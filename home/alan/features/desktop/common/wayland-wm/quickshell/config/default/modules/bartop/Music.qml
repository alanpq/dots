import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

import "root:/common"
import "root:/settings"

SectionV2 {
  id: root
  property var lastPlayer: null
  property var player: Mpris.players.values.filter(p => p.isPlaying)[0]

  hoverable: true

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

  onHover: () => {
    if(player)
    popupLoader.active = true
  }
  onHoverEnd: () => {
    popupLoader.active = false
  }

  function fmtTime(secs: number): string {
    const m = Math.floor(secs / 60);
    const h = Math.floor(m / 60);
    const s = Math.floor(secs % 60);
    return `${h}:${m}:${s}`;
  }

  LazyLoader {
    id: popupLoader
    Popup {
      id: popup
      target: root
      above: false
      LText {
        id: txt
        text: `${fmtTime(player.position)} / ${fmtTime(player.length)}`
        multiline: true
      }
    }
  }
}
