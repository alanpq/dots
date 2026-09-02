import Quickshell
import QtQuick

// A single free-floating box: sharp corners, sized to its content. Inset from
// the top by Style.gap and flush with the bottom edge so niri's own gap sets
// the spacing below the bar.
Rectangle {
    default property alias content: body.data

    color: Theme.surface
    radius: Style.sectionRadius
    height: parent.height - Style.gap
    anchors.bottom: parent.bottom
    implicitWidth: body.implicitWidth + 2 * Style.sectionHPad

    Row {
        id: body
        anchors.centerIn: parent
        spacing: Style.sectionSpacing
    }
}
