// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../../js/UIConstants.js" as UI

Rectangle {
    property bool invertedTheme: false
    property alias title: mytext.text
    property alias contentComponent: loader.sourceComponent
    property alias indicatorRunning: busyIndicator.running

    width: parent.width
    height: UI.HEIGHT_HEADERBAR
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

        visible: !contentComponent
        anchors.verticalCenter: parent.verticalCenter
        x: UI.MARGIN_DEFAULT
        font.pixelSize: UI.FONT_XLARGE
        color: "white"
    }

    Loader {
        id: loader

        width: parent.width
        anchors {
            verticalCenter: parent.verticalCenter
        }
    }

    BusyIndicator {
        id: busyIndicator

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            margins: UI.MARGIN_DEFAULT
        }
        visible: running
        platformStyle: BusyIndicatorStyle { size: "small" }
    }
}
