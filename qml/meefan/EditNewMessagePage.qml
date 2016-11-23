// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "component"
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI

CustomPage {
    property string replyMessageId
    property string replyUserId
    property string repostMessageId
    property string messageSource
    property alias text: textArea.text

    title: qsTr("New")

    TextArea {
        id: textArea

        width: parent.width

        anchors {
            top: parent.top
            bottom: toolBar.top
        }
    }

    ToolBarLayout {
        id: toolBar

        width: parent.width
        height: UI.HEIGHT_TOOLBAR
        anchors.bottom: parent.bottom

        ToolIcon {
            iconId: "toolbar-back"

            onClicked: {
                pageStack.pop();
            }
        }

        ToolIcon {
            enabled: textArea.text
            iconId: "toolbar-send-chat"

            onClicked: {
                var obj = Service.commitMessage(textArea.text + "\n----Send from meefan",
                                              replyMessageId,
                                              replyUserId,
                                              repostMessageId,
                                              messageSource)

                if (obj.error) {
                    return;
                }

                pageStack.pop();
                showInfoBanner(qsTr("Send the new message succeed."))
            }
        }
    }
}
