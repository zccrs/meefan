import QtQuick 1.1
import com.nokia.meego 1.0
import "../js/FanFouService.js" as Service

CustomPage {
    title: qsTr("Home")
    tools: commonTools

    function loadHomeTimelineHandle(obj) {
        if (obj.error) {
            return;
        }

//        try {
//            var obj = JSON.parse(ffkit.fromUtf8(ffkit.readFile("/tmp/test.json")))
//        } catch(e) {
//            console.log(JSON.stringify(e))
//        }

        for (var i in obj) {
            homeListModel.append({"object": obj[i]});
        }

        homeList.loadButtonVisible = true;
    }

    function loadHomeTimeline() {
        var max_id;

        if (homeListModel.count > 0)
            max_id = homeListModel.get(homeListModel.count - 1).object.id;

        Service.homeTimeline(max_id, loadHomeTimelineHandle);
    }

    Component.onCompleted: loadHomeTimeline();

    HomeList {
        id: homeList

        anchors.fill: parent
        model: ListModel {
            id: homeListModel
        }
        onLoadButtonClicked: {
            loadHomeTimeline()
        }
    }
}
