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

    tools: ToolBarLayout {
        enabled: !pageStack.busy

        ToolIcon {
            iconId: "toolbar-back";
            enabled: pageStack.depth > 1

            onClicked: {
                pageStack.pop();
            }
        }
        ToolIcon {
            iconId: "toolbar-view-menu";
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
