pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

// Right-cluster section: a fixed toggle pinned to the right edge; the tray
// icons live in a clipped strip to its left that animates open, so they slide
// out from behind the toggle. Hidden when there are no tray items.
Section {
    id: root

    // The bar window, needed to anchor tray item menus.
    required property var panelWindow

    // Populated on right-click; drive the shared menu popup below.
    property var menuHandle: null
    property Item menuAnchor: null

    visible: SystemTray.items.values.length > 0

    Item {
        id: tray
        property bool expanded: false

        implicitHeight: Style.trayIconSize
        implicitWidth: btn.width + reveal.width

        Item {
            id: reveal
            anchors.right: btn.left
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            clip: true
            width: tray.expanded ? (iconsRow.implicitWidth + Style.traySlotGap) : 0

            Behavior on width {
                NumberAnimation {
                    duration: Style.trayExpandDuration
                    easing.type: Easing.OutCubic
                }
            }

            // Anchored to the strip's right (the toggle edge) so the clip
            // uncovers it leftward.
            Row {
                id: iconsRow
                anchors.right: parent.right
                anchors.rightMargin: Style.traySlotGap
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.traySlotGap

                Repeater {
                    model: SystemTray.items

                    delegate: Item {
                        id: iconRoot
                        required property var modelData
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: Style.trayIconSize
                        implicitHeight: Style.trayIconSize

                        // Some SNIs advertise a themed icon name absent from
                        // the active icon theme (e.g. KDE Connect's
                        // "kdeconnectindicatordark"); quickshell then renders a
                        // magenta placeholder rather than erroring, so detect
                        // the miss up front and substitute a Nerd Font glyph.
                        // Icons provided by an explicit path or a pixmap are
                        // trusted as-is.
                        readonly property bool iconMissing: {
                            const prefix = "image://icon/";
                            const raw = "" + iconRoot.modelData.icon;
                            if (!raw.startsWith(prefix))
                                return raw.length === 0;
                            if (raw.includes("?path="))
                                return false;
                            return !Quickshell.hasThemeIcon(raw.slice(prefix.length).split("?")[0]);
                        }

                        // Glyph keyed by id/title substring; generic otherwise.
                        readonly property string fallbackGlyph: {
                            const key = ((iconRoot.modelData.id || "") + " " + (iconRoot.modelData.title || "")).toLowerCase();
                            if (key.includes("kdeconnect") || key.includes("kde connect"))
                                return "\uf10b"; // nf-fa-mobile
                            return "\uf059"; // nf-fa-question_circle
                        }

                        Image {
                            anchors.fill: parent
                            visible: !iconRoot.iconMissing
                            source: visible ? iconRoot.modelData.icon : ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: iconRoot.iconMissing
                            text: iconRoot.fallbackGlyph
                            color: Theme.foreground
                            font.family: Theme.monoFamily
                            font.pixelSize: Style.trayIconSize
                        }

                        MouseArea {
                            id: trayMouse
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton)
                                    iconRoot.modelData.activate();
                                else if (mouse.button === Qt.MiddleButton)
                                    iconRoot.modelData.secondaryActivate();
                                else if (mouse.button === Qt.RightButton && iconRoot.modelData.hasMenu) {
                                    root.menuHandle = iconRoot.modelData.menu;
                                    root.menuAnchor = iconRoot;
                                    trayMenu.open();
                                }
                            }
                        }
                    }
                }
            }
        }

        // Drawn last / z:1 so icons pass behind it.
        Text {
            id: btn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            z: 1
            color: Theme.foreground
            font.family: Theme.monoFamily
            font.pointSize: Theme.fontSize + Style.trayToggleFontBump
            font.bold: true
            text: tray.expanded ? "\u00BB" : "\u00AB"

            MouseArea {
                anchors.fill: parent
                onClicked: tray.expanded = !tray.expanded
            }
        }
    }

    Popup {
        id: trayMenu
        anchorWindow: root.panelWindow
        anchorItem: root.menuAnchor

        MenuView {
            handle: root.menuHandle
            onCloseRequested: trayMenu.close()
        }
    }
}
