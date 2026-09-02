// Basic Quickshell config: a top bar per screen with a live clock.
// https://quickshell.org/docs/
import Quickshell
import QtQuick

ShellRoot {
    // One panel per connected screen.
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData

                // Dock to the top edge, spanning the full width.
                anchors {
                    top: true
                    left: true
                    right: true
                }

                implicitHeight: 32
                color: "#1e1e2e"

                // Ticks once per second; drives the clock text below.
                SystemClock {
                    id: clock
                    precision: SystemClock.Seconds
                }

                Text {
                    anchors.centerIn: parent
                    color: "#cdd6f4"
                    font.family: "monospace"
                    font.pixelSize: 14
                    text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm:ss")
                }
            }
        }
    }
}
