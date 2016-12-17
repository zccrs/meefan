// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../component"
import "../../js/FanFouService.js" as Service
import "../../js/UIConstants.js" as UI

CustomPage {
    id: page

    property string userId
    property string type
    property string httpExtraArgs
    property alias menu: pullDownMenu
    property bool popWhenItemClicked: false

    signal userAvatarClicked(variant object)
    signal itemClicked(variant object)
    signal menuTriggered(int index, string text)
    signal pagePoped()

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"

            onClicked: {
                pageStack.pop();
                pagePoped();
            }
        }
    }

    onUserIdChanged: {
        privateData.currentPageNumber = 1;
        listModel.clear();
        loadList();
    }

    function httpHandle(obj) {
        if (obj.error) {
            return;
        }

        for (var i in obj) {
            listModel.append({"object": obj[i]});
        }

        if (obj.length === 0) {
            showInfoBanner(qsTr("No more"));
        } else {
            ++privateData.currentPageNumber;
        }
    }

    function loadList() {
        Service.getUsersArray(type, privateData.currentPageNumber, userId, httpExtraArgs, httpHandle);
    }

    QtObject {
        id: privateData

        property int currentPageNumber: 1
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
                onUserIdChanged();
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

        footer: Item {
            width: parent.width
            height: UI.HEIGHT_LIST_ITEM

            Button {
                id: load_button

                text: qsTr("Load")
                anchors.centerIn: parent
                onClicked: page.loadList()
            }
        }

        onItemClicked: {
            if (popWhenItemClicked) {
                pageStack.pop(undefined, true);
            } else {
                pageStack.replace(Qt.resolvedUrl("../UserInfoPage.qml"), {"userObject": object});
            }
        }

        Component.onCompleted: {
            userAvatarClicked.connect(page.userAvatarClicked)
            itemClicked.connect(page.itemClicked)
        }

        ScrollDecorator {
            flickableItem: parent
        }
    }
}
