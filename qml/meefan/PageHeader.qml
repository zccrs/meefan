// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Item {
    property bool invertedTheme: false
    property alias title: mytext.text

    width: parent.width
    height: 72

    Rectangle {
        width: parent.width
        height: 1
        anchors.bottom: line.top
        color: invertedTheme ? "#ccc" : "#bbb"
    }

    Rectangle {
        id: line
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: invertedTheme ? "#fafafa" : "#ccc"
    }

    Text{
        id: mytext
        anchors.verticalCenter: parent.verticalCenter
        x:10
        font.pixelSize: 32
    }
}
