import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property color baseColor: Theme.surface
    property color hoverColor: "#313244"
    property color textColor: "#cdd6f4"
    property color accentColor: "#89b4fa"
    signal clicked(MouseEvent mouse)

    radius: 0
    color: mouseArea.containsMouse ? hoverColor : baseColor
    width: labelItem.visible ? labelItem.width + iconItem.width + 24 : iconItem.width + 16
    height: 32

    Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: iconItem
            text: root.icon
            font.pixelSize: 16
            color: root.accentColor
            visible: root.icon !== ""
        }

        Text {
            id: labelItem
            text: root.label
            font.pixelSize: 13
            color: root.textColor
            visible: root.label !== ""
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => root.clicked(mouse)
    }
}
