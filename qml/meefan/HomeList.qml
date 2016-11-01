// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

ListView {
    property bool loadButtonVisible: false
    signal loadButtonClicked

    spacing: 10
    delegate: Item {
        width: parent.width - 20
        height: labelColumn.implicitHeight
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: avatar

            source: object.user.profile_image_url
            sourceSize: Qt.size(width, height)
            width: 60
            height: 60

            Image {
                source: "qrc:///images/mask.png"
                sourceSize: parent.sourceSize
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("UserInfoPage.qml"), {"userId": object.user.id});
                }
            }
        }

        Column {
            id: labelColumn

            anchors {
                left: avatar.right
                leftMargin: 10
                right: parent.right
            }

            Row {
                spacing: 10

                Text {
                    text: object.user.screen_name
                    font.pixelSize: 22
                }

                Text {
                    text: ffkit.datetimeFormatFromISO(new Date(object.created_at).toISOString())
                    color: "#888"
                    font.pixelSize: 22
                }
            }

            Text {
                id: textLocation

                text: object.source + " " + object.user.location
                color: "#888"
                font.pixelSize: 22

                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }

            Item {
                width: 1
                height: 10
            }

            Text {
                id: message

                text: object.text
                font.pixelSize: 26
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }

            Item {
                width: 1
                height: 10
            }

            Rectangle {
                color: "#ccc"
                height: 1
                width: parent.width
            }
        }
    }

    footer: Item {
        width: parent.width
        height: 80

        Button {
            id: load_button

            text: qsTr("Load")
            anchors.centerIn: parent
            visible: parent.parent.parent.loadButtonVisible
            onClicked: parent.parent.parent.loadButtonClicked()
        }
    }
}
