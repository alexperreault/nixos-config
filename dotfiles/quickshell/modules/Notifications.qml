import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Commons
import "." as Modules

// Notification daemon: toasts only, top-right, no history/DND/persistence.
Item {
    id: root

    ListModel { id: popups }

    function timeoutFor(notification) {
        if (notification.urgency === NotificationUrgency.Critical) return 0
        if (notification.urgency === NotificationUrgency.Low) return 5000
        return 8000
    }

    function removeFor(notification) {
        for (var i = 0; i < popups.count; i++) {
            if (popups.get(i).notification === notification) {
                popups.remove(i)
                return
            }
        }
    }

    NotificationServer {
        imageSupported: true
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true

        onNotification: function(notification) {
            notification.tracked = true
            popups.insert(0, { notification: notification, timeout: root.timeoutFor(notification) })
            notification.closed.connect(function() { root.removeFor(notification) })
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors { top: true; right: true }
            implicitWidth: 360
            implicitHeight: screen.height
            color: "transparent"
            WlrLayershell.namespace: "qs-notifications"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            mask: Region { item: column }

            Column {
                id: column
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: Style.space(12)
                spacing: Style.space(8)

                Repeater {
                    model: popups

                    Modules.NotificationCard {
                        notification: model.notification
                        timeout: model.timeout
                        // dismiss() triggers the notification's closed signal,
                        // which the onNotification handler above already wires
                        // to removeFor() in the correctly-scoped context —
                        // calling it again from here hits a QML id-scoping
                        // quirk with Repeater delegates from imported files
                        // ("root is not defined").
                        onDismissed: model.notification.dismiss()
                    }
                }
            }
        }
    }
}
