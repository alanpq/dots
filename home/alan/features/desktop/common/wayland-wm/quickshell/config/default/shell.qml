//@ pragma UseQApplication
//@ pragma Env QML_XHR_ALLOW_FILE_READ=1n

import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects

import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland

import "modules/bartop"

import "settings"

ShellRoot {
  Connections {
    target: Quickshell
    function onReloadCompleted() {
      Quickshell.inhibitReloadPopup()
    }
    function onReloadFailed() {
      if (!Settings?.isDebug)
        Quickshell.inhibitReloadPopup()
    }
  }

  Timer {
    id: hyprlandTimer
    interval: 200
    repeat: false
    onTriggered: () => {
      console.log("TRIGGER")
      Hyprland.refreshToplevels()
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      hyprlandTimer.restart()
    }
  }

  BarTop {}
  // BarRight {}
}
