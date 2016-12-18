import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import com.zccrs.meefan 1.0
import "../js/FanFouService.js" as Service
import "../js/FanFouAPI.js" as API
import "../js/UIConstants.js" as UI
import "setting"
import "component"
import "statuses"

PageStackWindow {
    id: appWindow

    property alias showHeaderBar: header.visible
    property alias headerBar: header
    property alias networkBusy: header.indicatorRunning
    property bool pageBush: pageStack.currentPage && pageStack.currentPage.status !== PageStatus.Active
    property int mentionsNotificationCount: 0
    property int privateMessageNotificationCount: 0

//    initialPage: UserInfoPage {

//    }

    function showInfoBanner(string) {
        infoBanner.text = string
        infoBanner.show()
    }

    function httpRequestErrorHandle(httpRequest, errorMessage) {
        /// To relogin
        if (httpRequest.status === 204) {
            showInfoBanner(qsTr("Login is expired."));

            settings.currentUser.token = "";
            settings.currentUser.secret = "";

            pageStack.clear();
            pageStack.push(Qt.resolvedUrl("LoginPage.qml"), null, true);
        }

        if (errorMessage) {
            showInfoBanner(errorMessage);
        }
    }

    function findChildren(obj, key, all, pro) {
        var children = obj.children;
        var list = [];

        for (var i = 0; i < children.length; ++i) {
            var string = pro ? children[i][pro].toString() : children[i].toString();

            if (string.indexOf(key) >= 0) {
                if (!all)
                    return children[i];

                list.push(children[i]);
            }
        }

        for (var i = 0; i < children.length; ++i) {
            var r = findChildren(children[i], key, all, pro);

            if (all)
                list.push(r);
            else if (r)
                return r;
        }

        if (all)
            return list;
    }

    function setShowFullWindow(enable) {
        appWindow.showToolBar = !enable;
        appWindow.showHeaderBar = !enable;
    }

    function showImageViewer(imageUrl) {
        setShowFullWindow (true);

        if (!imageViewerLoader.item) {
            imageViewerLoader.source = "component/ImageViewer.qml";
        }

        imageViewerLoader.item.imageUrl = imageUrl;
        imageViewerLoader.item.show();
    }

    function pushUserInfo(userId) {
        if (userId === settings.currentUser.userId)
            toolbar_contact_button.checked = true;
        else
            pageStack.push(Qt.resolvedUrl("UserInfoPage.qml"), {"userId": userId});
    }

    function openUrlExternally(link) {
        if (link.indexOf(API.FANFOU_HOME) === 0) {
            var l = link.substring(API.FANFOU_HOME.length);

            if (l.indexOf(/[\/?&]/) < 0) {
                pushUserInfo(l);
                return;
            }
        }

        Qt.openUrlExternally(link)
    }

    Loader {
        id: imageViewerLoader

        anchors.fill: parent
    }

    Connections {
        target: imageViewerLoader.item

        onSaveButtonClicked: {
            var url = imageViewerLoader.item.imageUrl.toString();
            var last = url.lastIndexOf('/') + 1;
            var fileName = ffkit.picturesStorageLocation() + "/";

            if (last > 0 && last < url.length) {
                fileName += url.substring(last);
            } else {
                fileName += ffkit.createUuid() + ".jpg";
            }

            if (ffkit.saveImage(image, fileName)) {
                showInfoBanner(qsTr("Saved: ") + fileName);
            } else {
                showInfoBanner(qsTr("Save failed: ") + fileName);
            }
        }

        onClosed: {
            setShowFullWindow(false);
        }
    }

    InfoBanner {
        id: infoBanner

        y:35
    }

    BusyIndicator {
        anchors.centerIn: parent
        platformStyle: BusyIndicatorStyle { size: "large" }
        running: pageBush
        visible: running
    }

    SettingsMain {
        id: settings

        json: ffkit.settingValue("settings", "")

        Component.onCompleted: {
            console.log("init settings:", ffkit.settingValue("settings", ""))

            Service.initialize(ffkit, httpRequestErrorHandle)

            if (currentUser.autoLogin && currentUser.token && currentUser.secret) {
                ffkit.oauthToken = currentUser.token;
                ffkit.oauthTokenSecret = currentUser.secret;

                pageStack.push(Qt.resolvedUrl("statuses/HomeTimelinePage.qml"), null, true);
            } else {
                pageStack.push(Qt.resolvedUrl("LoginPage.qml"), null, true);
            }
        }

        Component.onDestruction: {
            console.log("save settings:", json)
            ffkit.setSettingValue("settings", json)
        }
    }

    Timer {
        id: notificationTimer

        interval: 6000
        repeat: true

        onTriggered: {
            // One 60 msec
            interval = 60000;

            var obj = Service.getNotification();

            if (obj.error)
                return;

            var message = "";

            if (obj.mentions > 0 && mentionsNotificationCount != obj.mentions) {
                message += qsTr("Someone has mentioned you");
            }

            if (obj.direct_messages > 0 && privateMessageNotificationCount != obj.direct_messages) {
                if (message)
                    message += "\n";

                message += qsTr("There are %1 new private messages").replace("%1", obj.direct_messages);
            }

            if (message)
                showInfoBanner(message);

            mentionsNotificationCount = obj.mentions;
            privateMessageNotificationCount = obj.direct_messages;
        }
    }

    PageHeader {
        id: header

        title: pageStack.currentPage.title
        width: parent.width
        height: visible ? UI.HEIGHT_HEADERBAR : 0
        contentComponent: pageStack.currentPage.titleComponent

        Behavior on height {
            NumberAnimation {
                easing.type: Easing.InOutExpo;
                duration: 250
            }
        }

        Component.onCompleted: {
            parent = findChildren(appWindow, "appWindowContent", false, "objectName");
            pageStack.parent.anchors.top = header.bottom;
        }

        Connections {
            target: ffkit.httpRequest();

            onReadyStateChanged: {
                var state = ffkit.httpRequest().readyState;

                header.indicatorRunning = (state > HttpRequest.Opened && state < HttpRequest.Done);
            }
        }
    }

    ToolBarLayout {
        id: commonTools

        enabled: !pageBush
        visible: pageStack.toolBar === commonTools

//        ToolIcon {
//            id: backButton

//            height: parent.height
//            iconId: "toolbar-back"
//            enabled: pageStack.depth > 1

//            onClicked: {
//                pageStack.pop();
//            }
//        }

        ButtonRow {
            height: parent.height
            anchors {
                left: parent.left
                right: parent.right
            }

            CustomToolButton {
                id: toolbar_home_button

                iconId: "toolbar-home";

                checked: true
                onCheckedChanged: {
                    if (checked) {
                        pageStack.replace(Qt.resolvedUrl("statuses/HomeTimelinePage.qml"));
                    }
                }
            }
            CustomToolButton {
                iconId: "toolbar-list";

                onCheckedChanged: {
                    if (checked) {
                        pageStack.replace(Qt.resolvedUrl("statuses/PublicTimelinePage.qml"));
                    }
                }
            }
            CustomToolButton {
                iconId: "toolbar-new-message"

                onCheckedChanged: {
                    if (checked) {
                        pageStack.replace(Qt.resolvedUrl("statuses/MentionsPage.qml"));
                        mentionsNotificationCount = 0;
                    }
                }

                RemindToolTip {
                    anchors {
                        bottom: parent.verticalCenter
                        bottomMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    text: mentionsNotificationCount
                    visible: mentionsNotificationCount > 0
                }
            }
            CustomToolButton {
                id: toolbar_contact_button

                iconId: "toolbar-contact";

                onCheckedChanged: {
                    if (checked) {
                        pageStack.replace(Qt.resolvedUrl("UserInfoPage.qml"), {"userId": settings.currentUser.userId, "tools": commonTools});
                    }
                }

                RemindToolTip {
                    anchors {
                        bottom: parent.verticalCenter
                        bottomMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    text: privateMessageNotificationCount
                    visible: privateMessageNotificationCount > 0
                }
            }
            CustomToolButton {
                iconId: "toolbar-frequent-used";

                onCheckedChanged: {
                    if (checked) {
                        pageStack.replace(Qt.resolvedUrl("AboutPage.qml"));
                    }
                }
            }
        }
    }
}
