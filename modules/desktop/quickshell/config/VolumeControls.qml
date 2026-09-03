pragma ComponentBehavior: Bound

import Quickshell.Services.Pipewire
import QtQuick

// Volume popup body. The first row is the *hardware* sink the virtual outputs
// are routed to (resolved live from the graph), then a slider for each virtual
// output (Chat, Music, Default). Rows with no resolved node are omitted.
//
// Topology: each virtual output is a module-loopback exposing two nodes -- an
// Audio/Sink apps play into (`<name>`), and a Stream/Output/Audio playback node
// (`<name>_playback`) whose links feed a hardware sink. To find the master we
// take the Default output, hop to its playback sibling by name, then follow the
// global link graph to the sink that node drives. Re-pointing the loopback at a
// different device re-resolves the binding.
//
// Resolution touches only unbound-safe fields (name/description/isSink/isStream
// /id and the global link graph); `PwNode.properties` is invalid until a node
// is bound, and the playback sibling is never bound, so it is never read here.
Column {
    id: root

    // First sink node matching name/description/nickname (case-exact).
    function sinkByName(wanted) {
        const nodes = Pipewire.nodes.values;
        for (let i = 0; i < nodes.length; i++) {
            const nd = nodes[i];
            if (nd.isSink && (nd.name === wanted || nd.description === wanted || nd.nickname === wanted))
                return nd;
        }
        return null;
    }

    // The loopback playback node (Stream/Output/Audio) that carries `sink`'s
    // audio to hardware, matched by the module-loopback `<name>_playback`
    // convention. null if `sink` isn't a loopback virtual sink.
    function loopbackPlayback(sink) {
        if (!sink)
            return null;
        const wanted = sink.name + "_playback";
        const nodes = Pipewire.nodes.values;
        for (let i = 0; i < nodes.length; i++) {
            const nd = nodes[i];
            if (nd.isStream && nd.name === wanted)
                return nd;
        }
        return null;
    }

    readonly property var defaultSink: root.sinkByName("Default")
    readonly property var playback: root.loopbackPlayback(root.defaultSink)

    // The hardware sink the Default output currently feeds: the first sink the
    // loopback playback node links to in the global link graph.
    readonly property var masterSink: {
        const p = root.playback;
        if (!p)
            return null;
        const lgs = Pipewire.linkGroups.values;
        for (let i = 0; i < lgs.length; i++) {
            const lg = lgs[i];
            if (lg.source && lg.source.id === p.id && lg.target && lg.target.isSink)
                return lg.target;
        }
        return null;
    }

    // { node, icon } per slider: hardware master, then the three virtual
    // outputs. Nerd Font glyphs: speaker, speech bubble, music note, gamepad.
    readonly property var rows: [
        {
            node: root.masterSink,
            icon: "\uf028"
        },
        {
            node: root.sinkByName("Chat"),
            icon: "\uf075"
        },
        {
            node: root.sinkByName("Music"),
            icon: "\uf001"
        },
        {
            node: root.defaultSink,
            icon: "\uf11b"
        }
    ]

    // Keep every referenced node bound so its audio volume/mute stay live.
    PwObjectTracker {
        objects: root.rows.map(r => r.node).filter(n => n)
    }

    padding: Style.volPopupPad
    spacing: Style.volSliderSpacing

    Repeater {
        model: root.rows

        delegate: VolumeSlider {
            required property var modelData

            visible: modelData.node !== null
            node: modelData.node
            icon: modelData.icon
        }
    }
}
