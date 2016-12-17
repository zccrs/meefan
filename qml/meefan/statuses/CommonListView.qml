// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../../js/UIConstants.js" as UI
import "../../js/FanFouAPI.js" as API

ListView {
    property bool loadButtonVisible: false
    property bool messageMouseAreaEnabled: true
    signal loadButtonClicked
    signal userAvatarClicked(variant object)
    signal itemClicked(variant object)
    signal itemPressAndHold(variant object)
    signal pushUserInfo(string userId)

    spacing: 10
    delegate: Item {
        width: parent.width - UI.MARGIN_DEFAULT * 2
        height: labelColumn.implicitHeight
        anchors.horizontalCenter: parent.horizontalCenter

        MouseArea {
            anchors.fill: parent
            enabled: messageMouseAreaEnabled
            onClicked: itemClicked(object)
            onPressAndHold: itemPressAndHold(object)
        }

        Image {
            id: avatar

            source: object.user.profile_image_url
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

            Row {
                spacing: UI.SPACING_DEFAULT

                Text {
                    text: object.user.screen_name
                    font.pixelSize: UI.FONT_LSMALL
                }

                Text {
                    text: ffkit.datetimeFormatFromISO(new Date(object.created_at).toISOString())
                    color: UI.COLOR_SECONDARY_FOREGROUND
                    font.pixelSize: UI.FONT_LSMALL
                }
            }

            Text {
                id: textLocation

                text: object.source + " " + object.location
                color:  UI.COLOR_SECONDARY_FOREGROUND
                font.pixelSize: UI.FONT_LSMALL

                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }

            Item {
                width: 1
                height: UI.SPACING_DEFAULT
            }

            Text {
                id: message

                text: object.text
                width: parent.width
                font.pixelSize: UI.FONT_SLARGE
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText

                onLinkActivated: {
                    if (link.indexOf(API.FANFOU_HOME) === 0) {
                        var l = link.substring(API.FANFOU_HOME.length);

                        if (l.indexOf(/[\/?&]/) < 0) {
                            pushUserInfo(l);
                        }
                    }

                    Qt.openUrlExternally(link)
                }
            }

            Image {
                source: object.photo ? object.photo.thumburl : ""
                fillMode: Image.PreserveAspectFit
                width: Math.min(parent.width, implicitWidth)
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        appWindow.showImageViewer(object.photo.largeurl);
                    }
                }
            }

            Item {
                width: 1
                height:  UI.SPACING_DEFAULT
            }

            Rectangle {
                color: UI.COLOR_UNCONSPLCUOUS
                height: 1
                width: parent.width
            }
        }
    }

    footer: Item {
        width: parent.width
        height: UI.HEIGHT_LIST_ITEM

        Button {
            id: load_button

            text: qsTr("Load")
            anchors.centerIn: parent
            visible: parent.parent.parent.loadButtonVisible
            onClicked: parent.parent.parent.loadButtonClicked()
        }
    }

    ScrollDecorator {
        flickableItem: parent
    }
}
