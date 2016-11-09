// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../js/UIConstants.js" as UI

Rectangle {
    id: cellRoot

    property alias text: label.text
    property string iconId
    signal clicked

    width: parent.width / 3
    height: width

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#fefefe" }
        GradientStop { position: 0.5; color: "#efefef" }
        GradientStop { position: 0.6; color: "#eee" }
        GradientStop { position: 0.8; color: "#efefef" }
        GradientStop { position: 1.0; color: "#fefefe" }
    }

    Column {
        width: parent.width
        anchors.centerIn: parent

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:///images/cent_icon_" + iconId + ".png"
        }

        Text {
            id: label

            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: UI.FONT_LSMALL
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: mouseArea.pressed
        opacity: 0.2
        color: "black"
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        onClicked: cellRoot.clicked()
    }
}
