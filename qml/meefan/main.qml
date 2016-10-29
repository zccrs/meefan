import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "../js/FanFouService.js" as Service
import "setting"

PageStackWindow {
    id: appWindow

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

//    MainPage {
//        id: mainPage
//    }

//    ToolBarLayout {
//        id: commonTools
//        visible: true
//        ToolIcon {
//            platformIconId: "toolbar-view-menu"
//            anchors.right: (parent === undefined) ? undefined : parent.right
//            onClicked: (myMenu.status === DialogStatus.Closed) ? myMenu.open() : myMenu.close()
//        }
//    }
}
