pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

// Renders a Qs/DBus menu tree (any QsMenuHandle, e.g. SystemTrayItem.menu) as
// an interactive list. Submenus expand inline, indented, within the same
// window. Emits closeRequested when a leaf entry is activated so the containing
// popup can dismiss. Reusable for any menu handle.
Column {
    id: root

    // A QsMenuHandle. Left null when collapsed so the opener does not ref (and
    // the app is not asked to populate) menus that aren't shown.
    property var handle: null
    // Nesting depth; drives row indentation.
    property int depth: 0

    signal closeRequested

    spacing: 0
    width: maxContentWidth

    // Widest row content across entries and any visible submenu, so the menu
    // fits its contents without a width binding cycle (row widths derive from
    // this, not the other way around).
    property real maxContentWidth: Style.menuMinWidth
    function recompute() {
        let w = Style.menuMinWidth;
        for (let i = 0; i < rep.count; i++) {
            const it = rep.itemAt(i);
            if (it)
                w = Math.max(w, it.desiredWidth);
        }
        maxContentWidth = w;
    }

    QsMenuOpener {
        id: opener
        menu: root.handle
    }

    Repeater {
        id: rep
        model: opener.children
        onCountChanged: root.recompute()

        delegate: Column {
            id: entry

            required property var modelData
            property bool expanded: false

            // Content width this entry wants: its own row, or the widest
            // visible descendant. Independent of root.width -> no cycle.
            readonly property real ownWidth: modelData.isSeparator
                ? 0
                : Style.menuRowHPad + root.depth * Style.menuIndent + rowContent.implicitWidth
                    + Style.menuRowHPad + (modelData.hasChildren ? Style.menuRowSpacing + arrow.implicitWidth : 0)
            readonly property real desiredWidth: Math.max(ownWidth, (submenu.item && submenu.visible) ? submenu.item.maxContentWidth : 0)
            onDesiredWidthChanged: root.recompute()

            width: root.width

            // Separator.
            Item {
                width: parent.width
                visible: entry.modelData.isSeparator
                height: visible ? Style.menuSeparatorMargin * 2 + 1 : 0

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 2 * Style.menuRowHPad
                    height: 1
                    color: Theme.selection
                }
            }

            // Row.
            Rectangle {
                id: rowBg

                width: parent.width
                visible: !entry.modelData.isSeparator
                implicitHeight: visible ? rowContent.implicitHeight + 2 * Style.menuRowVPad : 0
                height: implicitHeight
                color: (rowMouse.containsMouse && entry.modelData.enabled) ? Theme.selection : "transparent"

                Row {
                    id: rowContent

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Style.menuRowHPad + root.depth * Style.menuIndent
                    spacing: Style.menuRowSpacing

                    // Checkbox / radio indicator.
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: entry.modelData.buttonType !== QsMenuButtonType.None
                        width: visible ? implicitWidth : 0
                        color: Theme.foreground
                        opacity: entry.modelData.enabled ? 1.0 : 0.4
                        font.family: Theme.monoFamily
                        font.pointSize: Theme.fontSize
                        text: {
                            if (entry.modelData.buttonType === QsMenuButtonType.CheckBox)
                                return entry.modelData.checkState === Qt.Checked ? "\u2611" : "\u2610";
                            if (entry.modelData.buttonType === QsMenuButtonType.RadioButton)
                                return entry.modelData.checkState === Qt.Checked ? "\u25C9" : "\u25CB";
                            return "";
                        }
                    }

                    // Icon.
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: entry.modelData.icon !== ""
                        width: visible ? Style.menuIconSize : 0
                        height: Style.menuIconSize
                        source: entry.modelData.icon
                        sourceSize.width: Style.menuIconSize
                        sourceSize.height: Style.menuIconSize
                        fillMode: Image.PreserveAspectFit
                    }

                    // Label.
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.foreground
                        opacity: entry.modelData.enabled ? 1.0 : 0.4
                        font.family: Theme.monoFamily
                        font.pointSize: Theme.fontSize
                        text: entry.modelData.text
                    }
                }

                // Submenu arrow, pinned right.
                Text {
                    id: arrow

                    anchors.right: parent.right
                    anchors.rightMargin: Style.menuRowHPad
                    anchors.verticalCenter: parent.verticalCenter
                    visible: entry.modelData.hasChildren
                    color: Theme.foreground
                    opacity: entry.modelData.enabled ? 1.0 : 0.4
                    font.family: Theme.monoFamily
                    font.pointSize: Theme.fontSize
                    text: entry.expanded ? "\u2304" : "\u203A"
                }

                MouseArea {
                    id: rowMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: entry.modelData.enabled && !entry.modelData.isSeparator
                    onClicked: {
                        if (entry.modelData.hasChildren) {
                            entry.expanded = !entry.expanded;
                        } else {
                            entry.modelData.triggered();
                            root.closeRequested();
                        }
                    }
                }
            }

            // Inline submenu; loaded by URL (not by type) to avoid QML's static
            // self-recursion check, and only while expanded so the handle is
            // refd lazily.
            Loader {
                id: submenu

                width: root.width
                active: entry.expanded && entry.modelData.hasChildren
                visible: active
                source: "MenuView.qml"

                onLoaded: {
                    item.handle = Qt.binding(() => entry.modelData);
                    item.depth = root.depth + 1;
                }

                Connections {
                    target: submenu.item
                    function onCloseRequested() {
                        root.closeRequested();
                    }
                }
            }
        }
    }
}
