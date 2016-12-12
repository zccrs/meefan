// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "statuses"

CommonListViewPage {
    property string userId

    title: qsTr("User Favorites")
    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"

            onClicked: pageStack.pop();
        }
    }

    type: "favorites"
    httpExtraArgs: "id=" + userId
}
