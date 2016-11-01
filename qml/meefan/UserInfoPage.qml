// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import com.zccrs.meefan 1.0
import "../js/FanFouService.js" as Service

CustomPage {
    property string userId
    property variant object: null

    title: qsTr("User Info")
    tools: commonTools

    Component.onCompleted: {
        object = Service.usersShow(userId);
//        object = JSON.parse(ffkit.fromUtf8(ffkit.readFile("/home/zhang/user.json")));
    }

    Item {
        id: backgroundImage

        width: parent.width
        height: 200

        Image {
            source: object.profile_background_image_url
            width: parent.width
            height: 200
            clip: true
            fillMode: Image.PreserveAspectCrop
            y: content.atYBeginning ? 0 : -content.contentY / 2.0
            scale: content.atYBeginning ? -content.contentY / content.contentHeight / 4.0 + 1 : 1

            Image {
                width: parent.width
                opacity: 0.2
                source: "qrc:///images/shadow.png"
                anchors.bottom: parent.bottom
            }
        }
    }

    Flickable {
        id: content

        anchors {
            top: backgroundImage.bottom
            topMargin: -avatarImage.height / 2 - 20
            bottom: parent.bottom
        }
        width: parent.width
        contentHeight: contentColumn.implicitHeight

        Column {
            id: contentColumn

            anchors {
                left: parent.left
                leftMargin: 20
                right: parent.right
                rightMargin: 20
            }

            MaskImage {
                id: avatarImage

                sourceSize.width: width
                width: 100
                height: width
                source: object.profile_image_url_large
                maskSource: "qrc:///images/mask.bmp"

                Text {
                    id: userName

                    text: object.screen_name
                    color: object.profile_text_color
                    font.pixelSize: 28
                    anchors {
                        left: parent.right
                        leftMargin: 20
                    }
                }

                Image {
                    source: "qrc:///images/icon_" + (object.gender === '男' ? "boy" : "girl") + ".png"
                    anchors {
                        left: userName.right
                        bottom: userName.baseline
                    }
                }
            }
        }
    }
}
