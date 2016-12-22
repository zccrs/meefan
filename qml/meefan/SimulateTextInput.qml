// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Item {
    property string text
    property string defaultText
    property alias color: message.color
    property alias font: message.font

    signal finished()

    height: message.implicitHeight
    width: message.implicitWidth + cursor.width + 2

    Text {
        id: message

        text: defaultText
    }

    function begin() {
        timer.start();
    }

    Rectangle {
        id: cursor

        width: 12
        height: parent.height
        color: parent.color
        anchors.right: parent.right
    }

    Timer {
        id: timer

        interval: 300
        repeat: true

        onTriggered: {
            message.text = defaultText + text.substring(0, message.text.length + 1 - defaultText.length);

            if (message.text.length === text.length + defaultText.length) {
                timer.stop();
                cursor.visible = false;
                finished();
            }
        }
    }
}
