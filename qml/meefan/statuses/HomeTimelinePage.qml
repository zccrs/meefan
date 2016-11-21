import QtQuick 1.1
import com.nokia.meego 1.0

CommonListViewPage {
    title: qsTr("Home")
    tools: commonTools

    type: "home_timeline"

    Timer {
        id: test

        interval: 100
        running: true
        onTriggered: {
            menu.addMenu(qsTr("Add"))
        }
    }

    onMenuTriggered: {
        if (text === qsTr("Add")) {
            pageStack.push(Qt.resolvedUrl("../EditNewMessagePage.qml"));
        }
    }

    onItemClicked: {
        pageStack.push(Qt.resolvedUrl("../EditNewMessagePage.qml"),
                       {
                           "text": "@" + object.user.screen_name + " ",
                           "replyMessageId": "\"" + object.id + "\""
                       })
    }
}
