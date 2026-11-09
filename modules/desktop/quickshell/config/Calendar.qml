pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import QtQuick

// Top-left section: today's calendar across every configured Google Calendar
// account (see quickshell-calendar / calendar-fetch.py). The bar shows only the
// current day's upcoming events, with overlapping events collapsed into one
// entry plus a "+N others" label. Click to toggle a dropdown (CalendarAgenda)
// listing the entire day's agenda. Refreshed once a minute; hidden when the day
// has no events.
Section {
    id: root

    // The bar window, needed to anchor the agenda popup.
    required property var panelWindow

    // Full current-day agenda (start-sorted), feeding the dropdown.
    property var agenda: []

    // [{ head: event, extra: int }] — one entry per overlap cluster, upcoming
    // only, feeding the collapsed bar.
    property var groups: []

    readonly property int maxGroups: 3

    visible: agenda.length > 0

    // Local midnight at the start of today.
    function startOfToday() {
        const n = new Date();
        return new Date(n.getFullYear(), n.getMonth(), n.getDate());
    }

    // True when the event overlaps the [today 00:00, tomorrow 00:00) window.
    // Covers timed events today, all-day events, and multi-day spans.
    function isToday(e) {
        const dayStart = root.startOfToday().getTime();
        const dayEnd = dayStart + 86400000;
        const s = Date.parse(e.start);
        const en = Date.parse(e.end);
        return s < dayEnd && en > dayStart;
    }

    // Wall-clock tick driving the relative labels. Updated every minute by a
    // timer independent of the gcalcli fetch, so "in N min" counts down live.
    property double now: Date.now()

    // Relative countdown for the collapsed bar: all-day events read "all day",
    // in-progress events "now", otherwise "in N min" / "in N hr" until start.
    // Reads root.now so the binding re-evaluates on every minute tick.
    function timeLabel(e) {
        if (e.allDay)
            return "all day";
        const diffMin = Math.round((new Date(e.start).getTime() - root.now) / 60000);
        if (diffMin <= 0)
            return "now";
        if (diffMin < 60)
            return "in " + diffMin + " min";
        return "in " + Math.round(diffMin / 60) + " hr";
    }

    // Filter the fetched list to today, then collapse today's *upcoming* timed
    // events into overlap clusters for the bar: a new cluster begins only once
    // an event starts at/after the running end of the current one; everything
    // else folds into the cluster's "extra" count. All-day events stand alone
    // (each its own entry) so they never swallow the day's timed meetings.
    function rebuild(events) {
        const today = events.filter(e => root.isToday(e));
        root.agenda = today;

        const now = Date.now();
        const out = [];
        let cur = null;
        let curEnd = 0;
        for (const e of today) {
            if (Date.parse(e.end) <= now)
                continue;
            const start = Date.parse(e.start);
            const end = Date.parse(e.end);
            if (e.allDay) {
                out.push({
                    head: e,
                    extra: 0
                });
                cur = null;
                continue;
            }
            if (!cur || start >= curEnd) {
                cur = {
                    head: e,
                    extra: 0
                };
                curEnd = end;
                out.push(cur);
            } else {
                cur.extra += 1;
                curEnd = Math.max(curEnd, end);
            }
        }
        root.groups = out.slice(0, root.maxGroups);
    }

    Process {
        id: fetch
        command: ["quickshell-calendar"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.rebuild(JSON.parse(this.text));
                } catch (e) {
                    root.agenda = [];
                    root.groups = [];
                }
            }
        }
    }

    Component.onCompleted: fetch.running = true

    // Re-fetch the agenda from gcalcli (network/subprocess) every 5 minutes.
    Timer {
        interval: 300000
        running: true
        repeat: true
        onTriggered: fetch.running = true
    }

    // Tick the wall clock every minute so relative labels count down between
    // fetches. Aligned to the next whole minute, then every 60s.
    Timer {
        interval: 60000 - (Date.now() % 60000)
        running: true
        repeat: true
        onTriggered: {
            root.now = Date.now();
            interval = 60000;
        }
    }

    // Whole section is the click handle: toggles the day-agenda dropdown.
    MouseArea {
        id: handle
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: bar.implicitWidth
        implicitHeight: bar.implicitHeight
        cursorShape: Qt.PointingHandCursor
        onClicked: agendaPopup.opened ? agendaPopup.close() : agendaPopup.open()

        Row {
            id: bar
            spacing: Style.sectionSpacing

            // Calendar glyph — stable handle even when nothing is upcoming.
            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.accent
                font.family: Theme.monoFamily
                font.pointSize: Theme.fontSize
                text: "\uf073" // nerd font calendar
            }

            Repeater {
                model: root.groups

                delegate: Row {
                    id: group
                    required property var modelData
                    required property int index

                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.sectionSpacing

                    // Separator between clusters.
                    Text {
                        visible: group.index > 0
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.muted
                        font.family: Theme.monoFamily
                        font.pointSize: Theme.fontSize
                        text: "\u00B7"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.accent
                        font.family: Theme.monoFamily
                        font.pointSize: Theme.fontSize
                        text: root.timeLabel(group.modelData.head)
                    }

                    // Title, elided so a long event can't blow the bar up.
                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: Math.min(title.implicitWidth, Style.calTitleMaxWidth)
                        implicitHeight: title.implicitHeight

                        Text {
                            id: title
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            color: Theme.foreground
                            font.family: Theme.monoFamily
                            font.pointSize: Theme.fontSize
                            text: group.modelData.head.title
                        }
                    }

                    Text {
                        visible: group.modelData.extra > 0
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.muted
                        font.family: Theme.monoFamily
                        font.pointSize: Theme.fontSize
                        text: "+" + group.modelData.extra + (group.modelData.extra === 1 ? " other" : " others")
                    }
                }
            }
        }
    }

    Popup {
        id: agendaPopup
        anchorWindow: root.panelWindow
        anchorItem: root

        // Collapse any open detail sidebar when the dropdown is dismissed, so it
        // reopens showing just the list.
        onOpenedChanged: if (!opened)
            agendaView.selected = null

        CalendarAgenda {
            id: agendaView
            events: root.agenda
        }
    }
}
