// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../../js/UIConstants.js" as UI

ToolButton {
    property alias iconId: toolIcon.iconId
    property alias iconSource: toolIcon.iconSource

    height: UI.HEIGHT_TOOL_VAR - 1
    flat: true
    anchors.bottom: parent.bottom

    onClicked: checked = true;
    platformStyle: ToolButtonStyle {
        backgroundVisible: false
        checkedBackground: "qrc:///images/toolbutton-checked-background.png"
        pressedBackground: checkedBackground
    }

    ToolIcon {
        id: toolIcon

        anchors.fill: parent
        platformStyle: ToolItemStyle{pressedBackground: ""}
        onClicked: parent.clicked()
    }
}
