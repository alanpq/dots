import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

import "root:/common"
import "root:/settings"

Section {
    property var lastPlayer: null
    property var player: Mpris.players.values.filter(p => p.isPlaying)[0]

    onLeftClick: () => {
        (player ?? lastPlayer)?.togglePlaying()
        if(player) lastPlayer = player
    }

    property var iconLookup: {
    }
    function getIcon(player: MprisPlayer): string {
        switch (player.identity) {
            case "Mozilla firefox": {
                if (player.trackTitle.endsWith("YouTube")) {
                    return "\udb81\uddc3 "
                }
                return "\udb80\ude39 "
            }
            default: return iconLookup[identity] ?? null
        }
    }

    function format(player: MprisPlayer): string {
        switch(player.identity) {
            case "Mozilla firefox": return `${player.trackTitle.replace(/( - YouTube)$/, '').trim()}`;
            default: return `${player.trackTitle} - ${player.trackArtist}`;
        }
    }

    LText {
        mono: true
        icon: player && getIcon(player)
        value: player ? format(player) : "Nothing playing"
    }
}
