import Quickshell
import QtQuick

// One bar per screen. The panel is transparent; content lives in free-floating
// Section boxes across a center cluster (media) and a right cluster (tray,
// date, time).
PanelWindow {
    id: panel
    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Style.barHeight
    color: "transparent"

    // Ticks once per second; drives the date/time sections.
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // Center cluster: now-playing media.
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height
        spacing: Style.gap

        Media {}
    }

    // Right cluster: battery, brightness, volume, tray, then date, then time.
    Row {
        anchors.right: parent.right
        anchors.rightMargin: Style.gap
        height: parent.height
        spacing: Style.gap

        Battery {}

        Brightness {}

        Volume {
            panelWindow: panel
        }

        Tray {
            panelWindow: panel
        }

        // Date.
        Section {
            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.foreground
                font.family: Theme.monoFamily
                font.pointSize: Theme.fontSize
                text: Qt.formatDateTime(clock.date, "ddd d MMM")
            }
        }

        // Time.
        Section {
            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.accent
                font.family: Theme.monoFamily
                font.pointSize: Theme.fontSize
                text: Qt.formatDateTime(clock.date, "HH:mm:ss")
            }
        }
    }
}
