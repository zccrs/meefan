// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import com.zccrs.meefan 1.0
import "component"
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI

CustomPage {
    title: qsTr("Private Message")
    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"

            onClicked: pageStack.pop();
        }
    }

    Component.onCompleted: {
        var obj = Service.getPrivateMessageList();

        if (obj.error) {
            return;
        }

        for (var i in obj) {
            listView.model.append({"object": obj[i]});
        }
    }

    ListView {
        id: listView

        anchors.fill: parent
        spacing: 10
        model: ListModel {}

        delegate: MouseArea {
            property variant userObject: object.dm.sender_id === object.other_id ? object.dm.sender : object.dm.recipient

            width: parent.width - UI.MARGIN_DEFAULT * 2
            height: Math.max(labelColumn.implicitHeight, avatar.height)
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                pageStack.push(Qt.resolvedUrl("PrivateMessageChatPage.qml"), {"userObject": userObject});
            }

            Image {
                id: avatar

                source: userObject.profile_image_url
                sourceSize: Qt.size(width, height)
                width: UI.SIZE_AVATAR_DEFAULT
                height: width

                Image {
                    source: "qrc:///images/mask.png"
                    sourceSize: parent.sourceSize
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        pageStack.replace(Qt.resolvedUrl("UserInfoPage.qml"), {"userObject": userObject});
                    }
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
                    text: userObject.screen_name
                    font.pixelSize: UI.FONT_LARGE
                }

                Text {
                    text: ffkit.datetimeFormatFromISO(new Date(object.dm.created_at).toISOString())
                    color: UI.COLOR_SECONDARY_FOREGROUND
                    font.pixelSize: UI.FONT_SMALL
                }

                Item {
                    width: 1
                    height: 10
                }

                Text {
                    text: object.dm.text
                    font.pixelSize: UI.FONT_LSMALL
                    color: object.new_conv ? UI.COLOR_FOREGROUND : UI.COLOR_SECONDARY_FOREGROUND
                    width: parent.width
                    elide: Text.ElideRight
                }
            }
        }

        ScrollDecorator {
            flickableItem: parent
        }
    }
}
