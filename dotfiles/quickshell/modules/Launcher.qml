import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "AppSearch.js" as AppSearch

// App launcher (SUPER+SPACE). DesktopEntries.applications fuzzy-filtered by
// AppSearch.js; launches via `uwsm app --` directly with the desktop id, same
// as fsel's launch_prefix did.
Item {
    id: root

    property bool opened: false
    property string query: ""
    property var entries: []
    property var usage: ({})

    FileView {
        id: usageFile
        path: Quickshell.env("HOME") + "/.local/state/quickshell/app-usage.json"
        printErrors: false
        onLoaded: {
            try {
                root.usage = JSON.parse(text())
            } catch (e) {
                root.usage = {}
            }
            root.refresh()
        }
        onLoadFailed: root.usage = {}
    }

    function recordLaunch(id) {
        var entry = usage[id] || { count: 0, last: 0 }
        usage[id] = { count: entry.count + 1, last: Date.now() }
        usageFile.setText(JSON.stringify(usage))
    }

    function refresh() {
        entries = AppSearch.filter(DesktopEntries.applications.values, root.query, root.usage)
    }

    onQueryChanged: refresh()

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { root.refresh() }
    }

    function open() {
        opened = true
        list.reset()
    }

    function close() {
        opened = false
        query = ""
        input.text = ""
        refresh()
    }

    function toggle() {
        opened ? close() : open()
    }

    function launch(entry) {
        Quickshell.execDetached(["uwsm", "app", "--", entry.id + ".desktop"])
        recordLaunch(entry.id)
        close()
    }

    IpcHandler {
        target: "launcher"
        function open(): string { root.open(); return "ok" }
        function close(): string { root.close(); return "ok" }
        function toggle(): string { root.toggle(); return "ok" }
    }

    PanelWindow {
        id: panel
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        WlrLayershell.namespace: "qs-launcher"
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
                width: 460
                height: 420
                anchors.centerIn: parent

                MouseArea {
                    anchors.fill: parent
                    // swallow clicks so they don't fall through to the scrim
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: Style.space(16)
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
                                if (root.entries.length > 0) root.launch(root.entries[0])
                            }
                        }
                    }

                    MenuList {
                        id: list
                        width: parent.width
                        height: parent.height - 52
                        visibleRows: 8
                        model: root.entries.map(function(e) {
                            return { label: e.name, icon: "", value: e.id, iconSource: Quickshell.iconPath(e.icon, true) }
                        })
                        onActivated: function(item) {
                            var entry = root.entries.filter(function(e) { return e.id === item.value })[0]
                            if (entry) root.launch(entry)
                        }
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
