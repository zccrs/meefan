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

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"

            onClicked: pageStack.pop();
        }
        ToolIcon {
            iconId: "toolbar-send-email"

            onClicked: {
                pageStack.clear();
                toolbar_home_button.clicked();
                pageStack.currentPage.openNewMessageEdit("@" + userObject.screen_name + " ",
                                                         undefined, userObject.id);
            }
        }
        ToolIcon {
            iconId: "toolbar-new-message"

            onClicked: {
                pageStack.push(Qt.resolvedUrl("PrivateMessageChatPage.qml"), {"userObject": userObject});
            }
        }
    }
    titleComponent: Component {
        Item {
            anchors.fill: parent

            Text {
                anchors.verticalCenter: parent.verticalCenter
                x: UI.MARGIN_DEFAULT
                font.pixelSize: UI.FONT_XLARGE
                color: "white"
                text: qsTr("User Info")
            }

            ToolIcon {
                iconId: {
                    if (userId === settings.currentUser.userId) {
                        return "toolbar-forward-selected";
                    } else if (userObject.following) {
                        return  "toolbar-favorite-mark-white-selected";
                    } else {
                        return "toolbar-favorite-unmark-white-selected";
                    }
                }

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: UI.MARGIN_DEFAULT
                }

                onClicked: {
                    if (userId === settings.currentUser.userId) {
                        settings.currentUser.token = "";
                        settings.currentUser.secret = "";
                        pageStack.replace(Qt.resolvedUrl("LoginPage.qml"));
                        return;
                    }

                    var obj = null;

                    if (userObject.following) {
                        obj = Service.cancelLikeFriend(userId)
                    } else {
                        obj = Service.likeFriend(userId)
                    }

                    if (obj.error || !obj.id)
                        return;

                    userObject = obj;
                }
            }
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

                MouseArea {
                    anchors.fill: parent

                    onDoubleClicked: {
                        if (settings.currentUser.chrismasSurprised)
                            pageStack.push(Qt.resolvedUrl("../zhihu/NewsListPage.qml"));
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
                    id: followsGridCell

                    iconId: "myba"
                    text: qsTr("Follows")
                    visible: !userObject.protected || userId === settings.currentUser.userId

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("users/FriendsPage.qml"), {"userId": userId});
                    }
                }

                UserInfoGridCell {
                    iconId: "fs"
                    text: qsTr("Fans")
                    visible: followsGridCell.visible

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("users/FansPage.qml"), {"userId": userId});
                    }
                }

                UserInfoGridCell {
                    iconId: "gz"
                    text: qsTr("Photos")

                    onClicked: {
                        var obj = {
                            "userId": userId,
                            "type": "photos_user_timeline",
                            "title": qsTr("User Photos")
                        }

                        pageStack.push(Qt.resolvedUrl("statuses/UserTimelinePage.qml"), obj);
                    }
                }

                UserInfoGridCell {
                    iconId: "chat"
                    text: qsTr("Private Message")
                    visible: userId === settings.currentUser.userId

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("PrivateMessageListPage.qml"));
                    }

                    RemindToolTip {
                        anchors {
                            right: parent.right
                            top: parent.top
                            margins: UI.MARGIN_DEFAULT
                        }
                        text: appWindow.privateMessageNotificationCount
                        visible: appWindow.privateMessageNotificationCount > 0
                    }
                }

                UserInfoGridCell {
                    iconId: "sc"
                    text: qsTr("Favorites")
                    visible: followsGridCell.visible

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("FavoriteListPage.qml"), {"userId": userId});
                    }
                }
            }
        }
    }
}
