import QtQuick
import qs.Commons

// Filtered list + keyboard nav shared by the launcher and the power menu, so
// both look and navigate identically. `model` is a plain JS array of
// { label, icon, value } objects; arrow keys move `currentIndex`, Enter
// emits `activated` with the highlighted entry, Escape emits `cancelled`.
FocusScope {
    id: root

    property var model: []
    property int currentIndex: 0
    property int rowHeight: 40
    property int iconWidth: 28
    property int visibleRows: Math.min(model.length, 8)

    // A hoverEnabled MouseArea fires `entered` (and a `positionChanged`) as
    // soon as it appears under an already-stationary cursor, which would
    // immediately steal currentIndex away from row 0. Hover only starts
    // driving currentIndex once the mouse actually moves, so opening the
    // menu always highlights the first entry. lastMousePos is the baseline
    // used to tell a real move from that synthetic event: the first position
    // report after (re)opening just records where the cursor already was,
    // and only a later report at a *different* position counts as movement.
    property bool hoverArmed: false
    property point lastMousePos: Qt.point(-1, -1)

    signal activated(var item)
    signal cancelled()

    implicitHeight: listView.count > 0 ? Math.min(listView.count, visibleRows) * rowHeight : rowHeight
    implicitWidth: 320

    onModelChanged: {
        currentIndex = model.length > 0 ? 0 : -1
        hoverArmed = false
        lastMousePos = Qt.point(-1, -1)
    }

    // Called by the parent's open() so re-showing the menu re-arms the
    // hover guard even when `model` happens not to change (e.g. reopening
    // with an empty, unmodified search query).
    function reset() {
        currentIndex = model.length > 0 ? 0 : -1
        hoverArmed = false
        lastMousePos = Qt.point(-1, -1)
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Down) {
            if (model.length > 0) currentIndex = (currentIndex + 1) % model.length
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            // Don't wrap from row 0: leave the event unaccepted so the
            // caller's Keys.onUpPressed (returning focus to the search
            // input) gets a chance to fire instead.
            if (model.length > 0 && currentIndex > 0) {
                currentIndex = currentIndex - 1
                event.accepted = true
            }
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (currentIndex >= 0 && currentIndex < model.length) root.activated(model[currentIndex])
            event.accepted = true
        } else if (event.key === Qt.Key_Escape) {
            root.cancelled()
            event.accepted = true
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: root.model
        currentIndex: root.currentIndex
        clip: true
        highlightMoveDuration: Style.animationDuration
        delegate: Rectangle {
            width: listView.width
            height: root.rowHeight
            color: index === root.currentIndex ? Color.alpha(Color.accent, 0.25) : "transparent"
            radius: Style.cornerRadius / 2

            Row {
                anchors.fill: parent
                anchors.leftMargin: Style.space(12)
                anchors.rightMargin: Style.space(12)
                spacing: Style.space(10)

                Image {
                    visible: !!modelData.iconSource
                    width: root.iconWidth
                    height: root.iconWidth
                    anchors.verticalCenter: parent.verticalCenter
                    source: modelData.iconSource || ""
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    visible: !modelData.iconSource && !!modelData.icon
                    width: root.iconWidth
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.icon || ""
                    font.family: Style.fontFamily
                    font.pixelSize: 16
                    color: Color.text
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - root.iconWidth - parent.spacing
                    text: modelData.label || ""
                    font.family: Style.fontFamily
                    font.pixelSize: 14
                    color: Color.text
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: if (root.hoverArmed) root.currentIndex = index
                onPositionChanged: {
                    var pos = mapToItem(root, mouse.x, mouse.y)
                    if (root.lastMousePos.x < 0) {
                        // First report since (re)open: just the baseline, not a move.
                        root.lastMousePos = pos
                    } else if (pos.x !== root.lastMousePos.x || pos.y !== root.lastMousePos.y) {
                        root.hoverArmed = true
                        root.currentIndex = index
                        root.lastMousePos = pos
                    }
                }
                onClicked: root.activated(modelData)
            }
        }
    }
}
