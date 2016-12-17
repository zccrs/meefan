// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../../js/UIConstants.js" as UI

ListView {
    signal userAvatarClicked(variant object)
    signal itemClicked(variant object)

    spacing: 10
    delegate: MouseArea {
        width: parent.width - UI.MARGIN_DEFAULT * 2
        height: Math.max(labelColumn.implicitHeight, avatar.height)
        anchors.horizontalCenter: parent.horizontalCenter

        onClicked: itemClicked(object)

        Image {
            id: avatar

            source: object.profile_image_url
            sourceSize: Qt.size(width, height)
            width: UI.SIZE_AVATAR_DEFAULT
            height: width

            Image {
                source: "qrc:///images/mask.png"
                sourceSize: parent.sourceSize
            }

            MouseArea {
                anchors.fill: parent

                onClicked: userAvatarClicked(object)
            }
        }

        Column {
            id: labelColumn

            anchors {
                left: avatar.right
                leftMargin: UI.MARGIN_DEFAULT
                right: parent.right
            }

            Text {
                text: object.screen_name
                font.pixelSize: UI.FONT_LARGE
            }

            Text {
                text: object.description
                font.pixelSize: UI.FONT_SMALL
                color: UI.COLOR_SECONDARY_FOREGROUND
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }
}
