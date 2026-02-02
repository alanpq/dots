pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland

import "root:/common"
import "root:/settings"

Section {
  id: root
  horizontalMargin: 0
  spacing: 0
  clickable: false
  readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)

  Repeater {
    model: ScriptModel {
      objectProp: "id"
      values: Hyprland.workspaces.values.filter(ws => ws.monitor === monitor).sort((a,b) => a.name.localeCompare(b.name))
    }
    delegate: Section {
      id: item
      screen: root.screen
      required property HyprlandWorkspace modelData
      readonly property list<HyprlandToplevel> toplevels: modelData?.toplevels?.values ?? []
      text: modelData?.name ?? "?"
      tooltip: toplevels.length === 0 ? "No Windows" : `${toplevels.length} Window${toplevels.length === 1 ? "" : "s"}:
${toplevels.map(w => w.lastIpcObject).filter(w => w !== null).map(w => `${w.title} [${w.class}]`).join("\n")}`
      tooltipDelay: Style.workspacesTooltipDelay
      txt.active: modelData?.active || toplevels.length > 0
      onLeftClick: {
        if (Hyprland.focusedWorkspace !== modelData)
          modelData.activate()
      }
      clickable: true
      horizontalMargin: modelData === Hyprland.focusedWorkspace ? 10 : 10
      rect.color: modelData?.urgent ? Style.workspacesUrgentColor : modelData === Hyprland.focusedWorkspace ? Style.workspacesFocusedColor : modelData?.active ? Style.workspacesActiveColor : Style.transparent

      Behavior on horizontalMargin {
        NumberAnimation {
          duration: Style.workspacesAnimationSpeed
        }
      }
    }
  }
}
