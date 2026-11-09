#!/usr/bin/env python3
"""Aggregate upcoming events from every authenticated gcalcli account.

Each Google account is an isolated gcalcli store selected by XDG_DATA_HOME:

    # one-time setup per account (run interactively):
    XDG_DATA_HOME=~/.local/share/quickshell-calendar/work \
        gcalcli --client-id=XXX.apps.googleusercontent.com init

The default gcalcli store (~/.local/share/gcalcli) is picked up too, as the
"default" account. Every account whose `gcalcli/oauth` token exists is queried
for the current calendar day (local midnight to next midnight); results are
normalised and merged into a single JSON array on stdout, sorted by start time:

    [{"title", "start", "end", "allDay", "account"}, ...]

start/end are local-time ISO strings ("YYYY-MM-DDTHH:MM"); all-day events use
T00:00 and set allDay=true. gcalcli must be on PATH.

Each account gets its own gcalcli config dir, mirroring its data dir, so you
can ignore calendars per account the native gcalcli way. The default account
reads ~/.config/gcalcli; a named account "work" reads
~/.config/quickshell-calendar/work/gcalcli. Drop a config.toml there:

    [calendars]
    ignore-calendars = ["Holidays in United States", "Birthdays"]
"""

import glob
import json
import os
import subprocess
import sys
from datetime import datetime, timedelta, timezone


def data_root() -> str:
    return os.environ.get(
        "XDG_DATA_HOME", os.path.expanduser("~/.local/share")
    )


def config_root() -> str:
    return os.environ.get(
        "XDG_CONFIG_HOME", os.path.expanduser("~/.config")
    )


def accounts() -> list[tuple[str, str, str]]:
    """(account, XDG_DATA_HOME, XDG_CONFIG_HOME) per store with an oauth token.

    Each account's config dir mirrors its data dir, so gcalcli reads a separate
    config.toml (and its [calendars] ignore-calendars) per account.
    """
    data = data_root()
    conf = config_root()
    found: list[tuple[str, str, str]] = []

    default_token = os.path.join(data, "gcalcli", "oauth")
    if os.path.exists(default_token):
        found.append(("default", data, conf))

    data_base = os.path.join(data, "quickshell-calendar")
    conf_base = os.path.join(conf, "quickshell-calendar")
    for token in sorted(
        glob.glob(os.path.join(data_base, "*", "gcalcli", "oauth"))
    ):
        name = token.split(os.sep)[-3]
        found.append((name, os.path.join(data_base, name),
                      os.path.join(conf_base, name)))

    return found


def fetch(
    data_home: str, config_home: str, start: datetime, end: datetime
) -> list[dict]:
    # gcalcli converts event times to local via python-dateutil's tzlocal(),
    # which mishandles Europe/Dublin's negative DST (reports +01:00 in winter)
    # and shifts every timed event +1h. Pin the child to UTC so no DST logic
    # runs; normalise() tags the times UTC and Qt localises them correctly.
    env = dict(
        os.environ,
        XDG_DATA_HOME=data_home,
        XDG_CONFIG_HOME=config_home,
        TZ="UTC",
    )
    try:
        out = subprocess.run(
            [
                "gcalcli", "--nocolor", "agenda", "--details", "all", "--tsv",
                start.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S"),
                end.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S"),
            ],
            env=env, capture_output=True, text=True, timeout=30,
        ).stdout
    except (OSError, subprocess.SubprocessError):
        return []

    return parse_tsv(out)


def parse_tsv(out: str) -> list[dict]:
    """Parse gcalcli's default agenda TSV (header + rows) into dicts.

    Default columns are start_date, start_time, end_date, end_time, title
    (`%Y-%m-%d` / `%H:%M`; empty time = all-day). title is the last column, so
    split with a bounded maxsplit to keep any embedded tabs inside it.
    """
    lines = out.splitlines()
    if not lines:
        return []
    header = lines[0].split("\t")
    rows: list[dict] = []
    for line in lines[1:]:
        if not line.strip():
            continue
        fields = line.split("\t", len(header) - 1)
        fields += [""] * (len(header) - len(fields))
        rows.append(dict(zip(header, fields)))
    return rows


def normalise(raw: dict, account: str) -> dict | None:
    sd, st = raw.get("start_date", ""), raw.get("start_time", "")
    ed, et = raw.get("end_date", ""), raw.get("end_time", "")
    if not sd:
        return None
    all_day = not st
    # fetch() runs gcalcli in UTC, so timed times are UTC wall-clock: tag them
    # with "Z" so Qt treats them as absolute instants and renders local time.
    # All-day events are floating calendar dates — no zone, no "Z".
    suffix = "" if all_day else "Z"
    return {
        "title": raw.get("title") or "(no title)",
        "start": f"{sd}T{st or '00:00'}{suffix}",
        "end": f"{ed or sd}T{et or '00:00'}{suffix}",
        "allDay": all_day,
        "account": account,
        "calendar": raw.get("calendar"),
        "location": raw.get("location"),
        "link": raw.get("html_link"),
        "conference_uri": raw.get("conference_uri"),
        "description": raw.get("description"),
    }


def main() -> None:
    # Local day window. datetime.astimezone() uses the OS zone database, which
    # handles Europe/Dublin's negative DST correctly (python-dateutil does not).
    start = datetime.now().astimezone().replace(
        hour=0, minute=0, second=0, microsecond=0
    )
    end = start + timedelta(days=1)

    events: list[dict] = []
    for name, data_home, config_home in accounts():
        for raw in fetch(data_home, config_home, start, end):
            ev = normalise(raw, name)
            if ev:
                events.append(ev)

    events.sort(key=lambda e: e["start"])
    json.dump(events, sys.stdout)


if __name__ == "__main__":
    main()
