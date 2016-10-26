import QtQuick 1.1
import com.nokia.meego 1.0
import "../js/FanFouService.js" as Service

CustomPage {
    title: qsTr("Concerned Message")

    function loadHomeTimeline() {
        var max_id

        if (homeList.model.count > 0)
            max_id = homeList.model.get(homeList.count - 1).object.id

        var obj = Service.homeTimeline(max_id)

        if (obj.error) {
            showInfoBanner(obj.error)
            return;
        }

//        try {
//            var obj = JSON.parse(ffkit.fromUtf8(ffkit.readFile("/tmp/test.json")))
//        } catch(e) {
//            console.log(JSON.stringify(e))
//        }

        for (var i in obj) {
            homeList.model.append({"object": obj[i]});
        }
    }

    Component.onCompleted: loadHomeTimeline()

    content: HomeList {
        id: homeList

        anchors.fill: parent
        onLoadButtonClicked: {
            loadHomeTimeline()
        }
    }
}
