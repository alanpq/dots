
import QtQuick

import "root:/common"
import "root:/settings"

Popup {
  id: root
  verticalMargin: Style.tooltipVerticalMargin
  horizontalMargin: Style.tooltipHorizontalMargin
  radius: Style.tooltipRadius
  bgColor: Style.tooltipBgColor
  required property string tooltip
  LText {
    id: txt
    mono: root.mono
    text: root.tooltip
    multiline: true
  }
}
