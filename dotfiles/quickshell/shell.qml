import QtQuick
import Quickshell
import "modules" as Modules

// Entry point. Deliberately flat: no plugin registry, no bar, no persisted
// shell.json — just the four things asked for. See modules/ for each.
ShellRoot {
    Modules.Osd {}
    Modules.Notifications {}
    Modules.Launcher {}
    Modules.PowerMenu {}
}
