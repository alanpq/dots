pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

// System notification handler and view. A single layer-shell overlay pinned to
// the top-left, just under the bar, showing each active notification as a
// sharp-cornered rectangular card. Cards auto-dismiss after a timeout and can
// be dismissed by clicking them.
PanelWindow {
    id: root

    // Freestanding overlay: span the top-left corner, click-through except over
    // the cards themselves (mask below). ExclusionMode.Ignore keeps the origin
    // at the true screen top so the bar offset is exact.
    anchors {
        top: true
        right: true
    }

    margins {
        top: Style.barHeight + Style.gap
        right: Style.gap
    }

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"

    // Only the cards receive input; the rest of the overlay is click-through.
    mask: Region {
        item: column
    }

    // Receives notifications over D-Bus. Marking each tracked keeps it in
    // trackedNotifications until dismissed or expired.
    NotificationServer {
        id: server
        keepOnReload: false
        actionsSupported: false
        bodySupported: true
        imageSupported: false

        onNotification: notification => {
            notification.tracked = true;
        }
    }

    Column {
        id: column

        width: Style.notifyWidth
        spacing: Style.gap

        Repeater {
            id: repeater
            model: server.trackedNotifications

            delegate: Rectangle {
                id: card
                required property var modelData

                width: parent.width
                height: cardBody.implicitHeight + (2 * Style.notifyPad)

                color: Theme.surface
                radius: 0

                // Rectangle {
                //     anchors.fill: parent
                //     anchors.margins: -1
                //     color: "transparent"
                // }
                border.color: card.modelData.urgency === NotificationUrgency.Critical ? Theme.yellow : "transparent"

                RowLayout {
                    id: cardRow

                    anchors {
                        fill: parent
                        margins: Style.notifyPad
                    }

                    spacing: card.modelData.image !== "" ? 12 : 0

                    Loader {
                        id: cardImg
                        active: card.modelData.image !== ""
                        sourceComponent: Image {
                            source: card.modelData.image

                            height: 40
                            width: source !== "" ? height : 0

                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    ColumnLayout {
                        id: cardBody

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop

                        spacing: 2

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(summaryText.implicitHeight, appNameText.implicitHeight)

                            Text {
                                id: appNameText
                                anchors.right: parent.right
                                text: card.modelData.appName
                                color: Theme.foreground
                                opacity: 0.6
                                font.family: Theme.monoFamily
                                font.pointSize: Theme.fontSize
                                wrapMode: Text.NoWrap
                            }

                            Text {
                                id: summaryText
                                anchors.left: parent.left
                                anchors.right: appNameText.left
                                anchors.rightMargin: Style.sectionSpacing
                                text: card.modelData.summary
                                color: card.modelData.urgency === NotificationUrgency.Critical ? Theme.green : Theme.foreground
                                font.family: Theme.monoFamily
                                font.pointSize: Theme.fontSize
                                font.bold: true
                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap
                            }
                        }

                        Text {
                            Layout.fillWidth: true

                            visible: card.modelData.body.length > 0
                            text: card.modelData.body

                            color: card.modelData.urgency === NotificationUrgency.Critical ? Theme.green : Theme.foreground
                            opacity: 0.8

                            font.family: Theme.monoFamily
                            font.pointSize: Theme.fontSize
                            textFormat: Text.PlainText
                            wrapMode: Text.WordWrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: card.modelData.dismiss()
                }

                Timer {
                    running: true
                    interval: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout : Style.notifyTimeout
                    onTriggered: card.modelData.expire()
                }
            }
        }
    }
}
