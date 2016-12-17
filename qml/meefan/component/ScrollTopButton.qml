// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    property Flickable flickableItem

    width: 60
    height: 60
    visible: !flickableItem.atYBeginning
    anchors {
        right: parent.right
        bottom: parent.bottom
    }

    Image {
        visible: !icon.mouseArea.pressed
        anchors.centerIn: parent
        source: "image://theme/icon-l-folder"
        opacity: 0.3
        width: 50
        smooth: true
        fillMode: Image.PreserveAspectFit
    }

    ToolIcon {
        id: icon

        property MouseArea mouseArea

        iconId: "toolbar-up-selected"
        anchors.centerIn: parent

        onClicked: animation.running = true;

        Component.onCompleted: {
            mouseArea = appWindow.findChildren(icon, "MouseArea");
        }
    }

    PropertyAnimation {
        id: animation

        target: flickableItem
        property: "contentY"
        to: 0
        duration: 300
    }
}
