pragma ComponentBehavior: Bound

import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick

// Output-device dropdown for the volume popup. Lists the hardware sinks the
// virtual outputs can target (every Audio/Sink except the three virtual
// loopback sinks and the virtual mic sink) and, on selection, re-links all
// three virtual output playback nodes to the chosen sink via the packaged
// `quickshell-vol-route` helper. Runtime-only; the NixOS pipewire config still
// sets the boot-time target.
//
// Only unbound-safe node fields are read (name/description/nickname/isSink/id),
// so the candidate nodes need no PwObjectTracker.
Column {
    id: root

    // The sink the virtual outputs currently feed, resolved by VolumeControls.
    // Drives the header label and the selected-row marker. May be null.
    property var current: null

    // Width of a slider row above, so the popup surface keeps a single width.
    property real rowWidth: Style.volRowWidth

    property bool expanded: false

    width: root.rowWidth
    spacing: 0

    // Virtual sinks that are never selectable targets (they are what we route
    // *from*, plus the mic sink which is not an output).
    readonly property var excluded: ["music_output", "chat_output", "default_output", "virtual_mic_sink"]

    readonly property var devices: {
        const out = [];
        const nodes = Pipewire.nodes.values;
        for (let i = 0; i < nodes.length; i++) {
            const nd = nodes[i];
            if (nd.isSink && root.excluded.indexOf(nd.name) === -1)
                out.push(nd);
        }
        return out;
    }

    function deviceLabel(nd) {
        return nd ? (nd.description || nd.nickname || nd.name) : "no device";
    }

    Process {
        id: reroute
    }

    function selectDevice(nd) {
        root.expanded = false;
        if (!nd)
            return;
        reroute.command = ["quickshell-vol-route", nd.name];
        reroute.running = true;
    }

    // Divider between the sliders and the dropdown.
    Item {
        width: parent.width
        height: Style.volSelectorSpacing

        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: 1
            color: Theme.selection
        }
    }

    // Header: current device, chevron; click toggles the list.
    Rectangle {
        id: header

        width: parent.width
        implicitHeight: headerLabel.implicitHeight + 2 * Style.volSelectorRowVPad
        height: implicitHeight
        radius: Style.sectionRadius
        color: headerMouse.containsMouse ? Theme.selection : "transparent"

        Text {
            id: headerIcon

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Style.volIconWidth
            horizontalAlignment: Text.AlignHCenter
            color: Theme.accent
            font.family: Theme.monoFamily
            font.pointSize: Theme.fontSize
            text: "\uf025" // nf-fa-headphones
        }

        Text {
            id: chevron

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.foreground
            font.family: Theme.monoFamily
            font.pointSize: Theme.fontSize
            text: root.expanded ? "\u2304" : "\u203A"
        }

        Text {
            id: headerLabel

            anchors.left: headerIcon.right
            anchors.leftMargin: Style.volRowSpacing
            anchors.right: chevron.left
            anchors.rightMargin: Style.volRowSpacing
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            color: Theme.foreground
            font.family: Theme.monoFamily
            font.pointSize: Theme.fontSize
            text: root.deviceLabel(root.current)
        }

        MouseArea {
            id: headerMouse

            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
        }
    }

    // Expandable device list.
    Column {
        width: parent.width
        visible: root.expanded
        spacing: 0

        Repeater {
            model: root.devices

            delegate: Rectangle {
                id: option

                required property var modelData
                readonly property bool selected: root.current && modelData.id === root.current.id

                width: root.width
                implicitHeight: optionLabel.implicitHeight + 2 * Style.volSelectorRowVPad
                height: implicitHeight
                color: optionMouse.containsMouse ? Theme.selection : "transparent"

                Text {
                    id: optionLabel

                    anchors.left: parent.left
                    anchors.leftMargin: Style.volIconWidth + Style.volRowSpacing
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    color: option.selected ? Theme.accent : Theme.foreground
                    font.family: Theme.monoFamily
                    font.pointSize: Theme.fontSize
                    text: (option.selected ? "\u2022 " : "") + root.deviceLabel(option.modelData)
                }

                MouseArea {
                    id: optionMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.selectDevice(option.modelData)
                }
            }
        }
    }
}
