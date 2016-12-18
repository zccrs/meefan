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

    onMenuTriggered: {
        if (text === qsTr("Add")) {
            openNewMessageEdit();
        }
    }

    Component.onCompleted: {
        notificationTimer.running = true;
    }
}
