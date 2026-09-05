pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Geometry mirrors whatever Hyprland is actually configured with, polled via
// `hyprctl -j getoption` rather than duplicated in this file. Re-polled after
// `hyprctl reload` (Hyprland.rawEvent "configreloaded") so `just theme` /
// editing hyprland.lua's rounding takes effect without restarting the shell.
Singleton {
    id: root

    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    property int cornerRadius: 12
    property int gapsOut: 10

    property int animationDuration: 140

    function space(n) { return n }

    Process {
        id: roundingProc
        command: ["hyprctl", "-j", "getoption", "decoration:rounding"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var parsed = JSON.parse(text)
                    if (typeof parsed.int === "number") root.cornerRadius = parsed.int
                } catch (e) {
                    // hyprctl missing / Hyprland not running: keep previous value.
                }
            }
        }
    }

    Process {
        id: gapsProc
        command: ["hyprctl", "-j", "getoption", "general:gaps_out"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var parsed = JSON.parse(text)
                    // gaps_out reports as css: "T R B L" (space-separated); halve
                    // the first value, matching hyprland.lua's own use of it.
                    var raw = String(parsed.css || "10 10 10 10")
                    var first = parseInt(raw.trim().split(/\s+/)[0], 10)
                    if (!isNaN(first)) root.gapsOut = Math.round(first / 2)
                } catch (e) {
                    // hyprctl missing / Hyprland not running: keep previous value.
                }
            }
        }
    }

    function refresh() {
        roundingProc.running = true
        gapsProc.running = true
    }

    Timer {
        id: settleTimer
        // Hyprland reports the *old* option value for a brief moment right
        // after "configreloaded" fires; give it a beat before re-polling.
        interval: 200
        onTriggered: root.refresh()
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded") settleTimer.restart()
        }
    }

    Component.onCompleted: refresh()
}
