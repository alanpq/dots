import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick

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
    implicitWidth: Style.notifyWidth + 2 * Style.gap
    implicitHeight: Math.max(1, column.implicitHeight + Style.barHeight + 2 * Style.gap)
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
        x: Style.gap
        y: Style.barHeight + Style.gap
        width: Style.notifyWidth
        spacing: Style.gap

        Repeater {
            model: server.trackedNotifications

            delegate: Rectangle {
                id: card
                required property var modelData

                readonly property color textColor: card.modelData.urgency === NotificationUrgency.Critical ? "#3a1818" : Theme.accent

                width: parent.width
                implicitHeight: cardBody.implicitHeight + 2 * Style.notifyPad
                color: card.modelData.urgency === NotificationUrgency.Critical ? Theme.yellow : Theme.surface
                radius: 0

                // Urgency accent stripe down the left edge.
                // Rectangle {
                //     width: 3
                //     height: parent.height
                //     color: card.modelData.urgency === NotificationUrgency.Critical ? Theme.red : Theme.accent
                // }
                //
                Text {
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: Style.notifyPad
                    verticalAlignment: Text.AlignVCenter

                    text: card.modelData.urgency === NotificationUrgency.Critical ? "\uf071" : "\uf05a"
                    color: card.modelData.urgency === NotificationUrgency.Critical ? "#3a1818" : Theme.accent
                }

                Column {
                    id: cardBody
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: Style.notifyPad * 2 + 13
                    anchors.rightMargin: Style.notifyPad
                    anchors.topMargin: Style.notifyPad
                    spacing: 2

                    Item {
                        width: parent.width
                        height: Math.max(summaryText.implicitHeight, appNameText.implicitHeight)

                        Text {
                            id: appNameText
                            anchors.right: parent.right
                            text: card.modelData.appName
                            color: card.textColor
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
                            color: card.textColor
                            font.family: Theme.monoFamily
                            font.pointSize: Theme.fontSize
                            font.bold: true
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                        }
                    }

                    Text {
                        width: parent.width
                        visible: card.modelData.body.length > 0
                        text: card.modelData.body
                        color: card.textColor
                        opacity: 0.8
                        font.family: Theme.monoFamily
                        font.pointSize: Theme.fontSize
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                    }
                }

                // Click to dismiss.
                MouseArea {
                    anchors.fill: parent
                    onClicked: card.modelData.dismiss()
                }

                // Auto-dismiss. Respect the app's expireTimeout when positive,
                // otherwise fall back to the default.
                Timer {
                    running: true
                    interval: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout : Style.notifyTimeout
                    onTriggered: card.modelData.expire()
                }
            }
        }
    }
}
