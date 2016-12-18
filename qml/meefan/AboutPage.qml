// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "component"
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI

CustomPage {
    title: qsTr("About")
    tools: commonTools

    Column {
        y: 30
        width: parent.width
        spacing: 30

        Rectangle {
            width: parent.width / 3
            height: width
            radius: width / 2
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            border {
                width: 1
                color: UI.COLOR_UNCONSPLCUOUS
            }

            Column {
                anchors.centerIn: parent
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "MeeFan"
                    color: parent.parent.border.color
                    font.pixelSize: UI.FONT_XXLARGE
                }

                Text {
                    text: "米饭"
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: parent.parent.border.color
                    font.pixelSize: UI.FONT_XXLARGE
                }
            }
        }

        Item {
            width: 1
            height: UI.SPACING_DEFAULT
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Version: ")  + ffkit.applicationVersion()
            font.pixelSize: UI.FONT_DEFAULT
            color: UI.COLOR_SECONDARY_FOREGROUND
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Designer: ") + "<a href='http://fanfou.com/~LRwABbrKTOc'>Susam.Minami</a>"
            font.pixelSize: UI.FONT_DEFAULT
            color: UI.COLOR_SECONDARY_FOREGROUND

            onLinkActivated: {
                appWindow.openUrlExternally(link);
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Developer: ") + "<a href='http://fanfou.com/zccrs'>zccrs</a>"
            font.pixelSize: UI.FONT_DEFAULT
            color: UI.COLOR_SECONDARY_FOREGROUND

            onLinkActivated: {
                appWindow.openUrlExternally(link);
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Acknowledgement: ") + "<a href='http://tieba.baidu.com/home/main/?un=%E6%A2%A6%E5%BD%B1%E5%86%B3%E5%B9%BB&ie=utf-8&fr=frs'>梦影决幻</a>"
            font.pixelSize: UI.FONT_DEFAULT
            color: UI.COLOR_SECONDARY_FOREGROUND

            onLinkActivated: {
                Qt.openUrlExternally(link);
            }
        }
    }

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: UI.MARGIN_XLARGE
        }
        font.pixelSize: UI.FONT_DEFAULT
        text: "<a href='https://zccrs.com'>%1</a>".replace("%1", qsTr("Feedback"))

        onLinkActivated: {
            toolbar_home_button.clicked();
            pageStack.currentPage.openNewMessageEdit("@zccrs ", undefined, "zccrs");
        }
    }
}
