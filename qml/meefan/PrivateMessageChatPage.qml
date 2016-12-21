// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import com.zccrs.meefan 1.0
import "component"
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI

CustomPage {
    id: page

    property variant userObject: null

    titleComponent: Component {
        Column {
            width: parent.width

            anchors {
                left: parent.left
                leftMargin: 20
            }

            Text {
                id: userName

                text: userObject.screen_name
                color: UI.COLOR_FOREGROUND_LIGHT
                font.pixelSize: UI.FONT_LARGE
            }

            Text {
                text: ffkit.stringSimplified(userObject.description)
                font.pixelSize: UI.FONT_LSMALL
                color: UI.COLOR_SECONDARY_FOREGROUND_LIGHT
                width: page.width - parent.anchors.leftMargin * 2
                elide: Text.ElideRight
            }
        }
    }

    function loadOldMessages() {
        if (listView.loadingList)
            return;

        listView.loadingList = true;

        var max_id;

        if (listView.model.count > 0)
            max_id = listView.model.get(0).object.id;

        var obj = Service.getPrivateMessagesOfUser(userObject.id, max_id);

        if (obj.error)
            return;

        for (var i = (max_id ? 1 : 0); i < obj.length; ++i) {
            listView.model.insert(0, {"object": obj[i]});
        }

        listView.loadingList = false;
    }

    function loadNewMessages() {
        if (listView.loadingList)
            return;

        listView.loadingList = true;

        var since_id;

        if (listView.model.count > 0)
            since_id = listView.model.get(listView.model.count - 1).object.id;

        var obj = Service.getPrivateMessagesOfUser(userObject.id, undefined, since_id);

        if (obj.error)
            return;

        for (var i in obj) {
            listView.model.append({"object": obj[obj.length - i - 1]});
        }

        listView.loadingList = false;
    }

    Component.onCompleted: {
        findChildren(appWindow, "ToolBar").platformStyle.visibilityTransitionDuration = 0;
        loadNewMessages();
        listView.positionViewAtEnd();
    }

    Component.onDestruction: {
        findChildren(appWindow, "ToolBar").platformStyle.visibilityTransitionDuration = 250;
    }

    ListView {
        id: listView

        property bool loadingList: false

        spacing: UI.SPACING_LARGE
        model: ListModel{}
        anchors {
            top: parent.top
            bottom: toolBar.top
            left: parent.left
            leftMargin: UI.MARGIN_XLARGE
            right: parent.right
            rightMargin: UI.MARGIN_XLARGE
        }

        delegate: Row {
            property bool enabledMirroring: object.recipient_id === userObject.id
                                            || object.recipient_id === userObject.unique_id

            width: parent.width
            height: Math.max(avatar.height, labelColumn.implicitHeight)
            spacing: UI.SPACING_DEFAULT
            LayoutMirroring.enabled: enabledMirroring

            Image {
                id: avatar

                source: object.sender.profile_image_url
                sourceSize: Qt.size(width, height)
                width: UI.SIZE_AVATAR_DEFAULT
                height: width
                anchors.bottom: labelColumn.bottom

                Image {
                    source: "qrc:///images/mask.png"
                    sourceSize: parent.sourceSize
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        pageStack.replace(Qt.resolvedUrl("UserInfoPage.qml"), {"userObject": object});
                    }
                }
            }

            Column {
                id: labelColumn

                width: (parent.width - avatar.width - parent.spacing) / 1.1

                BorderImage {
                    source: "qrc:/images/bubble_" + (enabledMirroring ? 1 : 2) +".png"
                    width: parent.width
                    height: message.implicitHeight + border.top + border.bottom
                    border.left: 28; border.top: 28
                    border.right: 28; border.bottom: 28
                    x: enabledMirroring ? border.left * 2 : -border.left * 2

                    Text {
                        id: message

                        text: object.text
                        anchors.rightMargin: parent.border.right
                        x: parent.border.left
                        y: parent.border.top
                        width: parent.width - parent.border.left - parent.border.right
                        font.pixelSize: UI.FONT_SLARGE
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                        horizontalAlignment: (lineCount <= 1 && object.sender_id !== userObject.unique_id)
                                             ? Text.AlignRight : Text.AlignLeft

                        Component.onCompleted: {
                            if (enabledMirroring)
                                anchors.right = parent.right
                        }
                    }
                }

                Text {
                    text: object.sender_screen_name
                    font.pixelSize: UI.FONT_DEFAULT
                    color: UI.COLOR_SECONDARY_FOREGROUND

                    Component.onCompleted: {
                        if (enabledMirroring)
                            anchors.right = parent.right
                    }
                }

                Text {
                    text: ffkit.datetimeFormatFromISO(new Date(object.created_at).toISOString())
                    color: UI.COLOR_SECONDARY_FOREGROUND
                    font.pixelSize: UI.FONT_SMALL

                    Component.onCompleted: {
                        if (enabledMirroring)
                            anchors.right = parent.right
                    }
                }
            }
        }

        onMovementEnded: {
            if (atYEnd) {
                loadNewMessages()
            }

            if (atYBeginning) {
                loadOldMessages()
            }
        }
    }

    ToolBar {
        id: toolBar

        property Item bgImage: findChildren(toolBar, "BorderImage");

        anchors.bottom: parent.bottom
        height: Math.max(UI.HEIGHT_TOOLBAR, textArea.height + 10)

        onHeightChanged: {
            bgImage.height = height
        }

        tools: Item{}

        Item {
            width: parent.width
            height: UI.HEIGHT_TOOLBAR
            anchors.bottom: parent.bottom

            ToolIcon {
                iconId: "toolbar-back"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }

                onClicked: pageStack.pop();
            }

            TextArea {
                id: textArea

                anchors {
                    bottom: parent.bottom
                    bottomMargin: (toolBar.height - height) / 2
                    horizontalCenter: parent.horizontalCenter
                }

                onImplicitHeightChanged: {
                    height = implicitHeight
                }
            }

            ToolIcon {
                enabled: textArea.text
                iconId: "toolbar-send-chat"
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                }

                onClicked: {
                    var obj = Service.sendPrivateMessage(userObject.id, textArea.text)

                    if (obj.error) {
                        return;
                    }

                    textArea.text = "";
                    listView.model.append({"object": obj});
                }
            }
        }
    }
}
