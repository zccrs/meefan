// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

MouseArea {
    id: root

    function beginShowMessage() {
        text_column.currentIndex = 0;
    }

    Rectangle {
        color: "black"
        opacity: 0.8
        anchors.fill: parent
    }

    Column {
        id: text_column

        property int currentIndex: -1

        x: 10
        y: 50

        Repeater {
            model: ["亲爱的" + (settings.currentUser.userScreenName ? settings.currentUser.userScreenName : settings.currentUser.userId),
                "恭喜您获得由meefan官方提供的",
                "终身SVIP服务",
                "中奖率可是72.08亿分之一哦！",
                "小饭悄悄的告诉你，这并不是惊喜",
                "惊喜在******=-=",
                "......",
                "个人中心，双击你的头像",
                "再见，SVIP"]

            SimulateTextInput {
                text: modelData
                defaultText: "~ $ "
                visible: index <= text_column.currentIndex
                color: "#02cd00"
                font.pixelSize: 26

                onVisibleChanged: {
                    if (visible)
                        begin();
                }

                onFinished: {
                    ++text_column.currentIndex;

                    if (index === 8) {
                        hj.y = root.height - hj.height - 10;
                    }
                }
            }
        }
    }

    Image {
        id: box_image

        anchors.centerIn: parent
        width: parent.width / 1.5
        fillMode: Image.PreserveAspectFit
        source: "box.png"

        SequentialAnimation {
            id: box_animation

            NumberAnimation { target: box_image; property: "width"; to: root.width / 1.2; duration: 300 }
            NumberAnimation { target: box_image; property: "width"; to: root.width / 1.8; duration: 400 }
            NumberAnimation { target: box_image; property: "width"; to: root.width / 1.2; duration: 300 }
            NumberAnimation { target: box_image; property: "width"; to: root.width; duration: 400 }
            NumberAnimation { target: box_image; property: "width"; to: 0; duration: 800; easing.type: Easing.OutExpo }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                box_animation.start();
                hj.visible = true;
            }
        }
    }

    Image {
        id: hj

        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
        sourceSize.width: parent.width / 2
        source: "2333.png"
        y: -height

        Behavior on y {
            NumberAnimation {duration: 1000; easing.type: Easing.OutElastic;}
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.visible = false;
            }
        }
    }

    Image {
        id: ct

        visible: box_image.width > 0
        anchors {
            bottom: parent.bottom
            right: parent.right
            bottomMargin: -40
            rightMargin: -65
        }
        source: "christmas_tree.png"

        onVisibleChanged: {
            if (!visible && hj.visible) {
                beginShowMessage();
            }
        }
    }
}
