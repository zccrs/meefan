// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../component"
import "../../js/FanFouService.js" as Service

CustomPage {
    id: page

    property string type
    property string httpExtraArgs
    property bool autoVisibleLoadButton: true
    property alias loadButtonVisible: listView.loadButtonVisible
    property alias menu: pullDownMenu
    property bool searchMode: false
    property bool hasSearch: true
    property alias messageMouseAreaEnabled: listView.messageMouseAreaEnabled

    signal userAvatarClicked(variant object)
    signal itemClicked(variant object)
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

        if (obj.length === 0) {
            showInfoBanner(qsTr("No more"));
        }
    }

    function loadList() {
        var max_id;

        if (listModel.count > 0)
            max_id = listModel.get(listModel.count - 1).object.id;

        if (searchMode)
            Service.searchMessage(searchTextField.text, max_id, page.userId, httpHandle);
        else
            Service.getStatusArray(type, max_id, httpExtraArgs, httpHandle);
    }

    function switchToSearchMode() {
        searchMode = true;
        privateData.pageTitle = title;
        title = qsTr("Search");
        appWindow.showToolBar = false;
        searchTextField.forceActiveFocus();
        searchTextField.selectAll();
    }

    function quitSearchMode() {
        title = privateData.pageTitle;
        appWindow.showToolBar = true;
        searchMode = false;
    }

    Component.onCompleted: {
        loadList();

        if (hasSearch)
            pullDownMenu.addMenu(qsTr("Search"));

        pullDownMenu.addMenu(qsTr("Refresh"));
    }

    QtObject {
        id: privateData

        property string pageTitle
    }

    PullDownMenu {
        id: pullDownMenu

        flickableItem: listView
        width: parent.width

        onTrigger: {
            switch (text) {
            case qsTr("Search"): {
                switchToSearchMode();
                break;
            }
            case qsTr("Refresh"): {
                listModel.clear();
                loadList();
                break;
            }
            }

            menuTriggered(index, text)
        }
    }

    CommonListView {
        id: listView

        width: parent.width
        anchors {
            top: parent.top
            bottom: searchToolBar.visible ? searchToolBar.top : parent.bottom
        }

        model: ListModel {
            id: listModel
        }
        onLoadButtonClicked: {
            loadList()
        }
        onUserAvatarClicked: {
            if (object.user.id === settings.currentUser.userId)
                toolbar_contact_button.checked = true;
            else
                pageStack.push(Qt.resolvedUrl("../UserInfoPage.qml"), {"userId": object.user.id});
        }
        onItemClicked: {
            pageStack.push(Qt.resolvedUrl("ContextTimeline.qml"), {"messageId": object.id});
        }
        onShowFullWindowChanged: {
            appWindow.showToolBar = !showFullWindow;
            appWindow.showHeaderBar = !showFullWindow;
        }

        Component.onCompleted: {
            userAvatarClicked.connect(page.userAvatarClicked)
            itemClicked.connect(page.itemClicked)
        }
    }

    ToolBar {
        id: searchToolBar

        anchors.bottom: parent.bottom
        visible: !appWindow.showToolBar && !listView.showFullWindow

        tools: ToolBarLayout {
            visible: tools === searchToolBar

            ToolIcon {
                iconId: "toolbar-back"

                onClicked: quitSearchMode();
            }

            TextField {
                id: searchTextField
            }

            ToolIcon {
                iconId: "toolbar-search"

                onClicked: {
                    listModel.clear();
                    loadList();
                }
            }
        }
    }
}
