// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../component"
import "../../js/FanFouService.js" as Service

CustomPage {
    id: page

    property string userId
    property string type
    property string httpExtraArgs
    property alias menu: pullDownMenu

    signal userAvatarClicked(variant object)
    signal itemClicked(variant object)
    signal menuTriggered(int index, string text)

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"

            onClicked: pageStack.pop();
        }
    }

    onUserIdChanged: {
        Service.getUsersArray(type, userId, httpExtraArgs, httpHandle);
    }

    function httpHandle(obj) {
        if (obj.error) {
            return;
        }

        for (var i in obj) {
            listModel.append({"object": obj[i]});
        }
    }

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
                Service.getUsersArray(type, userId, httpExtraArgs, httpHandle);
            }
            }

            menuTriggered(index, text)
        }
    }

    CommonUserListView {
        id: listView

        anchors.fill: parent
        model: ListModel {
            id: listModel
        }

        onItemClicked: {
            pageStack.replace(Qt.resolvedUrl("../UserInfoPage.qml"), {"object": object});
        }

        Component.onCompleted: {
            userAvatarClicked.connect(page.userAvatarClicked)
            itemClicked.connect(page.itemClicked)
        }
    }
}
