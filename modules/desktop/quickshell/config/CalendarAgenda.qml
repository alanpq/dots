pragma ComponentBehavior: Bound
import QtQuick

// Calendar dropdown body: a two-pane surface. The left pane lists the whole
// day's events (one clickable row each; past events dimmed). Clicking a row
// reveals the right-hand detail sidebar (CalendarEventDetail) for that event;
// clicking it again hides the sidebar. The source account is shown per row only
// when more than one account contributes events today.
Row {
    id: root

    // Today's events, start-sorted (Calendar.agenda).
    property var events: []

    // The event whose detail sidebar is open, or null. Reset whenever the list
    // is refreshed so a stale object can't linger in the sidebar.
    property var selected: null
    onEventsChanged: selected = null

    // The event the detail pane renders. Tracks `selected` but is NOT cleared on
    // deselect, so the pane keeps its content while it slides shut.
    property var shown: null
    onSelectedChanged: if (selected !== null)
        shown = selected

    // Only disambiguate accounts when several contribute today.
    readonly property bool showAccounts: {
        const seen = {};
        for (const e of root.events)
            seen[e.account] = true;
        return Object.keys(seen).length > 1;
    }

    spacing: 0

    // LEFT: the day's agenda, one clickable row per event.
    Column {
        id: list
        width: Style.calListWidth
        topPadding: Style.calPopupPad
        bottomPadding: Style.calPopupPad
        spacing: Style.calAgendaSpacing

        // Header: today's date.
        Text {
            leftPadding: Style.calRowHPad
            rightPadding: Style.calRowHPad
            color: Theme.muted
            font.family: Theme.monoFamily
            font.pointSize: Theme.fontSize
            text: Qt.formatDateTime(new Date(), "dddd, d MMMM")
        }

        Repeater {
            model: root.events

            delegate: Rectangle {
                id: rowBg
                required property var modelData

                readonly property bool past: Date.parse(modelData.end) <= Date.now()

                width: list.width
                implicitHeight: Math.max(time.implicitHeight, title.implicitHeight) + 2 * Style.calRowVPad
                color: (rowMouse.containsMouse || root.selected === modelData) ? Theme.selection : "transparent"

                // Time column — fixed width so titles align.
                Text {
                    id: time
                    anchors.left: parent.left
                    anchors.leftMargin: Style.calRowHPad
                    anchors.verticalCenter: parent.verticalCenter
                    width: Style.calTimeWidth
                    color: rowBg.past ? Theme.muted : Theme.accent
                    font.family: Theme.monoFamily
                    font.pointSize: Theme.fontSize
                    text: rowBg.modelData.allDay ? "all day" : Qt.formatDateTime(new Date(rowBg.modelData.start), "HH:mm")
                }

                // Source account, pinned right, only with several accounts today.
                Text {
                    id: account
                    visible: root.showAccounts
                    anchors.right: parent.right
                    anchors.rightMargin: Style.calRowHPad
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.muted
                    font.family: Theme.monoFamily
                    font.pointSize: Theme.fontSize
                    text: rowBg.modelData.account
                }

                // Title fills the gap between time and account, elided.
                Text {
                    id: title
                    anchors.left: time.right
                    anchors.leftMargin: Style.calAgendaColGap
                    anchors.right: account.visible ? account.left : parent.right
                    anchors.rightMargin: account.visible ? Style.calAgendaColGap : Style.calRowHPad
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    color: rowBg.past ? Theme.muted : Theme.foreground
                    font.family: Theme.monoFamily
                    font.pointSize: Theme.fontSize
                    text: rowBg.modelData.title
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    // Toggle: re-selecting the open event closes the sidebar.
                    onClicked: root.selected = (root.selected === rowBg.modelData ? null : rowBg.modelData)
                }
            }
        }
    }

    // RIGHT: detail sidebar. A clipped slot whose width animates between 0 and
    // the pane's natural width, so the pane appears to slide out from behind the
    // list and retract back underneath it. `shown` keeps the content alive for
    // the duration of the closing slide. Height follows width>0 so the popup
    // only collapses vertically once the slide has finished.
    Item {
        id: slot
        clip: true
        width: root.selected !== null ? body.implicitWidth : 0
        height: width > 0 ? body.implicitHeight : 0

        Behavior on width {
            NumberAnimation {
                duration: Style.calSlideDuration
                easing.type: Easing.OutCubic
            }
        }

        Row {
            id: body
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 0

            Rectangle {
                width: Style.popupBorderWidth
                height: detail.implicitHeight
                color: Theme.selection
            }

            CalendarEventDetail {
                id: detail
                event: root.shown
            }
        }
    }
}
