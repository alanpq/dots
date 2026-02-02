import Quickshell

import "root:/common"
import "root:/settings"

Section {
  id: root
  icon: "󰈀"
  monoTooltip: true
  onLeftClick: Quickshell.execDetached(["alacritty", "-e", "nmtui"])
  RepeatedCommand {
    command: ["nmcli", "--fields", ["name", "type", "device", "active"].join(","), "connection", "show"]
    onFinished: output => {
      const txt = output.trim()
      root.tooltip = txt
      const [_, ...lines] = txt.split("\n").map(line => line.trim().split(/\s+/))
      const activeLines = lines.filter(([name, type, device, active]) => active === "yes")
      const ethernet = activeLines.find(([name, type, device, active]) => type === "ethernet")
      const wifi = activeLines.find(([name, type, device, active]) => type === "wifi")
      if (ethernet) {
        root.icon = "󰈀"
        root.text = ""
      } else if (wifi) {
        root.icon = " "
        root.text = wifi[0]
      } else {
        root.icon = ""
      }
    }
  }
}
