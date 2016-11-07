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

    function loadTimeline() {
        var max_id;

        if (timelineListModel.count > 0)
            max_id = timelineListModel.get(timelineListModel.count - 1).object.id;

        var obj = Service.userTimeline(max_id);

        if (obj.error) {
            return;
        }

        for (var i in obj) {
            timelineListModel.append({"object": obj[i]});
        }

        timelineList.loadButtonVisible = true;
    }

    Component.onCompleted: loadTimeline()

    CommonList {
        id: timelineList

        anchors.fill: parent

        model: ListModel {
            id: timelineListModel
        }
        onLoadButtonClicked: {
            loadTimeline()
        }
    }
}
