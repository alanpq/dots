// Entry point: one Bar per connected screen. Components and the Theme/Style
// singletons live alongside this file in the config/ folder.
// https://quickshell.org/docs/
import Quickshell
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            Bar {}
        }
    }
}
