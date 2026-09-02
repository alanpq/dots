import Quickshell
import Quickshell.Io
import QtQuick

// Right-cluster section: backlight level. Scroll to adjust. Hidden on machines
// with no backlight device (e.g. desktops), where brightnessctl reports none.
//
// brightnessctl drives the same device niri's XF86MonBrightness keys use. We
// read the live value from sysfs rather than watching it: kernel backlight
// files don't deliver inotify events, so a short poll plus an immediate reload
// after our own writes keeps the readout current.
Section {
    id: root

    property string device: ""
    property int rawCurrent: 0
    property int rawMax: 0
    readonly property real fraction: root.rawMax > 0 ? Math.max(0, Math.min(1, root.rawCurrent / root.rawMax)) : 0
    readonly property int percent: Math.round(root.fraction * 100)
    readonly property int step: 5

    visible: root.device !== "" && root.rawMax > 0

    function adjust(up) {
        if (root.device === "")
            return;
        setter.command = ["brightnessctl", "-c", "backlight", "set", up ? ("+" + root.step + "%") : (root.step + "%-")];
        setter.running = true;
    }

    // One-shot discovery: "device,class,current,percent,max".
    Process {
        running: true
        command: ["brightnessctl", "-m", "-c", "backlight", "info"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = this.text.trim().split("\n").pop();
                const f = line ? line.split(",") : [];
                if (f.length >= 5) {
                    root.rawCurrent = parseInt(f[2]) || 0;
                    root.rawMax = parseInt(f[4]) || 0;
                    root.device = f[0];
                }
            }
        }
    }

    FileView {
        id: brightnessFile
        path: root.device ? "/sys/class/backlight/" + root.device + "/brightness" : ""
        onLoaded: root.rawCurrent = parseInt(this.text().trim()) || root.rawCurrent
    }

    // Applies the scroll adjustment, then refreshes the readout.
    Process {
        id: setter
        onExited: brightnessFile.reload()
    }

    // Catches changes made outside quickshell (the brightness hotkeys).
    Timer {
        running: root.device !== ""
        interval: 1000
        repeat: true
        onTriggered: brightnessFile.reload()
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.foreground
        font.family: Theme.monoFamily
        font.pointSize: Theme.fontSize
        text: "\uf185 " + root.percent + "%" // nf-fa-sun_o

        MouseArea {
            anchors.fill: parent
            onWheel: wheel => {
                root.adjust(wheel.angleDelta.y > 0);
                wheel.accepted = true;
            }
        }
    }
}
