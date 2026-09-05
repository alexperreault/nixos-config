import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import qs.Commons
import qs.Ui

// Reactive OSD: watches Pipewire's default sink and the active MPRIS player
// directly, rather than waiting for a keybind script to push an IPC call.
// This means the OSD also appears when volume changes from wiremix or an
// app, not only from the hardware keys.
Item {
    id: root

    property bool opened: false
    property string icon: ""
    property string message: ""
    property bool hasProgress: false
    property real value: 0
    property real maxValue: 100

    // Suppresses the flash that would otherwise fire once at startup, when
    // Pipewire/Mpris properties first settle to their initial values.
    property bool ready: false

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var activePlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    Timer {
        interval: 400
        running: true
        onTriggered: root.ready = true
    }

    function iconFor(kind) {
        switch (kind) {
        case "volume-muted": return "󰝟"
        case "volume-low": return "󰕿"
        case "volume-medium": return "󰖀"
        case "volume-high": return "󰕾"
        case "media-play": return "󰐊"
        case "media-pause": return "󰏤"
        default: return ""
        }
    }

    function show(iconKey, msg, hasProg, val, maxVal) {
        icon = iconFor(iconKey)
        message = msg || ""
        hasProgress = !!hasProg
        value = val || 0
        maxValue = maxVal || 100
        opened = true
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 1400
        onTriggered: root.opened = false
    }

    Connections {
        target: root.sink && root.sink.audio ? root.sink.audio : null
        function onVolumeChanged() {
            if (!root.ready || !root.sink || !root.sink.audio) return
            if (root.sink.audio.muted) return
            var pct = Math.round(root.sink.audio.volume * 100)
            var key = pct <= 0 ? "volume-muted" : (pct <= 33 ? "volume-low" : (pct <= 66 ? "volume-medium" : "volume-high"))
            root.show(key, pct + "%", true, pct, 100)
        }
        function onMutedChanged() {
            if (!root.ready || !root.sink || !root.sink.audio) return
            if (root.sink.audio.muted) {
                root.show("volume-muted", "Muted", false, 0, 100)
            } else {
                var pct = Math.round(root.sink.audio.volume * 100)
                var key = pct <= 33 ? "volume-low" : (pct <= 66 ? "volume-medium" : "volume-high")
                root.show(key, pct + "%", true, pct, 100)
            }
        }
    }

    Connections {
        target: root.activePlayer
        function onPlaybackStateChanged() {
            if (!root.ready || !root.activePlayer) return
            var playing = root.activePlayer.playbackState === MprisPlaybackState.Playing
            root.show(playing ? "media-play" : "media-pause", root.activePlayer.trackTitle || "", false, 0, 100)
        }
    }

    PanelWindow {
        id: panel
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        WlrLayershell.namespace: "qs-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}

        Card {
            id: card
            width: 260
            height: 64
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.space(60)
            opacity: root.opened ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: Style.animationDuration }
            }

            Row {
                anchors.fill: parent
                anchors.margins: Style.space(16)
                spacing: Style.space(14)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.icon
                    font.family: Style.fontFamily
                    font.pixelSize: 22
                    color: Color.text
                }

                Rectangle {
                    visible: root.hasProgress
                    width: 130
                    height: 6
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 3
                    color: Color.alpha(Color.text, 0.25)

                    Rectangle {
                        height: parent.height
                        radius: parent.radius
                        width: parent.width * (root.maxValue > 0 ? root.value / root.maxValue : 0)
                        color: Color.accent

                        Behavior on width {
                            NumberAnimation { duration: Style.animationDuration }
                        }
                    }
                }

                Text {
                    visible: !root.hasProgress && root.message !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    width: 100
                    text: root.message
                    elide: Text.ElideRight
                    font.family: Style.fontFamily
                    font.pixelSize: 14
                    color: Color.text
                }

                Text {
                    visible: root.hasProgress
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(root.value) + "%"
                    font.family: Style.fontFamily
                    font.pixelSize: 14
                    color: Color.text
                }
            }
        }
    }
}
