import QtQuick

// One row of the volume popup: an icon (click toggles mute), a draggable /
// scrollable track, and a percent readout. Operates on a Pipewire sink node's
// audio; the node is kept live by the containing popup's PwObjectTracker.
Row {
    id: root

    required property var node
    required property string icon

    readonly property var audio: (root.node && root.node.ready) ? root.node.audio : null
    readonly property bool muted: root.audio ? root.audio.muted : false
    // Displayed level, clamped to 0-1 (PipeWire allows overamplification).
    readonly property real vol: root.audio ? Math.max(0, Math.min(1, root.audio.volume)) : 0
    readonly property real step: 0.05

    spacing: Style.volRowSpacing

    function setVolume(v) {
        if (root.audio)
            root.audio.volume = Math.max(0, Math.min(1, v));
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        width: Style.volIconWidth
        horizontalAlignment: Text.AlignHCenter
        color: root.muted ? Theme.muted : Theme.accent
        font.family: Theme.monoFamily
        font.pointSize: Theme.fontSize
        text: root.icon

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.audio)
                    root.audio.muted = !root.audio.muted;
            }
        }
    }

    Rectangle {
        id: track

        anchors.verticalCenter: parent.verticalCenter
        width: Style.volSliderWidth
        height: Style.volSliderHeight
        radius: height / 2
        color: Theme.selection

        Rectangle {
            width: Math.round(track.width * root.vol)
            height: track.height
            radius: track.radius
            color: root.muted ? Theme.muted : Theme.accent
        }

        Rectangle {
            x: Math.round(track.width * root.vol) - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: Style.volKnobSize
            height: Style.volKnobSize
            radius: width / 2
            color: Theme.foreground
        }

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => root.setVolume(mouse.x / track.width)
            onPositionChanged: mouse => {
                if (pressed)
                    root.setVolume(mouse.x / track.width);
            }
            onWheel: wheel => {
                root.setVolume(root.vol + (wheel.angleDelta.y > 0 ? root.step : -root.step));
                wheel.accepted = true;
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        width: Style.volPctWidth
        horizontalAlignment: Text.AlignRight
        color: Theme.foreground
        font.family: Theme.monoFamily
        font.pointSize: Theme.fontSize
        text: root.muted ? "muted" : Math.round(root.vol * 100) + "%"
    }
}
