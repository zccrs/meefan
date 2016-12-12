// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import com.zccrs.meefan 1.0
import "component"
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI

CustomPage {
    property string userId
    property variant userObject: null

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
        if (!userObject)
            userObject = Service.usersShow(userId);
        else
            userId = userObject.id;
    }

    Item {
        id: backgroundItem

        width: parent.width
        height: 200
        scale: 1.08
        clip: true

        Image {
            id: backgroundImage

            source: userObject.profile_background_image_url
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
                source: userObject.profile_image_url_large
                maskSource: "qrc:///images/mask.bmp"

                Text {
                    id: userName

                    text: userObject.screen_name
                    color: userObject.profile_text_color
                    font.pixelSize: UI.FONT_LARGE
                    anchors {
                        left: parent.right
                        leftMargin: 20
                    }
                }

                Image {
                    source: "qrc:///images/icon_" + (userObject.gender === '男' ? "boy" : "girl") + ".png"
                    anchors {
                        left: userName.right
                        bottom: userName.baseline
                    }
                }
            }

            Item {
                width: 1
                height: UI.SPACING_DEFAULT * 2
            }

            Grid {
                width: parent.width
                columns: 3
                spacing: 1

                UserInfoGridCell {
                    iconId: "tiezi"
                    text: qsTr("Messages")

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("statuses/UserTimelinePage.qml"), {"userId": userId});
                    }
                }

                UserInfoGridCell {
                    iconId: "myba"
                    text: qsTr("Follows")

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("users/FriendsPage.qml"), {"userId": userId});
                    }
                }

                UserInfoGridCell {
                    iconId: "fs"
                    text: qsTr("Fans")

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("users/FansPage.qml"), {"userId": userId});
                    }
                }

                UserInfoGridCell {
                    iconId: "gz"
                    text: qsTr("Pictures")
                }

                UserInfoGridCell {
                    iconId: "tiezi"
                    text: qsTr("Private Message")
                    visible: userId === settings.currentUser.userId

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("PrivateMessageListPage.qml"));
                    }
                }

                UserInfoGridCell {
                    iconId: "sc"
                    text: qsTr("Favorites")

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("FavoriteListPage.qml"), {"userId": userId});
                    }
                }
            }
        }
    }
}
