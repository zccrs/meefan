import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: page

    property Item content: null
    property alias title: header.title

    onContentChanged: {
        content.parent = contentBox
    }

    orientationLock: PageOrientation.LockPortrait

    tools: ButtonRow {
        enabled: !pageStack.busy
        anchors.fill: parent

        CustomToolButton {
            iconId: "toolbar-home";
        }
        CustomToolButton {
            iconId: "toolbar-list";
        }
        CustomToolButton {
            iconId: "toolbar-search";
        }
        CustomToolButton {
            iconId: "toolbar-contact";
        }
        CustomToolButton {
            iconId: "toolbar-settings";
        }
    }

    PageHeader {
        id: header
    }

    Item {
        id: contentBox

        clip: true
        width: parent.width
        anchors {
            top: header.bottom
            bottom: parent.bottom
        }
    }
}
