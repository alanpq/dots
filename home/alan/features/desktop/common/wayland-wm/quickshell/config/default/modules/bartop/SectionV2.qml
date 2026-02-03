
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "root:/common"
import "root:/settings"

Item {
  id: root
  required property ShellScreen screen
  readonly property bool isOnTop: ScreenType.isOnTop(ScreenType.get(screen))
  default property alias data: row.data
  property alias rect: rect
  property alias row: row
  property alias mouse: mouse
  property alias txt: txt
  property double horizontalMargin: Style.pillMargin
  property double verticalMargin: (rect.implicitHeight - row.implicitHeight) / 2
  property double spacing: Style.pillSpacing
  property string color: Style.pillBgColor
  property string textColor: Style.textPrimaryColor
  property bool roundLeft: true
  property bool roundRight: true
  property string icon: ""
  property string text: ""
  property string prefix: ""
  property string suffix: ""

  property bool clickable: true
  property bool hoverable: false
  property double hoverDelay: Style.tooltipDelay

  property bool mono: true
  signal click(MouseEvent mouse)
  signal leftClick(MouseEvent mouse)
  signal rightClick(MouseEvent mouse)
  signal middleClick(MouseEvent mouse)
  signal doubleClick(MouseEvent mouse)
  signal leftDoubleClick(MouseEvent mouse)
  signal rightDoubleClick(MouseEvent mouse)
  signal middleDoubleClick(MouseEvent mouse)
  signal wheel(WheelEvent wheel)
  signal wheelUp(WheelEvent wheel)
  signal wheelDown(WheelEvent wheel)
  signal wheelRight(WheelEvent wheel)
  signal wheelLeft(WheelEvent wheel)

  signal hover()
  signal hoverEnd()

  implicitWidth: rect.implicitWidth
  implicitHeight: rect.implicitHeight

  WrapperRectangle {
    id: rect
    implicitHeight: Style.pillHeight
    radius: implicitHeight / 2
    topLeftRadius: root.roundLeft ? radius : 0
    bottomLeftRadius: root.roundLeft ? radius : 0
    topRightRadius: root.roundRight ? radius : 0
    bottomRightRadius: root.roundRight ? radius : 0
    leftMargin: root.horizontalMargin
    rightMargin: root.horizontalMargin
    topMargin: root.verticalMargin
    bottomMargin: root.verticalMargin
    color: root.color

    RowLayout {
      id: row
      spacing: root.spacing

      LText {
        id: txt
        visible: !!root.icon || !!root.text
        mono: root.mono
        text: Util.flattenString([root.icon, root.text === "" ? "" : `${root.prefix}${root.text}${root.suffix}`].filter(x => x !== "").join(" "))
        font.pointSize: Style.pillFontSize
        activeColor: textColor

        Behavior on activeColor {
            ColorAnimation {
                duration: 200
            }
        }
      }
        Behavior on implicitWidth {
            NumberAnimation {
                duration: 1000
            }
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }
  }

  MouseArea {
    id: mouse
    anchors.fill: root
    enabled: root.clickable
    onClicked: mouse => {
      root.click(mouse)
      if (mouse.button === Qt.LeftButton)
        root.leftClick(mouse)
      else if (mouse.button === Qt.RightButton)
        root.rightClick(mouse)
      else if (mouse.button === Qt.MiddleButton)
        root.middleClick(mouse)
    }
    onDoubleClicked: mouse => {
      root.doubleClick(mouse)
      if (mouse.button === Qt.LeftButton)
        root.leftDoubleClick(mouse)
      else if (mouse.button === Qt.RightButton)
        root.rightDoubleClick(mouse)
      else if (mouse.button === Qt.MiddleButton)
        root.middleDoubleClick(mouse)
    }
    onWheel: wheel => {
      root.wheel(wheel)
      if (wheel.angleDelta.y > 0)
        root.wheelUp(wheel)
      else if (wheel.angleDelta.y < 0)
        root.wheelDown(wheel)
      if (wheel.angleDelta.x > 0)
        root.wheelRight(wheel)
      else if (wheel.angleDelta.x < 0)
        root.wheelLeft(wheel)
    }
    hoverEnabled: root.hoverable
    onEntered: {
      if (!hoverEnabled)
        return
      hover.start()
    }
    onExited: {
      if (!hoverEnabled)
        return
      hover.stop()
      root.hoverEnd()
    }
    acceptedButtons: root.clickable ? Qt.AllButtons : Qt.NoButton
    cursorShape: root.clickable ? Qt.PointingHandCursor : undefined
  }

  Timer {
    id: hover
    interval: root.hoverDelay
    onTriggered: {
      if (!mouse.hoverEnabled)
        return
      root.hover()
    }
  }
}
