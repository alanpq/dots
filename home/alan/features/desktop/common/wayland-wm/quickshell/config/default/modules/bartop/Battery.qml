import Quickshell.Services.UPower
import Quickshell
import Quickshell.Widgets
import QtQuick

import "root:/common"
import "root:/settings"

Section {
  property UPowerDevice battery: UPower.devices.values.find(d => d.isLaptopBattery) ?? null
  icon: battery === null ? "󱉝" : {
    [UPowerDeviceState.Charging]: ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"][Math.floor(10 * battery.percentage)],
    [UPowerDeviceState.Discharging]: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"][Math.floor(10 * battery.percentage)],
    [UPowerDeviceState.FullyCharged]: "󰁹",
    [UPowerDeviceState.Empty]: "󰂎",
    [UPowerDeviceState.PendingCharge]: "󰂐",
    [UPowerDeviceState.PendingDischarge]: "󰂍",
    [UPowerDeviceState.Unknown]: "󰂑"
  }[battery.state]
    text: battery === null ? "" : `${(100 * battery.percentage).toFixed(0)}%`
  tooltip: battery === null ? "" : `${{
    [UPowerDeviceState.Charging]: battery.changeRate === 0 ? "Battery is idle" : `Time until full: ${Time.humanDuration(battery.timeToFull)}
Charging rate: ${battery.changeRate.toFixed(2)}W`,
    [UPowerDeviceState.Discharging]: battery.changeRate === 0 ? "Battery is idle" : `Time left: ${Time.humanDuration(battery.timeToEmpty)}
Discharging rate: ${battery.changeRate.toFixed(2)}W`,
    [UPowerDeviceState.FullyCharged]: "Fully charged",
    [UPowerDeviceState.Empty]: "Battery is empty",
    [UPowerDeviceState.PendingCharge]: "Starting to charge",
    [UPowerDeviceState.PendingDischarge]: "Starting to discharge",
    [UPowerDeviceState.Unknown]: "Unknown battery state"
  }[battery.state]}
Health: ${battery.healthPercentage.toFixed(2)}%`
}
