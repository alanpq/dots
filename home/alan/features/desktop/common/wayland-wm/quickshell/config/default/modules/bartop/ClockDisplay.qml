import Quickshell
import QtQuick
import "root:/settings"

Item {
    id: root
    implicitHeight: parent.height
    implicitWidth: parent.width

    property var size: "12"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
      id: clockText
      text: Qt.formatDateTime(clock.date, "dd/MM hh:mm")
      font.family: "Iosevka"
      font.weight: 500
      font.pointSize: parent.size
      color: Theme.palette.primary
      anchors.centerIn: parent
    }
}
