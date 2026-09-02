import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Center section: the currently-playing MPRIS track (Spotify, spotifyd,
// Firefox/YouTube, ...). Hidden when nothing is running.
Section {
    id: root

    // Prefer a player that is actually playing, else the first available.
    readonly property var player: {
        const ps = Mpris.players.values;
        if (ps.length === 0)
            return null;
        for (let i = 0; i < ps.length; i++)
            if (ps[i].isPlaying)
                return ps[i];
        return ps[0];
    }

    visible: player !== null

    // Play/pause toggle.
    Text {
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.accent
        font.family: Theme.monoFamily
        font.pointSize: Theme.fontSize
        text: (root.player && root.player.isPlaying) ? "\u23F8" : "\u25B6"

        MouseArea {
            anchors.fill: parent
            enabled: root.player && root.player.canTogglePlaying
            onClicked: root.player.togglePlaying()
        }
    }

    // Title — artist, elided so a long track can't blow the section up.
    Item {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: Math.min(mediaText.implicitWidth, Style.mediaMaxWidth)
        implicitHeight: mediaText.implicitHeight

        Text {
            id: mediaText
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: Theme.foreground
            font.family: Theme.monoFamily
            font.pointSize: Theme.fontSize
            text: {
                const p = root.player;
                if (!p)
                    return "";
                const t = p.trackTitle || "";
                const a = p.trackArtist || "";
                return a ? (t + "  \u2014  " + a) : t;
            }
        }
    }
}
