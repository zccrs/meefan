// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtWebKit 1.0
import com.nokia.meego 1.0
import "../meefan/component"
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI

CustomPage {
    id: page

    property variant newsObject: null
    property int newsId: 0

    title: qsTr("Zhihu Daily")
    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"

            onClicked: pageStack.pop();
        }
    }

    Component.onCompleted: {
        var obj = Service.getNewsContent(newsId);

        if (obj.error)
            return;

        newsObject = obj;
    }

    Image {
        id: titleImage

        sourceSize.width: parent.width
        source: newsObject.image
        y: Math.min(0, flickable.contentTopMargin - implicitHeight)
           - (flickable.atYBeginning ? flickable.contentY : flickable.contentY / 2.0)

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.2
        }

        Text {
            width: parent.width
            text: ffkit.fromUtf8(newsObject.title)
            font.pixelSize: UI.FONT_LARGE
            color: UI.COLOR_FOREGROUND_LIGHT
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            anchors {
                left: parent.left
                right: parent.right
                bottom: text_image_source.top
                bottomMargin: 0
                margins: UI.MARGIN_XLARGE
            }
        }

        Text {
            id: text_image_source

            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: UI.MARGIN_DEFAULT
            }
            text: ffkit.fromUtf8(newsObject.image_source)
            font.pixelSize: UI.FONT_XSMALL
            color: UI.COLOR_SECONDARY_FOREGROUND_LIGHT
        }
    }

    Flickable {
        id: flickable

        property int contentTopMargin: 200

        width: parent.width
        anchors.fill: parent

        contentHeight: webViewColumn.implicitHeight

        Column {
            id: webViewColumn
            width: parent.width

            Item {
                width: 1
                height: flickable.contentTopMargin
            }

            WebView {
                id: webView

                width: parent.width
                preferredWidth: width
                html: ffkit.fromUtf8(newsObject.body)
                settings.defaultFontSize: UI.FONT_DEFAULT
            }
        }
    }

    ScrollDecorator {
        flickableItem: flickable
        anchors.fill: parent
    }

    ScrollTopButton {
        flickableItem: flickable
    }
}
