pragma Singleton
import Quickshell
import QtQuick

// Static design tokens: spacing, sizes, radii, and animation timings.
// Colors and fonts live in the generated Theme singleton.
Singleton {
    // Bar geometry.
    readonly property int barHeight: 34
    readonly property int gap: 6

    // Section box.
    readonly property int sectionHPad: 10
    readonly property int sectionRadius: 0
    readonly property int sectionSpacing: 6

    // Tray.
    readonly property int trayIconSize: 20
    readonly property int traySlotGap: 6
    readonly property int trayExpandDuration: 180
    readonly property int trayToggleFontBump: 5

    // Media.
    readonly property int mediaMaxWidth: 320

    // Calendar.
    readonly property int calTitleMaxWidth: 160
    readonly property int calPopupPad: 12
    readonly property int calAgendaSpacing: 6
    readonly property int calAgendaColGap: 12
    readonly property int calTimeWidth: 56
    readonly property int calAgendaTitleMaxWidth: 280
    // Agenda list rows (clickable).
    readonly property int calListWidth: 300
    readonly property int calRowHPad: 12
    readonly property int calRowVPad: 5
    // Event detail sidebar.
    readonly property int calDetailWidth: 340
    readonly property int calDetailSpacing: 8
    readonly property int calDetailGlyphW: 18
    readonly property int calDetailRowGap: 8
    readonly property int calDetailDescMaxLines: 10
    readonly property int calSlideDuration: 180
    readonly property int calDetailBtnPadY: 5
    readonly property int calDetailBtnSpacing: 2

    // Notifications.
    readonly property int notifyWidth: 360
    readonly property int notifyPad: 10
    readonly property int notifyTimeout: 5000

    // Popup surface (menus, dialogs).
    readonly property int popupBorderWidth: 1

    // Menu.
    readonly property int menuMinWidth: 180
    readonly property int menuRowHPad: 12
    readonly property int menuRowVPad: 6
    readonly property int menuRowSpacing: 8
    readonly property int menuSeparatorMargin: 4
    readonly property int menuIconSize: 16
    readonly property int menuIndent: 14

    // Volume popup.
    readonly property int volPopupPad: 10
    readonly property int volSliderSpacing: 10
    readonly property int volRowSpacing: 10
    readonly property int volIconWidth: 20
    readonly property int volSliderWidth: 150
    readonly property int volSliderHeight: 4
    readonly property int volKnobSize: 12
    readonly property int volPctWidth: 44

    // Output-device dropdown at the bottom of the volume popup. Width matches a
    // slider row so the surface keeps one width.
    readonly property int volRowWidth: volIconWidth + 2 * volRowSpacing + volSliderWidth + volPctWidth
    readonly property int volSelectorSpacing: 8
    readonly property int volSelectorRowVPad: 6
}
