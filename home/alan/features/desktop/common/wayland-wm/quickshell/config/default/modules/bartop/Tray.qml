import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Row {
    height: parent.height
    spacing: 10

    property int size: 20

    Repeater {
        model: SystemTray.items
        delegate: Item {

            width: size; height: size
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: (event) => {
                    if (event.button === Qt.LeftButton)
                      if (modelData.onlyMenu) {
                        menu.open()
                      }
                      else modelData.activate();
                    else if (modelData.hasMenu)
                        menu.open();
                }


                QsMenuAnchor {
                  id: menu
                  menu: modelData.menu // qmllint disable
                  anchor {
                    item: icon
                    adjustment: PopupAdjustment.FlipX // qmllint disable
                    edges: Edges.Bottom | Edges.Left // qmllint disable
                    rect {
                      w: icon.width
                      h: icon.height + 4
                    }
                  }
                }

                Image {
                    id: icon

                    source: {
                        let icon = modelData.icon;
                        if (icon.includes("?path=")) {
                            const [name, path] = icon.split("?path=");
                            icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
                        }
                        return icon;
                    }
                    asynchronous: true
                    anchors.fill: parent
                }
            }
        }
    }
}
