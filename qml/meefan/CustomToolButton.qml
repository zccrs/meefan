// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

ToolButton {
    property alias iconId: toolIcon.iconId
    property alias iconSource: toolIcon.iconSource

    height: 71
    flat: true
    anchors.bottom: parent.bottom

    onClicked: checked = true;
    platformStyle: ToolButtonStyle {
        backgroundVisible: false
        checkedBackground: "qrc:///images/toolbutton-checked-background.png"
    }

    ToolIcon {
        id: toolIcon

        anchors.fill: parent
        platformStyle: ToolItemStyle{pressedBackground: ""}
        onClicked: parent.clicked()
    }
}
