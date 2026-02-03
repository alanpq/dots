import { Temporal } from "temporal-polyfill"

const CLIENT_ID = process.env.CLIENT_ID!
const CLIENT_SECRET = process.env.CLIENT_SECRET!
if ([CLIENT_ID, CLIENT_SECRET].some(x => x === undefined)) {
    console.error('CLIENT_ID and CLIENT_SECRET not set in .env, see .env.example')
    process.exit()
}
let ACCESS_TOKEN = process.env.ACCESS_TOKEN
let ACCESS_TOKEN_EXP = process.env.ACCESS_TOKEN_EXP
let REFRESH_TOKEN = process.env.REFRESH_TOKEN

if ([ACCESS_TOKEN, ACCESS_TOKEN_EXP, REFRESH_TOKEN].some(x => x === undefined))
    await getToken({ useRefreshToken: false }) // first run, get initial tokens
if (Number(ACCESS_TOKEN_EXP) < Temporal.Now.instant().epochMilliseconds)
    await getToken({ useRefreshToken: true }) // update tokens using refresh


class State {
    cals: GCalList | null = null;

    cal_events: { [id: string]: GCalEvents } = {};

    constructor() {
    }

    async fetchCalList(depth: number = 0) {
        if (depth > 1) {
            throw new Error("recursion error");
        }
        const params = new URLSearchParams();
        const sync = this.cals?.nextSyncToken;
        if (sync) {
            params.append("syncToken", sync);
        }
        const res = await fetch(`https://www.googleapis.com/calendar/v3/users/me/calendarList?${params}`, {
            headers: { Authorization: `Bearer ${ACCESS_TOKEN}` },
        });
        if (sync && (res.status === 404 || res.status === 410)) {
            this.cals = null;
            return await this.fetchCalList(depth + 1);
        }
        if (res.status !== 200) {
            throw new Error(`cal list failed - ${res.status}`);
        }

        const body = await res.json() as GCalList;
        this.cals = { ...body, items: sync ? body.items.concat(this.cals?.items ?? []) : body.items };
        return this.cals;
    }

    async fetchEvents(calId: string, since: Temporal.Instant, depth: number = 0): Promise<GCalEvent[]> {
        if (depth > 1) {
            throw new Error("recursion error");
        }
        const tz = 'UTC';

        const timeMax = since
            .toZonedDateTimeISO(tz)
            .startOfDay()
            .add({ days: 1 })
            .toInstant()
            .toString();
        const params = new URLSearchParams({
            timeMin: since.toString(),
            timeMax,
            singleEvents: 'true', // expand reoccurring events into separate instances
            orderBy: 'startTime',
        })
        const sync = this.cal_events[calId]?.nextSyncToken;
        if (sync) {
            params.append("syncToken", sync);
        }
        const res = await fetch(`https://www.googleapis.com/calendar/v3/calendars/${calId}/events?${params}`, {
            headers: { Authorization: `Bearer ${ACCESS_TOKEN}` },
        });

        if (sync && (res.status === 404 || res.status === 410)) {
            delete this.cal_events[calId];
            return await this.fetchEvents(calId, since, depth + 1);
        }

        if (res.status === 404) {
            return [];
        }

        if (res.status !== 200) {
            throw new Error(`events failed - ${res.status}`);
        }

        const body = await res.json() as GCalEvents;
        // console.log({ body })
        this.cal_events[calId] = {
            ...body,
            items: sync ? body.items.concat(this.cal_events[calId]?.items ?? []) : body.items
        };
        return this.cal_events[calId].items;
    }

    async load() {
        try {
            const file = Bun.file("cache.json")
            const json = await file.json();
            this.cals = json.cals;
            this.cal_events = json.cal_events;
        } catch {
            // console.error("no cache found");
        }
    }

    async save() {
        const file = Bun.file("cache.json")
        await file.write(JSON.stringify({
            cals: this.cals,
            cal_events: this.cal_events,
        }));
    }
}

const state = new State();
await state.load();

console.log(JSON.stringify(await getEvents(state), null, 2))

await state.save();

function updateDotEnv() {
    const content = Object.entries({ CLIENT_ID, CLIENT_SECRET, ACCESS_TOKEN, ACCESS_TOKEN_EXP, REFRESH_TOKEN })
        .map(([k, v]) => `${k}=${v}`)
        .join("\n")
    Bun.write(".env", content)
}

function getAuthorizationCode() {
    if (!process.stdin.isTTY) {
        console.error("auth required");
        process.exit(1);
    }

    const authorizationCodeURL = `https://accounts.google.com/o/oauth2/v2/auth?${new URLSearchParams({
        scope: 'https://www.googleapis.com/auth/calendar',
        response_type: 'code',
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
        client_id: CLIENT_ID,
    })}`

    const authorizationCode = prompt(`${authorizationCodeURL}\nauth code:`)!.trim()
    if (!/^\d\/[\w-]{60}$/.test(authorizationCode)) {
        console.error('invalid auth code, try again')
        return getAuthorizationCode()
    }
    return authorizationCode
}

interface TokenData {
    access_token: string
    refresh_token?: string
    expires_in: number
    // also `{ scope: string; token_type: "Bearer" }` but I'll never touch those
}
async function getToken({ useRefreshToken }: { useRefreshToken: boolean }) {
    const token = await fetch('https://www.googleapis.com/oauth2/v4/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            client_id: CLIENT_ID,
            client_secret: CLIENT_SECRET,
            redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',

            grant_type: useRefreshToken ? 'refresh_token' : 'authorization_code',
            code: useRefreshToken ? undefined : getAuthorizationCode(),
            refresh_token: useRefreshToken ? REFRESH_TOKEN : undefined,
        }),
    }).then(r => r.json() as Promise<TokenData>)
    ACCESS_TOKEN = token.access_token
    ACCESS_TOKEN_EXP = (Temporal.Now.instant().epochMilliseconds + (token.expires_in * 1000)).toString() // expires_in is how many seconds until the token is expired
    if (token?.refresh_token) REFRESH_TOKEN = token.refresh_token
    updateDotEnv()
}

interface GCalEventTimingInfo { dateTime?: string; date?: string }
interface GCalEvents {
    etag: string,
    items: GCalEvent[],
    nextSyncToken?: string,
}
interface GCalEvent {
    status: string
    htmlLink: string
    summary: string
    start: GCalEventTimingInfo
    end: GCalEventTimingInfo
}

interface GCalListItem {
    "kind": "calendar#calendarListEntry",
    "etag": string,
    "id": string,
    "summary": string,
    "description": string,
    "location": string,
    "timeZone": string,
    "dataOwner": string,
    "summaryOverride": string,
    "colorId": string,
    "backgroundColor": string,
    "foregroundColor": string,
    "hidden": boolean,
    "selected": boolean,
    "accessRole": string,
    "defaultReminders": [
        {
            "method": string,
            "minutes": number
        }
    ],
    "notificationSettings": {
        "notifications": [
            {
                "type": string,
                "method": string
            }
        ]
    },
    "primary": boolean,
    "deleted": boolean,
    "conferenceProperties": {
        "allowedConferenceSolutionTypes": [
            string
        ]
    },
    "autoAcceptInvitations": boolean
}

interface GCalList {
    kind: string
    etag: string
    nextPageToken?: string
    items: GCalListItem[]
    nextSyncToken?: string
}

interface Event {
    title: string
    link: string
    startMs: number
    endMs: number
}


async function getEvents(state: State): Promise<Array<Event>> {
    const cals = await state.fetchCalList();
    if (!cals) throw "no cals!";

    // console.log({ cals });

    const now = Temporal.Now.instant()

    const events = (await Promise.all(cals.items.map(cal => state.fetchEvents(cal.id, now)))).flat().filter(Boolean);

    const gcalEvents = events
        .filter(event => event.status === 'confirmed') // no canceled/tentative
        .filter(event => event.start?.dateTime !== undefined) // no all-day events

    return gcalEvents.map(event => ({
        title: event.summary,
        link: event.htmlLink,
        startMs: Temporal.Instant.from(event.start.dateTime!).epochMilliseconds,
        endMs: Temporal.Instant.from(event.end.dateTime!).epochMilliseconds,
    }))
}
