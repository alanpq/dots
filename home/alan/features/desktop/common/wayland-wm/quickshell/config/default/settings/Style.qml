pragma Singleton
import QtQml
import QtQuick
import Quickshell

Singleton {
  readonly property string monospaceFont: "Iosevka"
  readonly property string sansSerifFont: "Roboto"
  readonly property double fontSize: 12
  readonly property color textPrimaryColor: Theme.palette.primary
  readonly property color textInactiveColor: Theme.palette.primary_fixed_dim
  readonly property color barBgColor: Theme.palette.surface
  readonly property double barHeight: 30
  readonly property double barHorizontalMargin: 10
  readonly property double barSpacing: 10
  readonly property color pillBgColor: "transparent"
  readonly property double pillFontSize: fontSize
  readonly property double pillHeight: barHeight
  readonly property double pillMargin: 12
  readonly property double pillSpacing: 10
  readonly property color dividerColor: Qt.color("#22FFFFFF")
  readonly property double dividerSize: 1.5
  readonly property color transparent: Qt.color("#00000000")
  readonly property double trayIconSize: 16
  readonly property color trayTitleColor: Qt.color("#D9CEFF")
  readonly property color workspacesUrgentColor: Qt.color("#BB4E68")
  readonly property color workspacesFocusedColor: Qt.color("#488FCA")
  readonly property color workspacesActiveColor: Qt.color("#2A6A9E")
  readonly property double workspacesAnimationSpeed: 100
  readonly property double workspacesTooltipDelay: 200
  readonly property double popupHorizontalMargin: 8
  readonly property double popupVerticalMargin: 8
  readonly property double popupRadius: 10
  readonly property double popupOffset: 4
  readonly property color popupBgColor: pillBgColor
  readonly property double tooltipDelay: 500
  readonly property double tooltipHorizontalMargin: popupHorizontalMargin + 4
  readonly property double tooltipVerticalMargin: popupVerticalMargin
  readonly property double tooltipRadius: popupRadius + 4
  readonly property color tooltipBgColor: popupBgColor
  readonly property double menuHorizontalMargin: popupHorizontalMargin
  readonly property double menuVerticalMargin: popupVerticalMargin
  readonly property double menuRadius: popupRadius
  readonly property color menuBgColor: popupBgColor
  readonly property double menuItemSpacing: 0
  readonly property double menuItemHorizontalMargin: menuHorizontalMargin
  readonly property double menuItemVerticalMargin: menuVerticalMargin
  readonly property double menuItemRadius: menuRadius
  readonly property double menuItemIconSpacing: menuItemHorizontalMargin
  readonly property double menuSeparatorVerticalMargin: menuVerticalMargin / 2
  readonly property color menuHoverBgColor: Qt.color("#22FFFFFF")
}
