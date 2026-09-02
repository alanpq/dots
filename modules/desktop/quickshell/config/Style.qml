pragma Singleton
import Quickshell
import QtQuick

// Static design tokens: spacing, sizes, radii, and animation timings.
// Colors and fonts live in the stylix-generated Theme singleton.
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
}
