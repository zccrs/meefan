import QtQuick 1.1
import com.nokia.meego 1.0

CommonListViewPage {
    id: page

    title: qsTr("Home")
    tools: commonTools

    type: "home_timeline"

    Timer {
        interval: 100
        running: true
        onTriggered: {
            menu.addMenu(qsTr("Add"))
        }
    }

    Loader {
        id: editNewMessageLoader

        anchors.fill: parent
    }

    onMenuTriggered: {
        if (text === qsTr("Add")) {
            if (!editNewMessageLoader.item) {
                editNewMessageLoader.source = "../EditNewMessage.qml";
                editNewMessageLoader.item.closed.connect(function() {showFullWindow(false);});
            }

            showFullWindow(true);
            editNewMessageLoader.item.show();
        }
    }

//    onItemClicked: {
//        pageStack.push(Qt.resolvedUrl("../EditNewMessagePage.qml"),
//                       {
//                           "text": "@" + object.user.screen_name + " ",
//                           "replyMessageId": "\"" + object.id + "\""
//                       })
//    }
}
