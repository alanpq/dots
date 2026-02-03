import QtQuick
import "root:/common"
import "root:/settings"

Text {
  property bool active: true
  property string icon
  property string value: ""
  property bool mono: true
  property bool multiline: false
  property string activeColor: Style.textPrimaryColor
  property string inactiveColor: Style.textInactiveColor
  color: active ? activeColor : inactiveColor
  font.family: mono ? Style.monospaceFont : Style.sansSerifFont
  font.pointSize: Style.fontSize
  text: icon ? `${icon} ${value}` : value
  maximumLineCount: multiline ? undefined : 1
  wrapMode: multiline ? Text.Wrap : Text.NoWrap
  clip: true
}
