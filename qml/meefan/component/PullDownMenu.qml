// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.zccrs.meefan 1.0
import "../../js/UIConstants.js" as UI

Item {
    id: root

    property Flickable flickableItem
    property bool invertedTheme: false
    property int menuItemPixelSize: 22
    property int currentIndex: flickableItem.contentY < 0 ? listMenu.currentIndex : -1
    property int menuItemHeight: 30
    property alias listModel: listMenu.model

    signal trigger(int index, string text)

    height: listMenu.count * (menuItemHeight + listMenu.spacing)

    onCurrentIndexChanged: {
        if (currentIndex >= 0 && listMenu.count > 0)
            ffkit.vibrationDevice();
    }

    function addMenu(menuText, iconSource) {
        var obj = {
            "iconSource": iconSource ? iconSource : "",
            "menuText": menuText
        }

        listModel.append(obj)
    }

    function removeMenu(index) {
        listModel.remove(index)
    }

    function clearMenu() {
        listModel.clear()
    }

    function insertMenu(index, menuText, iconSource) {
        var obj = {
            "iconSource": iconSource ? iconSource: "",
            "menuText": menuText
        }

        listModel.insert(index, obj)
    }

    function setMenuText(index, value) {
        if(index < listModel.count)
            listModel.get(index).menuText = value
    }

    function getMenuText(index) {
        return listModel.get(index).menuText
    }

    ListView {
        id: listMenu

        property int yDeviation: 0

        interactive: false
        width: parent.width
        height: parent.height
        spacing: 5
        clip: true

        onHeightChanged: {
            updateY()
        }

        function updateY() {
            if (listView.atYBeginning) {
                y = -listView.contentY + yDeviation - height - 10
            } else {
                y = -height
            }
        }

        onYChanged: {
            if (y > height) {
                currentIndex = 0
            } else {
                var index = listMenu.indexAt(width / 2, root.height - y)
                currentIndex = index
            }
        }

        model: ListModel{}
        delegate: listDelegate

        Connections {
            target: listView

            onContentYChanged: {
                listMenu.updateY()
            }

            onAtYBeginningChanged: {
                if (listView.atYBeginning) {
                    listMenu.yDeviation = listView.contentY
                }
            }
        }
    }

    Component {
        id: listDelegate

        Row {
            property bool active: ListView.view.currentIndex == index

            height: title.implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: icon
                sourceSize.height: parent.height
                source: iconSource
            }

            Text {
                id: title

                text: menuText
                color: active ? UI.COLOR_FOREGROUND : UI.COLOR_UNCONSPLCUOUS
                scale: active ? 1.2 : 1

                font {
                    bold: active
                    pixelSize: menuItemPixelSize
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 300
                    }
                }
            }

            Component.onCompleted: {
                menuItemHeight = height
            }

            onHeightChanged: {
                menuItemHeight = height
            }
        }
    }

    MonitorMouseEvent {
        target: listView
        anchors.fill: parent

        onMouseRelease: {
            if (currentIndex >= 0) {
                trigger(currentIndex, listModel.get(currentIndex).menuText);
            }
        }
    }
}
