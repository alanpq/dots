import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Controls.Basic

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

  onWheel: (wheel) => {
    if (!player || !player.canControl || !player.volumeSupported) return;
    player.volume = player.volume + wheel.angleDelta.y * 0.0005;
    volOsdLoader.active = true;
    volOsdCloseTimer.restart();
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
      anchor.margins.bottom: -((volOsdLoader.active ? volOsdLoader.item.implicitHeight + Style.popupOffset: 0) + Style.popupOffset)
      bgColor: playerColors[1]
      LText {
        id: txt
        color: playerColors[0]
        text: ``
        multiline: true
      }
      Timer {
          interval: 500
          running: popupLoader.active
          repeat: true
          triggeredOnStart: true
          onTriggered: {
              const pos = fmtTime(player.position);
              txt.text = `${pos} / ${fmtTime(player.length)}\n${Util.capitalize(playerKind)}`;
          }
      }
    }
  }

  LazyLoader {
    id: volOsdLoader
    Popup {
      id: volOsd
      target: root
      above: false
      bgColor: playerColors[1]

      ProgressBar {
          id: control
          value: player.volume
          padding: 0

          Behavior on value {
            NumberAnimation {
              duration: 100
            }
          }

          background: Rectangle {
              implicitWidth: 200
              implicitHeight: 6
              color: Qt.lighter(playerColors[1], 2.0)
              radius: 3
          }

          contentItem: Item {
              implicitWidth: 200
              implicitHeight: 4

              // Progress indicator for determinate state.
              Rectangle {
                  width: control.visualPosition * parent.width
                  height: parent.height
                  radius: 2
                  color: Qt.darker(playerColors[1], 2.0)
                  visible: !control.indeterminate
              }
          }
      }

      // LText {
      //   id: txt
      //   color: playerColors[0]
      //   text: `${player.volume}`
      //   multiline: true
      // }
    }
  }
  Timer {
      id: volOsdCloseTimer
      interval: 1000
      running: false
      repeat: false
      onTriggered: {
          volOsdLoader.active = false
      }
  }
}
