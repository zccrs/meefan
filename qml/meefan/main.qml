import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1

PageStackWindow {
    id: appWindow

    function showInfoBanner(string) {
        infoBanner.text = string
        infoBanner.show()
    }

    initialPage: LoginPage {

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
