import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Power menu (SUPER+ESCAPE). Same four entries as the fsel-driven
// powermenu.sh it replaces, no confirmation step. Type to filter, same as
// the launcher.
Item {
    id: root

    property bool opened: false
    property string query: ""

    readonly property var allEntries: [
        { label: "Suspend", icon: "󰤄", value: "suspend" },
        { label: "Reboot", icon: "󰜉", value: "reboot" },
        { label: "Shutdown", icon: "󰐥", value: "shutdown" },
        { label: "Exit Hyprland", icon: "󰍃", value: "exit" }
    ]

    readonly property var entries: {
        var q = query.toLowerCase()
        if (!q) return allEntries
        return allEntries.filter(function(e) { return e.label.toLowerCase().indexOf(q) >= 0 })
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
        switch (item.value) {
        case "suspend": Quickshell.execDetached(["systemctl", "suspend"]); break
        case "reboot": Quickshell.execDetached(["systemctl", "reboot"]); break
        case "shutdown": Quickshell.execDetached(["systemctl", "poweroff"]); break
        case "exit": Quickshell.execDetached(["hyprctl", "dispatch", "exit"]); break
        }
        close()
    }

    IpcHandler {
        target: "powermenu"
        function open(): string { root.open(); return "ok" }
        function close(): string { root.close(); return "ok" }
        function toggle(): string { root.toggle(); return "ok" }
    }

    PanelWindow {
        id: panel
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        WlrLayershell.namespace: "qs-powermenu"
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
