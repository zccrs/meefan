// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../js/FanFouService.js" as Service

CustomPage {
    title: qsTr("My Message")
    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"

            onClicked: pageStack.pop();
        }
    }

    function loadRetlies() {
        var max_id;

        if (repliesListModel.count > 0)
            max_id = repliesListModel.get(repliesListModel.count - 1).object.id;

        var obj = Service.userReplies(max_id);

        if (obj.error) {
            return;
        }

        for (var i in obj) {
            repliesListModel.append({"object": obj[i]});
        }

        repliesList.loadButtonVisible = true;
    }

    Component.onCompleted: loadRetlies()

    CommonList {
        id: repliesList

        anchors.fill: parent

        model: ListModel {
            id: repliesListModel
        }
        onLoadButtonClicked: {
            loadRetlies()
        }
    }
}
