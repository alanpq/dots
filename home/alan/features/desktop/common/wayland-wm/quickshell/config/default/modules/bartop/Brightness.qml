pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

import "root:/common"
import "root:/settings"

Section {
  id: root
  icon: "󰃠 "
  suffix: "%"
  property int brightness: -1
  property int step: 5
  text: brightness === -1 ? "" : brightness

  onWheelUp: {
    if (brightness === -1 || brightness === 100)
      return
    cmd.timer.stop()
    brightness += step
    for (const scope of variants.instances)
      scope.process.running = true
  }

  onWheelDown: {
    if (brightness === -1 || brightness === 0)
      return
    cmd.timer.stop()
    brightness -= step
    for (const scope of variants.instances)
      scope.process.running = true
  }

  Variants {
    id: variants
    model: []
    delegate: Scope {
      id: scope
      required property string modelData
      property alias process: process

      Process {
        id: process
        command: ["brightnessctl", "-md", scope.modelData, "set", `${root.brightness}%`]
        onRunningChanged: {
          for (const scope of variants.instances)
            if (scope.process.running)
              return
          cmd.timer.restart()
        }
      }
    }
  }

  RepeatedCommand {
    id: cmd
    command: ["brightnessctl", "-mlc", "backlight"]
    onFinished: output => {
      const devices = output.trim().split("\n").map(line => line.split(",")).map(([name, type, cur, _, max]) => ({
            name,
            pct: parseInt(cur) / parseInt(max)
          })).sort((a, b) => a.name.localeCompare(b.name))
      let pct = 0
      for (const d of devices)
        pct += d.pct
      pct /= devices.length
      root.brightness = Math.round(root.step * Math.round((100 / root.step) * pct))
      root.tooltip = devices.map(d => `${(100 * d.pct).toFixed(0)}%`).join(" | ")
      variants.model = devices.map(d => d.name)
      for (const name of devices.filter(d => Math.round(100 * d.pct) !== root.brightness).map(d => d.name)) {
        cmd.timer.stop()
        for (const scope of variants.instances)
          if (scope.modelData === name)
            scope.process.running = true
      }
    }
  }
}
