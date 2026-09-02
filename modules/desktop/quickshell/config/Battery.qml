import Quickshell
import Quickshell.Services.UPower
import QtQuick

// Right-cluster section: charge level of the laptop battery. Hidden entirely on
// machines without one (desktops), where UPower's display device is not a
// laptop battery.
Section {
    id: root

    readonly property var dev: UPower.displayDevice
    readonly property bool charging: root.dev && (root.dev.state === UPowerDeviceState.Charging || root.dev.state === UPowerDeviceState.FullyCharged || root.dev.state === UPowerDeviceState.PendingCharge)
    // percentage is a 0.0-1.0 fraction (energy / energyCapacity).
    readonly property int percent: root.dev ? Math.round(root.dev.percentage * 100) : 0

    // Nerd Font glyph: a bolt while charging, else a fill level by charge.
    readonly property string glyph: {
        if (root.charging)
            return "\uf0e7"; // nf-fa-bolt
        const p = root.percent;
        if (p >= 88)
            return "\uf240"; // battery_full
        if (p >= 63)
            return "\uf241"; // battery_three_quarters
        if (p >= 38)
            return "\uf242"; // battery_half
        if (p >= 13)
            return "\uf243"; // battery_quarter
        return "\uf244"; // battery_empty
    }

    visible: root.dev && root.dev.isLaptopBattery

    Text {
        anchors.verticalCenter: parent.verticalCenter
        color: (!root.charging && root.percent <= 15) ? Theme.red : Theme.foreground
        font.family: Theme.monoFamily
        font.pointSize: Theme.fontSize
        text: root.glyph + "  " + root.percent + "%"
    }
}
