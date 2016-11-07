// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import com.zccrs.meefan 1.0
import "../js/FanFouService.js" as Service

CustomPage {
    property string userId
    property variant object: null

    title: qsTr("User Info")
    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"

            onClicked: pageStack.pop();
        }
        ToolIcon {
            iconId: "toolbar-view-menu"
        }
    }

    Component.onCompleted: {
        object = Service.usersShow(userId);
//        object = JSON.parse(ffkit.fromUtf8(ffkit.readFile("/home/zhang/user.json")));
    }

    Item {
        id: backgroundItem

        width: parent.width
        height: 200
        scale: 1.08
        clip: true

        Image {
            id: backgroundImage

            source: object.profile_background_image_url
            width: parent.width
            height: 200
            clip: true
            fillMode: Image.PreserveAspectCrop
            y: content.atYBeginning ? 0 : -content.contentY / 2.0
            scale: content.atYBeginning ? -content.contentY / content.contentHeight / 4.0 + 1 : 1
            effect: BlurEffect {
                blurRadius: 10
            }
        }

        Rectangle {
            anchors.fill: backgroundImage
            color: "black"
            opacity: 0.2
        }

        Image {
            width: parent.width
            opacity: 0.4
            source: "qrc:///images/shadow.png"
            anchors.bottom: backgroundImage.bottom
        }
    }

    Flickable {
        id: content

        anchors {
            top: backgroundItem.bottom
            topMargin: -avatarImage.height / 2
            bottom: parent.bottom
        }
        width: parent.width
        contentHeight: contentColumn.implicitHeight

        Column {
            id: contentColumn

            width: parent.width

            MaskImage {
                id: avatarImage

                anchors {
                    left: parent.left
                    leftMargin: 20
                }

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

            Item {
                width: 1
                height: 20
            }

            Grid {
                width: parent.width
                columns: 3
                spacing: 1

                UserInfoGridCell {
                    iconId: "tiezi"
                    text: qsTr("Messages")

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("UserTimelinePage.qml"));
                    }
                }

                UserInfoGridCell {
                    iconId: "myba"
                    text: qsTr("Follows")
                }

                UserInfoGridCell {
                    iconId: "fs"
                    text: qsTr("Fans")
                }

                UserInfoGridCell {
                    iconId: "gz"
                    text: qsTr("Pictures")
                }
            }
        }
    }
}
