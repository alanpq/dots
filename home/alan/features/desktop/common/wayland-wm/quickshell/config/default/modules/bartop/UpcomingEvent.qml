import QtQuick
import Quickshell.Io
import Quickshell

import "root:/common"
import "root:/settings"

SectionV2 {
    id: calendarWidget
    property var upcomingEvents: []
    readonly property var currentEvent: {
        if (calendarWidget.upcomingEvents instanceof Error)
            return calendarWidget.upcomingEvents;
        return calendarWidget.upcomingEvents.find(event => Date.now() < event.endMs);
    }

    Process {
        id: fetchEvents
        workingDirectory: (new URL(Qt.resolvedUrl("gcal"))).pathname
        command: ["bun", "index.ts"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const stdout = this.text.trim();
                if (stdout === '')
                    return;
                try {
                    calendarWidget.upcomingEvents = JSON.parse(stdout);
                } catch (e) {
                    console.error(e);
                    calendarWidget.upcomingEvents = e;
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                const stderr = this.text.trim();
                if (stderr === '')
                    return;
                console.error(stderr);
                calendarWidget.upcomingEvents = new Error(stderr);
                eventTiming.text = "(run `bun gcal/index.ts`)";
            }
        }
    }
    Timer {
        interval: 600000 // 10 minutes
        running: true
        repeat: true
        onTriggered: fetchEvents.running = true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            const event = calendarWidget.currentEvent;
            calendarWidget.visible = true;
            if (event instanceof Error) {
                eventTitle.text = event.toString();
                return;
            }
            if (event === undefined) {
                eventTitle.text = "";
                eventTiming.text = "";
                calendarWidget.visible = false;
                return;
            }
            eventTitle.text = event.title ?? "No Title";

            const now = Date.now();
            const eventStarted = event.startMs <= now;
            const ms = (eventStarted ? event.endMs : event.startMs) - now;
            eventTiming.setText({
                ms,
                eventStarted
            });
        }
    }

    height: Style.barHeight
    width: eventDetails.implicitWidth

    visible: true

    clip: true

    Behavior on width {
        NumberAnimation {
            duration: 100
        }
    }

    Row {
        id: eventDetails
        spacing: 2
        rightPadding: 12
        LText {
            id: eventTitle
            color: "white"
            text: ""
            width: Math.min(implicitWidth, 550)
            elide: Text.ElideRight
        }
        LText {
            id: eventTiming
            anchors.bottom: eventTitle.bottom
            anchors.bottomMargin: 2
            color: "#bac2de"
            text: ""
            font.pixelSize: 10

            function setText({
                ms,
                eventStarted
            }) {
                const h = Math.floor(ms / 36e5);
                const m = Math.floor(ms / 6e4 % 60);
                const time = (h ? h + 'hr' : '') + (m ? m + 'm' : '') || Math.floor(ms / 1e3) + 's';

                this.text = `(${eventStarted ? '-' : ''}${time})`;
            }
        }
    }

    // MouseArea {
    //     readonly property bool eventShown: calendarWidget.currentEvent !== undefined && !(calendarWidget.currentEvent instanceof Error)
    //     cursorShape: eventShown ? Qt.PointingHandCursor : Qt.ArrowCursor
    //     anchors.fill: parent
    //     onPressed: {
    //         if (this.eventShown)
    //             Quickshell.execDetached(["xdg-open", calendarWidget.currentEvent.link])
    //     }
    // }
}
