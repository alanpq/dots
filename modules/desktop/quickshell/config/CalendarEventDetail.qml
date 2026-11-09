pragma ComponentBehavior: Bound
import QtQuick

// Detail sidebar body for a single calendar event: title, time range, location,
// calendar, description, and (when present) clickable links to join the video
// call or open the event in a browser. Fed a normalised event object (see
// calendar-fetch.py) by CalendarAgenda when a row is selected.
Column {
    id: root

    // The selected event, or null (the pane is only instantiated when set).
    property var event: null

    // Content width available to a field after the column's horizontal padding.
    readonly property real availWidth: Style.calDetailWidth - 2 * Style.calPopupPad

    function timeRange(e) {
        if (!e)
            return "";
        if (e.allDay)
            return "All day";
        return Qt.formatDateTime(new Date(e.start), "HH:mm") + " \u2013 " + Qt.formatDateTime(new Date(e.end), "HH:mm");
    }
    function dateLabel(e) {
        return e ? Qt.formatDateTime(new Date(e.start), "ddd, d MMM") : "";
    }
    function whenText(e) {
        if (!e)
            return "";
        return e.allDay ? root.dateLabel(e) : root.timeRange(e) + "  \u00B7  " + root.dateLabel(e);
    }
    // gcalcli escapes newlines as literal "\n" in its TSV; restore them.
    function restoreNewlines(s) {
        return s ? String(s).replace(/\\n/g, "\n") : "";
    }

    width: Style.calDetailWidth
    padding: Style.calPopupPad
    spacing: Style.calDetailSpacing

    // Icon + value row. A non-empty url makes the row a clickable button that
    // highlights on hover.
    component Field: Item {
        id: field
        property string glyph: ""
        property string value: ""
        property color tint: Theme.muted
        property string url: ""
        property int maxLines: 0

        readonly property bool isLink: url !== ""
        // Link rows keep vertical padding; the hover highlight bleeds out into
        // the sidebar's own horizontal padding (bgMargin) so it reaches the pane
        // edges while the icon/text stay aligned with the info rows above.
        readonly property int padY: isLink ? Style.calDetailBtnPadY : 0
        readonly property int bgMargin: isLink ? Style.calPopupPad : 0

        width: root.availWidth
        implicitHeight: Math.max(icon.implicitHeight, text.implicitHeight) + 2 * padY
        visible: value !== ""

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: -field.bgMargin
            anchors.rightMargin: -field.bgMargin
            visible: field.isLink
            color: linkMouse.containsMouse ? Theme.selection : "transparent"
        }

        Text {
            id: icon
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: field.padY
            width: Style.calDetailGlyphW
            color: field.tint
            font.family: Theme.monoFamily
            font.pointSize: Theme.fontSize
            text: field.glyph
        }

        Text {
            id: text
            anchors.left: icon.right
            anchors.leftMargin: Style.calDetailRowGap
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: field.padY
            wrapMode: Text.Wrap
            maximumLineCount: field.maxLines > 0 ? field.maxLines : 2147483647
            elide: field.maxLines > 0 ? Text.ElideRight : Text.ElideNone
            color: field.isLink ? Theme.accent : Theme.foreground
            // Links embedded in rich-text (e.g. description HTML) match our link fields.
            linkColor: Theme.accent
            font.family: Theme.monoFamily
            font.pointSize: Theme.fontSize
            text: field.value
        }

        MouseArea {
            id: linkMouse
            anchors.fill: parent
            anchors.leftMargin: -field.bgMargin
            anchors.rightMargin: -field.bgMargin
            visible: field.isLink
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally(field.url)
        }
    }

    // Title.
    Text {
        width: root.availWidth
        wrapMode: Text.Wrap
        color: Theme.foreground
        font.family: Theme.monoFamily
        font.pointSize: Theme.fontSize
        font.bold: true
        text: root.event ? root.event.title : ""
    }

    Field {
        glyph: "\uf017" // clock
        tint: Theme.accent
        value: root.whenText(root.event)
    }

    Field {
        glyph: "\uf3c5" // map marker
        value: root.event ? (root.event.location || "") : ""
    }

    Field {
        glyph: "\uf073" // calendar
        value: root.event ? (root.event.calendar || root.event.account || "") : ""
    }

    Field {
        glyph: "\uf036" // align-left
        maxLines: Style.calDetailDescMaxLines
        value: root.event ? root.restoreNewlines(root.event.description) : ""
    }

    // Action buttons, grouped so they sit tight against each other (their own
    // spacing) while the normal field spacing separates them from the details
    // above. Each button's breathing room lives in its inner padding (padY), so
    // the hover highlight reads as a proper button.
    Column {
        width: root.availWidth
        spacing: Style.calDetailBtnSpacing
        visible: (root.event && (root.event.conference_uri || root.event.link)) ? true : false

        Field {
            glyph: "\uf03d" // video
            tint: Theme.accent
            value: (root.event && root.event.conference_uri) ? "Join video call" : ""
            url: root.event ? (root.event.conference_uri || "") : ""
        }

        Field {
            glyph: "\uf0c1" // link
            tint: Theme.accent
            value: (root.event && root.event.link) ? "Open in browser" : ""
            url: root.event ? (root.event.link || "") : ""
        }
    }
}
