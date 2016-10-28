// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

ListView {
    property bool loadButtonVisible: false

    signal loadButtonClicked

    spacing: 10
    delegate: Item {
        width: parent.width - 20
        height: Math.max(avatar.implicitHeight, text_column.implicitHeight)
                + textLocation.implicitHeight + textLocation.anchors.bottomMargin
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: avatar

            source: object.user.profile_image_url_large
            sourceSize: Qt.size(width, height)
            width: 80
            height: 80

            Image {
                source: "qrc:///images/mask.png"
                sourceSize: parent.sourceSize
            }
        }

        Column {
            id: text_column

            anchors {
                left: avatar.right
                leftMargin: 10
                right: parent.right
            }

            Row {
                spacing: 10

                Text {
                    text: object.user.screen_name
                    font.pixelSize: 20
                }

                Text {
                    text: ffkit.datetimeFormatFromISO(new Date(object.created_at).toISOString())
                    color: "#888"
                    font.pixelSize: 20
                }
            }

            Text {
                id: message

                text: object.text
                font.pixelSize: 26
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }

        Text {
            id: textLocation

            text: object.source + " " + object.user.location
            color: "#888"
            font.pixelSize: 20
            anchors {
                right: parent.right
                bottom: parent.bottom
                bottomMargin: 10
            }

            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }

        Rectangle {
            color: "#ccc"
            height: 1
            anchors {
                left: text_column.left
                right: parent.right
                top: textLocation.bottom
                topMargin: 10
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
