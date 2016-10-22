import QtQuick 1.1
import com.nokia.meego 1.0

PageStackWindow {
    id: appWindow

    initialPage: mainPage

    MainPage {
        id: mainPage
    }

    ToolBarLayout {
        id: commonTools
        visible: true
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status === DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: qsTr("Sample menu item") }
        }
    }

    Connections {
        target: oauth

        onRequestAccessTokenFinished: {
            console.log("finished! token =", token, "secret =", secret)
        }
        onRequestAccessTokenError: {
            console.log("error:", error)
        }
    }

    Component.onCompleted: {
        oauth.consumerKey = "e5dd03165aebdba16611e1f4849ce2c3";
        oauth.consumerSecret = "none";
        oauth.requestAccessToken("username", "password");
    }
}
