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
  property int barHeight: Style.barHeight
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
              UpcomingEvent { screen: topBar.screen }
          }
      }

      Item {
          id: leftCornerArea
          height: barHeight
          anchors.left: leftBar.right
          anchors.right: centerBar.left

          Corner {
             anchors.fill: parent
              corners: [1]
              cornerType: "cubic"
              cornerHeight: barHeight
              cornerWidth: barPadding*cornerFrac
              color: backgroundColor
          }
      }

      Item {
          id: centerCornerLeft
          height: barHeight
          anchors.left: leftBar.right
          anchors.right: centerBar.left

          Corner {
              anchors.fill: parent
              corners: [0]
              cornerType: "cubic"
              cornerHeight: barHeight
              cornerWidth: barPadding*cornerFrac
              color: music.desiredColor
              Behavior on color {
                  ColorAnimation {
                      duration: 100
                  }
              }

          }
      }
      WrapperRectangle{
          id: centerBar
          color: music.desiredColor
          anchors.centerIn: parent
          Row{
              height: barHeight
              Music {
                  id: music
                  screen: topBar.screen
              }
          }
          Behavior on color {
              ColorAnimation {
                  duration: 100
              }
          }
      }
      Item {
          id: centerCornerRight
          height: barHeight
          anchors.left: centerBar.right
          anchors.right: rightBar.left

          Corner {
              anchors.fill: parent
              corners: [1]
              cornerType: "cubic"
              cornerHeight: barHeight
              cornerWidth: barPadding*cornerFrac
              color: music.desiredColor
              Behavior on color {
                  ColorAnimation {
                      duration: 100
                  }
              }
          }
      }

      Item {
          id: rightCornerArea
          height: barHeight
          anchors.left: centerBar.right
          anchors.right: rightBar.left

          Corner {
              anchors.fill: parent
              corners: [0]
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

            Loader {
              id: brightness
              active: topBar.screenType === ScreenType.Laptop || topBar.screenType === ScreenType.Primary
              visible: active
              sourceComponent: Brightness {
                screen: topBar.screen
              }
            }

            Loader {
              id: battery
              active: UPower.devices.values.find(d => d.isLaptopBattery) !== null && topBar.screenType === ScreenType.Laptop
              visible: active
              sourceComponent: Battery {
                  screen: topBar.screen
              }
            }

            Tray {leftPadding: barPadding; rightPadding: barPadding * 1.5; size: Style.fontSize * 1.5}

            ClockDisplay { width: 80 }
          }
      }
    }
  }
}
