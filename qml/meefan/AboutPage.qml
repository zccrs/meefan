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

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Version: ")  + ffkit.applicationVersion()
            font.pixelSize: UI.FONT_DEFAULT
            color: UI.COLOR_SECONDARY_FOREGROUND
        }

        Item {
            width: 1
            height: UI.SPACING_DEFAULT
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Project: ") + "<a href='https://github.com/zccrs/meefan'>Github</a>"
            font.pixelSize: UI.FONT_DEFAULT
            color: UI.COLOR_SECONDARY_FOREGROUND

            onLinkActivated: {
                Qt.openUrlExternally(link);

                console.log(link)
            }
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
            text: qsTr("Acknowledgement: ") + "<a href='http://www.9smart.cn/user/56529cbf3d6625c318492a07'>梦影决幻</a>"
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
            bottom: feedbackText.top
        }

        font.pixelSize: UI.FONT_DEFAULT
        text: "<a href='none'>Clear Config</>"

        onLinkActivated: {
            ffkit.clearAppConfig();
            settings.userMap = undefined;
            settings.clearCurrentUserInfo();
            appWindow.showInfoBanner("Clear Successful, Plase restart the application now");
        }
    }

    Text {
        id: feedbackText

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
