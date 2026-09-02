import Quickshell
import QtQuick

// Reusable anchored floating surface for menus, tooltips, and dialogs. Wraps a
// PopupWindow: positions itself under `anchorItem` within `anchorWindow`, sizes
// to its content, and dismisses on outside click (grabFocus) or Escape.
// Content is supplied via the default property.
PopupWindow {
    id: root

    // Item the popup is positioned against, and the window that owns it.
    property Item anchorItem: null
    required property var anchorWindow

    // Gap between the anchor's bottom edge and the popup.
    property int margin: Style.gap

    // Surface styling.
    property color surfaceColor: Theme.surface
    property color borderColor: Theme.selection
    property int borderWidth: Style.popupBorderWidth
    property int radius: Style.sectionRadius

    default property alias content: body.data

    // Dismiss on click outside the popup. Requires the owning window to have
    // received input first (true for a popup opened from a click).
    property bool dismissOnOutsideClick: true

    color: "transparent"
    visible: false
    grabFocus: dismissOnOutsideClick

    implicitWidth: body.implicitWidth + 2 * borderWidth
    implicitHeight: body.implicitHeight + 2 * borderWidth

    // Top-left of the popup in anchorWindow content coordinates.
    readonly property point origin: (anchorItem && anchorWindow)
        ? anchorWindow.contentItem.mapFromItem(anchorItem, 0, anchorItem.height + margin)
        : Qt.point(0, 0)

    anchor.window: anchorWindow
    anchor.rect.x: Math.round(origin.x)
    anchor.rect.y: Math.round(origin.y)

    function open() {
        visible = true;
    }
    function close() {
        visible = false;
    }

    data: [
        Rectangle {
            anchors.fill: parent
            color: root.surfaceColor
            radius: root.radius
            border.color: root.borderColor
            border.width: root.borderWidth

            Item {
                id: body
                anchors.fill: parent
                anchors.margins: root.borderWidth
                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
            }
        },
        Item {
            // Keyboard dismissal; focusable only while the popup is shown.
            anchors.fill: parent
            focus: root.visible
            Keys.onEscapePressed: root.close()
        }
    ]
}
