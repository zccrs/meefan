// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../../js/UIConstants.js" as UI

Image {
    property alias text: toolTip.text

    source: "image://theme/icon-m-common-presence-online"
    width: 30
    smooth: true
    fillMode: Image.PreserveAspectFit

    Text {
        id: toolTip

        anchors.centerIn: parent
        font.pixelSize: UI.FONT_XXSMALL
        color: UI.COLOR_FOREGROUND_LIGHT
    }
}
