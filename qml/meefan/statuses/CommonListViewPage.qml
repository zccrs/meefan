// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../component"
import "../../js/FanFouService.js" as Service

CustomPage {
    property string type
    property string httpExtraArgs
    property bool autoVisibleLoadButton: true
    property alias loadButtonVisible: listView.loadButtonVisible
    property alias menu: pullDownMenu

    signal menuTriggered(int index, string text)

    function httpHandle(obj) {
        if (obj.error) {
            return;
        }

        for (var i in obj) {
            listModel.append({"object": obj[i]});
        }

        if (autoVisibleLoadButton)
            listView.loadButtonVisible = true;
    }

    function loadList() {
        var max_id;

        if (listModel.count > 0)
            max_id = listModel.get(listModel.count - 1).object.id;

        Service.getStatusArray(type, max_id, httpExtraArgs, httpHandle);
    }

    Component.onCompleted: loadList();

    PullDownMenu {
        id: pullDownMenu

        flickableItem: listView
        width: parent.width

        Component.onCompleted: {
            addMenu(qsTr("Refresh"))
        }

        onTrigger: {
            switch (index) {
            case 0: {
                listModel.clear();
                loadList();
            }
            }

            menuTriggered(index, text)
        }
    }

    CommonListView {
        id: listView

        anchors.fill: parent
        model: ListModel {
            id: listModel
        }
        onLoadButtonClicked: {
            loadList()
        }
    }
}
