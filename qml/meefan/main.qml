import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "../js/FanFouService.js" as Service
import "setting"

PageStackWindow {
    id: appWindow

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
        } else {
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

                pageStack.push(Qt.resolvedUrl("MainPage.qml"));
            } else {
                pageStack.push(Qt.resolvedUrl("LoginPage.qml"));
            }
        }

        Component.onDestruction: {
            console.log("save settings:", json)
            ffkit.setSettingValue("settings", json)
        }
    }

    PageHeader {
        id: header

        parent: findChildren(appWindow, "appWindowContent", false, "objectName")
        title: pageStack.currentPage.title
        width: parent.width

        Component.onCompleted: {
            pageStack.parent.anchors.top = header.bottom;
        }
    }

    ButtonRow {
        id: commonTools

        enabled: !pageStack.busy
        anchors.fill: parent

        CustomToolButton {
            iconId: "toolbar-home";

            onCheckedChanged: {
                if (checked) {
                    pageStack.replace(Qt.resolvedUrl("MainPage.qml"));
                }
            }
        }
        CustomToolButton {
            iconId: "toolbar-list";
        }
        CustomToolButton {
            iconId: "toolbar-search";
        }
        CustomToolButton {
            iconId: "toolbar-contact";

            onCheckedChanged: {
                if (checked) {
                    pageStack.replace(Qt.resolvedUrl("UserInfoPage.qml"));
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
