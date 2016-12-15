// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../component"
import "../../js/FanFouService.js" as Service
import "../"

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

        //###(zccrs): Delete duplicate data
        if (listModel.count > 0 && obj.length > 0
                && listModel.get(listModel.count - 1).object.id === obj[0].id) {
            obj.shift();
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

    Loader {
        id: editNewMessageLoader
        anchors.fill: parent
        z: 1;
    }

    function openNewMessageEdit(text, replyMessageId, replyUserId, repostMessageId, messageSource) {
        if (!editNewMessageLoader.item) {
            editNewMessageLoader.source = "../EditNewMessage.qml"
            editNewMessageLoader.item.anchors.fill = editNewMessageLoader.item.parent;
            editNewMessageLoader.item.sendMessageFinished.connect(function(object) {
                                                                      object.text = object.text.replace(/<a href.+?><img.*\/>.+?<\/a>/, "");

                                                                      listView.model.insert(0, {"object": object});
                                                                  });
        }

        editNewMessageLoader.item.text = text ? text : "";
        editNewMessageLoader.item.replyMessageId = replyMessageId ? replyMessageId : "";
        editNewMessageLoader.item.replyUserId = replyUserId ? replyUserId : "";
        editNewMessageLoader.item.repostMessageId = repostMessageId ? repostMessageId : "";
        editNewMessageLoader.item.messageSource = messageSource ? messageSource : "";
        editNewMessageLoader.item.show();

        return editNewMessageLoader.item;
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
        onShowFullWindowChanged: setShowFullWindow(listView.showFullWindow)
        onItemPressAndHold: {
            itemMenu.object = object;
            itemMenu.open();
        }

        Component.onCompleted: {
            userAvatarClicked.connect(page.userAvatarClicked)
            itemClicked.connect(page.itemClicked)
        }
    }

    Menu {
        id: itemMenu

        property variant object: null

        content: MenuLayout {
            MenuItem {
                text: qsTr("Reply")

                onClicked: {
                    openNewMessageEdit("@" + itemMenu.object.user.screen_name + " ", itemMenu.object.id);
                }
            }

            MenuItem {
                text: qsTr("Repost")

                onClicked: {
                    var text = " " + qsTr("Repost") + "@" + itemMenu.object.user.screen_name + " " + ffkit.toPlainText(itemMenu.object.text);

                    openNewMessageEdit(text, undefined, undefined, itemMenu.object.id);
                }
            }

            MenuItem {
                text: {
                    if (itemMenu.object)
                        if (itemMenu.object.favorited)
                        return qsTr("Cancel Favorite")

                    return qsTr("Favorite");
                }

                onClicked: {
                    var obj;

                    if (itemMenu.object.favorited) {
                        obj = Service.cancelFavoriteMessage(itemMenu.object.id);
                    } else {
                        obj = Service.favoriteMessage(itemMenu.object.id);
                    }


                    if (obj.error || !obj.id)
                        return;

                    for (var i = 0; i < listView.model.count; ++i) {
                        if (listView.model.get(i).object.id === obj.id) {
                            listView.model.set(i, {"object": obj});
                            break;
                        }
                    }

                    showInfoBanner(qsTr("Successful operation"));
                }
            }

            MenuItem {
                id: menu_remove

                text: qsTr("Delete")
                enabled: itemMenu.object ? itemMenu.object.user.id === settings.currentUser.userId : false

                onClicked: {
                    var obj = Service.destroyMessage(itemMenu.object.id);

                    if (obj.error || !obj.id)
                        return;

                    for (var i = 0; i < listView.model.count; ++i) {
                        if (listView.model.get(i).object.id === obj.id) {
                            listView.model.remove(i);
                            break;
                        }
                    }
                }
            }
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
