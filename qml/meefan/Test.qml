// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Loader {
    id: loadChristmas

    anchors.fill: parent
    visible: false

    function load() {
        if (settings.currentUser.chrismasSurprised
                || settings.currentUser.userId != "zccrs") {
        //    return;
        }

        if (status == Loader.Null) {
            loadChristmas.source = "Christmas.qml";
        }
    }

    Component.onCompleted: {
        if (commonTools.visible) {
            load();
        } else {
            connections.target = commonTools;
        }
    }

    Connections {
        id: connections

        onVisibleChanged: {
            if (commonTools.visible)
                load();
        }
    }

    onStatusChanged: {
        if (status == Loader.Ready) {
            if (!settings.currentUser.userScreenName) {
                var userInfo = appWindow.getService().usersShow();

                if (userInfo.error)
                    return;

                settings.currentUser.userScreenName = userInfo.screen_name;
            }

            visible = true;
        }
    }
}
