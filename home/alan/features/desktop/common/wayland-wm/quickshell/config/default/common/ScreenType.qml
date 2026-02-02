pragma Singleton
import QtQuick
import Quickshell

Singleton {
  enum ScreenType {
    Laptop = 0,
    Primary = 1,
    Secondary = 2,
    Tertiary = 3,
    Unknown = 4
  }

  function get(screen: ShellScreen): int {
    return {
      "eDP-1": ScreenType.Laptop,
      "DP-1": ScreenType.Primary,
      "DP-2": ScreenType.Secondary,
      "DP-3": ScreenType.Tertiary
    }[screen.name] ?? ScreenType.Unknown
  }

  function isOnTop(screenType: int): bool {
    return {
      [ScreenType.Laptop]: true,
      [ScreenType.Primary]: true,
      [ScreenType.Secondary]: true,
      [ScreenType.Tertiary]: true,
      [ScreenType.Unknown]: true
    }[screenType]
  }
}
