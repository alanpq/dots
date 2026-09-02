import Quickshell
import Quickshell.Wayland
import QtQuick

// Reusable anchored floating surface for menus, tooltips, and dialogs.
//
// A full-screen transparent layer-shell overlay that holds both the floating
// surface and a background dismiss catcher in one surface, so it dismisses on
// any outside click regardless of the compositor's popup-grab semantics (niri
// does not break an xdg_popup grab for clicks landing on the parent bar) with
// no z-order ambiguity.
//
// The overlay stays mapped and toggles its input region (`mask`) instead of its
// visibility: an empty mask is click-through when closed, and the whole window
// when open. Keeping the surface mapped means its input region is live before
// the cursor arrives, so a fast move to the menu still gets pointer-enter
// (hover). Toggling `visible` instead re-maps the surface each time and races
// the cursor: land on it before it is input-live and no enter/hover fires.
// Content is supplied via the default property.
PanelWindow {
    id: root

    // Item the popup is positioned against, and the window that owns it (used
    // only to pin the overlay to the correct screen).
    property Item anchorItem: null
    required property var anchorWindow

    // Gap between the anchor's bottom edge and the popup.
    property int margin: Style.gap

    // Dismiss on click outside the surface. When false the overlay still blocks
    // background input (modal) but stays open — useful for dialogs.
    property bool dismissOnOutsideClick: true

    // Surface styling.
    property color surfaceColor: Theme.surface
    property color borderColor: Theme.selection
    property int borderWidth: Style.popupBorderWidth
    property int radius: Style.sectionRadius

    default property alias content: body.data

    // Whether the popup is currently shown. Drives the input mask and content.
    property bool opened: false

    visible: true
    color: "transparent"
    screen: anchorWindow ? anchorWindow.screen : null

    // Span the whole output so the catcher covers every click on this screen,
    // including the bar strip. ExclusionMode.Ignore makes the overlay ignore
    // the bar's exclusive zone (otherwise it starts below the bar, shifting the
    // coordinate origin down and leaving the top strip unguarded).
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-popup"

    // Whole window interactive while open; empty (click-through) while closed.
    mask: Region {
        item: root.opened ? catcher : null
    }

    // Anchor top-left in overlay coordinates, resolved at open() time. Computed
    // imperatively rather than as a mapToItem binding, which does not re-run
    // when the anchor is laid out or moves.
    property real originX: 0
    property real originY: 0

    function open() {
        if (anchorItem) {
            const p = anchorItem.mapToItem(null, 0, anchorItem.height + margin);
            originX = p.x;
            originY = p.y;
        }
        opened = true;
    }
    function close() {
        opened = false;
    }

    data: [
        // Background dismiss catcher.
        MouseArea {
            id: catcher
            anchors.fill: parent
            visible: root.opened
            onPressed: if (root.dismissOnOutsideClick)
                root.close()
        },

        // Floating surface, clamped on-screen.
        Rectangle {
            id: surface

            visible: root.opened
            x: Math.round(Math.max(0, Math.min(root.originX, root.width - width)))
            y: Math.round(Math.max(0, Math.min(root.originY, root.height - height)))
            width: body.implicitWidth + 2 * root.borderWidth
            height: body.implicitHeight + 2 * root.borderWidth
            color: root.surfaceColor
            radius: root.radius
            border.color: root.borderColor
            border.width: root.borderWidth

            // Swallow clicks on the surface (padding, gaps) so they never reach
            // the catcher below; row interactions are handled by content on top.
            MouseArea {
                anchors.fill: parent
            }

            Item {
                id: body
                anchors.fill: parent
                anchors.margins: root.borderWidth
                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
            }
        },

        // Escape to dismiss (once the overlay has keyboard focus).
        Item {
            anchors.fill: parent
            focus: root.opened
            Keys.onEscapePressed: root.close()
        }
    ]
}
