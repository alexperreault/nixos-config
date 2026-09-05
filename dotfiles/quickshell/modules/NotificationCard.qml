import QtQuick
import qs.Commons
import qs.Ui

// One notification toast. Left-click invokes the default action (if any) and
// dismisses; right-click just dismisses. Self-expires after `timeout` ms
// (0 = never, used for critical urgency).
Card {
    id: root

    property var notification: null
    property int timeout: 8000

    width: 340
    implicitHeight: content.implicitHeight + Style.space(24)

    signal dismissed()

    Timer {
        interval: root.timeout
        running: root.timeout > 0
        onTriggered: root.dismissed()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton && root.notification && root.notification.actions.length > 0) {
                root.notification.actions[0].invoke()
            }
            root.dismissed()
        }
    }

    Row {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Style.space(12)
        spacing: Style.space(12)

        Image {
            visible: root.notification && root.notification.image !== ""
            source: root.notification ? root.notification.image : ""
            width: 40
            height: 40
            fillMode: Image.PreserveAspectCrop
        }

        Column {
            width: parent.width - (root.notification && root.notification.image !== "" ? 52 : 0)
            spacing: Style.space(4)

            Text {
                width: parent.width
                text: root.notification ? root.notification.summary : ""
                font.family: Style.fontFamily
                font.bold: true
                font.pixelSize: 14
                color: Color.text
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.notification ? root.notification.body : ""
                font.family: Style.fontFamily
                font.pixelSize: 13
                color: Color.alpha(Color.text, 0.85)
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }
        }
    }
}
