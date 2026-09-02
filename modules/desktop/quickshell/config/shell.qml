//@ pragma UseQApplication
import Quickshell
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            Bar {}
        }
    }

    Notifications {}
}
