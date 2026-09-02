import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Right-cluster section: default sink volume. Scroll to adjust, click to toggle
// mute. Always applicable, so never hidden.
Section {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: (root.sink && root.sink.ready) ? root.sink.audio : null
    readonly property bool muted: root.audio ? root.audio.muted : false
    readonly property int percent: root.audio ? Math.round(root.audio.volume * 100) : 0
    readonly property real step: 0.05

    // Nerd Font speaker glyph by level; crossed-out when muted.
    readonly property string glyph: {
        if (root.muted || root.percent === 0)
            return "\uf026"; // volume_off
        if (root.percent < 50)
            return "\uf027"; // volume_down
        return "\uf028"; // volume_up
    }

    // Binds the sink so its audio volume/mute stay live.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        color: root.muted ? Theme.muted : Theme.foreground
        font.family: Theme.monoFamily
        font.pointSize: Theme.fontSize
        text: root.glyph + "  " + (root.muted ? "muted" : root.percent + "%")

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.audio)
                    root.audio.muted = !root.audio.muted;
            }
            onWheel: wheel => {
                if (root.audio)
                    root.audio.volume = Math.max(0, Math.min(1, root.audio.volume + (wheel.angleDelta.y > 0 ? root.step : -root.step)));
                wheel.accepted = true;
            }
        }
    }
}
