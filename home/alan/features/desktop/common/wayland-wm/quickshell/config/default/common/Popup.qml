
import QtQml
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

import "root:/common"
import "root:/settings"

PopupWindow {
  id: root
  default property alias data: content.data
  property alias content: content
  required property Item target
  property bool above: true
  property bool mono: false
  property double horizontalMargin: Style.popupHorizontalMargin
  property double verticalMargin: Style.popupVerticalMargin
  property double radius: Style.popupRadius
  property string bgColor: Style.popupBgColor
  anchor.item: target
  anchor.edges: above ? Edges.Top : Edges.Bottom
  anchor.gravity: above ? Edges.Top : Edges.Bottom
  anchor.adjustment: PopupAdjustment.SlideX
  anchor.margins.bottom: -Style.popupOffset
  anchor.margins.top: -Style.popupOffset
  implicitWidth: content.implicitWidth
  implicitHeight: content.implicitHeight
  color: Style.transparent
  visible: true

  function redraw() {
    visible = false
    visible = true
  }
  onImplicitWidthChanged: redraw()
  onImplicitHeightChanged: redraw()

  WrapperRectangle {
    id: content
    leftMargin: root.horizontalMargin
    rightMargin: root.horizontalMargin
    topMargin: root.verticalMargin
    bottomMargin: root.verticalMargin
    radius: root.radius
    color: root.bgColor
    focus: true
    Keys.onEscapePressed: root.closed()
  }
}
