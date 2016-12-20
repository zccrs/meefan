// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../meefan/component"
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI

CustomPage {
    id: page

    property int currentDate: 0

    title: qsTr("Zhihu Daily")
    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"

            onClicked: pageStack.pop();
        }
    }

    function loadList() {
        var obj = Service.getNewsLatest(currentDate > 0 ? currentDate : undefined);

        if (obj.error)
            return;

        for (var i in obj.stories) {
            var date = ffkit.dateConvert(String(obj.date), "yyyyMMdd", "MMMdd dddd");

            listModel.append({"object": obj.stories[i], "date": date});
        }

        if (obj.length === 0) {
            showInfoBanner(qsTr("No more"));
        }

        currentDate = obj.date;
    }

    Component.onCompleted: {
        loadList()
    }

    ListView {
        spacing: UI.MARGIN_DEFAULT
        anchors.fill: parent
        section.property: "date"
        section.criteria: ViewSection.FullString
        section.delegate: Text {
            text: section
            color: UI.COLOR_UNCONSPLCUOUS
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: UI.FONT_XLARGE
            verticalAlignment: Qt.AlignVCenter
            height: implicitHeight * 2
        }

        model: ListModel {
            id: listModel
        }
        delegate: Item {
            width: parent.width - 2 * UI.MARGIN_DEFAULT
            height: Math.max(text.implicitHeight, image.implicitHeight, 100) + UI.MARGIN_DEFAULT
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: text

                anchors {
                    left: parent.left
                    right: image.left
                    rightMargin: UI.MARGIN_DEFAULT
                }
                font.pixelSize: UI.FONT_SLARGE
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: ffkit.fromUtf8(object.title)
            }

            Image {
                id: image

                source: object.images[0]
                sourceSize.width: 100
                width: source ? 100 : 0
                height: width
                anchors.right: parent.right
            }

            Rectangle {
                color: UI.COLOR_UNCONSPLCUOUS
                height: 1
                width: parent.width
                anchors.bottom: parent.bottom
            }
        }

        footer: Item {
            width: parent.width
            height: UI.HEIGHT_LIST_ITEM

            Button {
                id: load_button

                enabled: !appWindow.networkBusy
                text: qsTr("Load")
                anchors.centerIn: parent
                onClicked: page.loadList()
            }
        }

        ScrollDecorator {
            flickableItem: parent
        }

        ScrollTopButton {
            flickableItem: parent
        }
    }
}
