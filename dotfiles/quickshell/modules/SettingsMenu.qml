import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "AppSearch.js" as AppSearch

// Settings menu (SUPER+ALT+SPACE). Entries with an appId open a tool in a
// floating window sized by the matching window rule in hyprland.lua. TUIs run as
// `foot --app-id=<appId> <cmd>`, so the terminal exits with the app.
// Picking an entry whose window already exists focuses it instead.
Item {
    id: root

    property bool opened: false
    property string query: ""

    readonly property var allEntries: [
        { label: "Network", icon: "󰤨", value: "network", keywords: "wifi ethernet vpn connection",
          appId: "nm-connection-editor", command: ["nm-connection-editor"] },
        { label: "Wi-Fi", icon: "󰖩", value: "wifi", keywords: "wireless network hotspot",
          appId: "tui.wlctl", command: ["foot", "--app-id=tui.wlctl", "wlctl"] },
        { label: "Bluetooth", icon: "󰂯", value: "bluetooth", keywords: "devices pair headphones",
          appId: "tui.bluetui", command: ["foot", "--app-id=tui.bluetui", "bluetui"] },
        { label: "Sound", icon: "󰕾", value: "sound", keywords: "audio volume mixer output input microphone",
          appId: "tui.wiremix", command: ["foot", "--app-id=tui.wiremix", "wiremix"] },
        { label: "Displays", icon: "󰍹", value: "displays", keywords: "monitors screens resolution scale workspaces",
          appId: "nwg-displays", command: ["nwg-displays"] },
        { label: "Night Light", icon: "󰖔", value: "nightlight", keywords: "hyprsunset blue light filter warm",
          command: [Quickshell.env("HOME") + "/.config/hypr/scripts/nightlight.sh"] }
    ]

    readonly property var entries: {
        if (!query) return allEntries
        var scored = []
        for (var i = 0; i < allEntries.length; i++) {
            var e = allEntries[i]
            var s = AppSearch.score({ name: e.label, genericName: e.keywords }, query)
            if (s >= 0) scored.push({ entry: e, score: s })
        }
        scored.sort(function(a, b) { return b.score - a.score })
        return scored.map(function(x) { return x.entry })
    }

    function open() {
        opened = true
        list.reset()
    }

    function close() {
        opened = false
        query = ""
        input.text = ""
    }

    function toggle() { opened ? close() : open() }

    function act(item) {
        if (!item.appId) {
            // one-shot script, not a session-scoped app
            Quickshell.execDetached(item.command)
        } else {
            var existing = ToplevelManager.toplevels.values.filter(function(t) { return t.appId === item.appId })[0]
            if (existing) existing.activate()
            else Quickshell.execDetached(["uwsm", "app", "--"].concat(item.command))
        }
        close()
    }

    IpcHandler {
        target: "settings"
        function open(): string { root.open(); return "ok" }
        function close(): string { root.close(); return "ok" }
        function toggle(): string { root.toggle(); return "ok" }
    }

    PanelWindow {
        id: panel
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        WlrLayershell.namespace: "qs-settings"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            color: Color.alpha("#000000", 0.35)

            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }

            Card {
                id: card
                width: 260
                height: 40 + Style.space(12) + list.implicitHeight + Style.space(24)
                anchors.centerIn: parent

                MouseArea {
                    anchors.fill: parent
                    // swallow clicks so they don't fall through to the scrim
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: Style.space(12)
                    spacing: Style.space(12)

                    Rectangle {
                        width: parent.width
                        height: 40
                        radius: Style.cornerRadius / 2
                        color: Color.alpha(Color.text, 0.08)

                        TextInput {
                            id: input
                            anchors.fill: parent
                            anchors.margins: Style.space(10)
                            font.family: Style.fontFamily
                            font.pixelSize: 15
                            color: Color.text
                            focus: true
                            clip: true
                            onTextChanged: root.query = text

                            Keys.onDownPressed: list.forceActiveFocus()
                            Keys.onUpPressed: list.forceActiveFocus()
                            Keys.onEscapePressed: root.close()
                            Keys.onReturnPressed: {
                                if (root.entries.length > 0) root.act(root.entries[0])
                            }
                        }
                    }

                    MenuList {
                        id: list
                        width: parent.width
                        model: root.entries
                        visibleRows: root.allEntries.length
                        onActivated: function(item) { root.act(item) }
                        onCancelled: root.close()
                        Keys.onUpPressed: if (currentIndex === 0) input.forceActiveFocus()
                    }
                }
            }
        }
    }

    onOpenedChanged: {
        if (opened) input.forceActiveFocus()
    }
}
