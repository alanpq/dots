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
  property var resolved: player && resolvePlayerKind(player)
  property var lastResolved: lastPlayer && resolvePlayerKind(lastPlayer)
  property var playerKind: (resolved && resolved.kind) ?? (lastResolved && lastResolved.kind)
  property var trackTitle: (resolved && resolved.trackTitle)
  property var playerColors: colorLookup[playerKind ?? ""] ?? colorLookup[""]

  hoverable: true

  onLeftClick: () => {
    (player ?? lastPlayer)?.togglePlaying()
    if(player) lastPlayer = player
  }


  function resolvePlayerKind(player: MprisPlayer): variant {
    switch (player.identity) {
      case "Mozilla firefox": {
        if (player.trackTitle.endsWith("YouTube")) {
          return {kind: "youtube", trackTitle: player.trackTitle.replace(/( - YouTube)$/, '').trim()}
        }
        return {kind: "firefox", trackTitle: player.trackTitle}
      }
      default: return {kind: player.identity.toLowerCase(), trackTitle: player.trackTitle}
    }
  }

  property var iconLookup: {
    "firefox": "\udb80\ude39 ",
    "youtube":  "\udb81\uddc3 ",
    "spotify": "\uf1bc",
  }
  property var colorLookup: {
    "": [Style.textPrimaryColor, Style.pillBgColor],
    "youtube": ["white", Qt.rgba(0.7,0,0,1)],
    "spotify": ["black", "#1ed760"],
  }

  function format(player: MprisPlayer): string {
    switch (playerKind) {
      case "firefox":
      case "youtube":
        return trackTitle;
      default: return `${player.trackTitle} - ${player.trackArtist}`;
    }
  }

  icon: playerKind && iconLookup[playerKind]
  property var desiredColor: player?.isPlaying ? playerColors[1] : Style.pillBgColor
  color: "transparent"
  textColor: playerColors[player?.isPlaying ? 0 : 1]
  text: player ? format(player) : lastPlayer ? "" : ""

  onHover: () => {
    if (player) popupLoader.active = true
  }
  onHoverEnd: () => {
    popupLoader.active = false
  }

  function fmtTime(secs: number): string {
    const m = Math.floor(secs / 60);
    const h = Math.floor(m / 60);
    const s = Math.floor(secs % 60);
    return h > 0 ? `${h.toString().padStart(2,"0")}:${m.toString().padStart(2,"0")}:${s.toString().padStart(2,"0")}` : `${m.toString().padStart(2,"0")}:${s.toString().padStart(2,"0")}`;
  }

  LazyLoader {
    id: popupLoader
    Popup {
      id: popup
      target: root
      above: false
      bgColor: playerColors[1]
      LText {
        id: txt
        color: playerColors[0]
        text: `${fmtTime(player.position)} / ${fmtTime(player.length)}\n${playerKind}`
        multiline: true
      }
    }
  }
}
