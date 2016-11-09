// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../../js/UIConstants.js" as UI

Rectangle {
    property bool invertedTheme: false
    property alias title: mytext.text

    width: parent.width
    height: 72
    color: "#0071BC"

    Rectangle {
        width: parent.width
        height: 1
        anchors.bottom: line.top
        color: invertedTheme ? "#ccc" : "#2082C7"
    }

    Rectangle {
        id: line
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: invertedTheme ? "#fafafa" : "#82ACD2"
    }

    Text {
        id: mytext
        anchors.verticalCenter: parent.verticalCenter
        x:10
        font.pixelSize: UI.FONT_XLARGE
        color: "white"
    }
}
