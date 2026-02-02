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

import "root:/common"
import "root:/settings"

Scope {
  property int barHeight: 35
  property int barPadding: barHeight/2
  property var backgroundColor: Theme.palette.surface

  property var cornerFrac: 2

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property ShellScreen modelData
      id: topBar
      screen: modelData

      color: 'transparent'

      readonly property int screenType: ScreenType.get(screen)
      readonly property bool isOnTop: ScreenType.isOnTop(screenType)
      anchors {
        top: isOnTop
        bottom: !isOnTop
        left: true
        right: true
      }

      implicitHeight: barHeight
      exclusiveZone: barHeight+3

      WrapperRectangle{
          id: leftBar
          color: backgroundColor
          anchors.left: parent.left
          Row{
              height: barHeight
              Workspaces { screen: topBar.screen }
          }
      }

      Item {
          id: leftCornerArea
          height: barHeight
          anchors.left: leftBar.right
          anchors.right: centerBar.left

          Corner {
             anchors.fill: parent
              corners: [0, 1]
              cornerType: "cubic"
              cornerHeight: barHeight
              cornerWidth: barPadding*cornerFrac
              color: backgroundColor
          }
      }

      WrapperRectangle{
          id: centerBar
          color: backgroundColor
          anchors.centerIn: parent
          Row{
              height: barHeight
          }
      }

      Item {
          id: rightCornerArea
          height: barHeight
          anchors.left: centerBar.right
          anchors.right: rightBar.left

          Corner {
              anchors.fill: parent
              corners: [0, 1]
              cornerType: "cubic"
              cornerHeight: barHeight
              cornerWidth: barPadding*cornerFrac
              color: backgroundColor
          }
      }

      WrapperRectangle{
          id: rightBar
          color: backgroundColor
          anchors.right: parent.right
          Row{
            height: barHeight

            rightPadding: barPadding

            Network { screen: topBar.screen }
            Brightness { screen: topBar.screen }
            Battery { screen: topBar.screen }

            Tray {rightPadding: barPadding; size: barHeight * 0.6}

            ClockDisplay{width: 80; size: barHeight * 0.37}
          }
      }
    }
  }
}
