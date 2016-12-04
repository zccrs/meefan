import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import com.zccrs.meefan 1.0
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI
import "setting"
import "component"
import "statuses"

PageStackWindow {
    id: appWindow

    property alias showHeaderBar: header.visible

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
        } else if (errorMessage) {
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

    InfoBanner {
        id: infoBanner

        y:35
    }

    BusyIndicator {
        anchors.centerIn: parent
        platformStyle: BusyIndicatorStyle { size: "large" }
        running: pageStack.busy
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

        enabled: !pageStack.busy
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

                onClicked: {
                    if (checked) {
                        pageStack.replace(Qt.resolvedUrl("statuses/PublicTimelinePage.qml"));
                    }
                }
            }
            CustomToolButton {
                iconId: "toolbar-new-message"
            }
            CustomToolButton {
                id: toolbar_contact_button

                iconId: "toolbar-contact";

                onCheckedChanged: {
                    if (checked) {
                        pageStack.replace(Qt.resolvedUrl("UserInfoPage.qml"), {"userId": settings.currentUser.userId, "tools": commonTools});
                    }
                }
            }
            CustomToolButton {
                iconId: "toolbar-settings";

                onClicked: {
                    settings.currentUser.token = "";
                    settings.currentUser.secret = "";

                    showInfoBanner("clean token and secret finished");
                }
            }
        }
    }
}
