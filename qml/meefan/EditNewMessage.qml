// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "component"
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI

Rectangle {
    property string replyMessageId
    property string replyUserId
    property string repostMessageId
    property string messageSource
    property alias text: textArea.text

    signal closed
    signal sendMessageFinished(variant object)

    color: "#aa000000"

    function show() {
        setShowFullWindow(true);
        visible = true;
        textArea.forceActiveFocus();
    }

    function hide() {
        setShowFullWindow(false);
        focus = false;
        visible = false;
        closed();
    }

    Keys.onEscapePressed: {
        if (inputContext.softwareInputPanelVisible)
            textArea.closeSoftwareInputPanel();
        else
            hide();
    }

    MouseArea {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: _column.top
        }

        onClicked: hide();
    }

    MouseArea {
        anchors.fill: _column

        onClicked: {
            textArea.focus = false;
            textArea.closeSoftwareInputPanel();
        }
    }

    Rectangle {
        anchors.fill: _column
        color: "#E0E1E2"
    }

    Image {
        width: parent.width
        anchors.bottom: _column.top
        source: "qrc:///images/shadow.png"
    }

    Column {
        id: _column

        width: parent.width
        anchors.bottom: parent.bottom

        Item {
            width: 1
            height: UI.SPACING_DEFAULT
        }

        TextArea {
            id: textArea

            width: parent.width - 2 * UI.MARGIN_DEFAULT
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            width: 1
            height: UI.SPACING_DEFAULT
        }

        Item {
            id: toolBar

            width: parent.width - 2 * UI.MARGIN_DEFAULT
            height: UI.HEIGHT_TOOLBAR
            anchors.horizontalCenter: parent.horizontalCenter

            ButtonStyle { id: toolBtnStyle; buttonWidth: buttonHeight; }
            Row {
                spacing: UI.SPACING_DEFAULT

                Button {
                    platformStyle: toolBtnStyle;
                    iconSource: "qrc:///images/btn_insert_at.png";

                    onClicked: {
                        setShowFullWindow(false);

                        var obj = {
                            "userId": settings.currentUser.userId,
                            "popWhenItemClicked": true
                        }
                        var page = pageStack.push(Qt.resolvedUrl("users/FriendsPage.qml"), obj);

                        page.itemClicked.connect(function (object) {
                                                     setShowFullWindow(true);
                                                     textArea.text += "@" + object.screen_name + " ";
                                                     textArea.forceActiveFocus();
                                                     textArea.cursorPosition = textArea.text.length
                                                 });
                        page.pagePoped.connect(function () {
                                                   setShowFullWindow(true);
                                               });
                    }
                }

//                Button {
//                    platformStyle: toolBtnStyle;
//                    iconSource: "qrc:///images/btn_insert_face.png";
//                }

                Button {
                    id: picBtn;

                    property variant selectImageDialogCom

                    platformStyle: toolBtnStyle;
                    iconSource: "qrc:///images/btn_insert_pics.png";

//                    Image {
//                        anchors { top: parent.top; right: parent.right; }
//                        source: "qrc:///images/ico_mbar_news_point.png";
//                        visible: false;
//                    }

                    onClicked: {
                        if (!selectImageDialogCom)
                            selectImageDialogCom = Qt.createComponent("component/GallerySheet.qml");

                        var dialog = selectImageDialogCom.createObject(pageStack.currentPage);
                        selectImageDialogConnections.target = dialog;
                        dialog.open();
                    }

                    Connections {
                        id: selectImageDialogConnections

                        target: null
                        onImageSelected: {
                            messageImage.source = url;
                        }
                    }
                }
            }

            Button {
                enabled: (messageImage.source.toString() || textArea.text) && !sendIndicator.running
                anchors.right: parent.right;
                platformStyle: ButtonStyle {
                    buttonWidth: buttonHeight*2;
                    inverted: !theme.inverted;
                }

                text: qsTr("Send");
                onClicked: {
                    var obj = messageImage.source.toString()
                              ? Service.uploadPhoto(messageImage.source, textArea.text)
                              : Service.commitMessage(textArea.text,
                                                    replyMessageId,
                                                    replyUserId,
                                                    repostMessageId,
                                                    messageSource);

                    if (obj.error) {
                        return;
                    }

                    hide();
                    showInfoBanner(qsTr("Send the new message succeed."));
                    sendMessageFinished(obj);
                }

                BusyIndicator {
                    id: sendIndicator

                    anchors.centerIn: parent
                    platformStyle: BusyIndicatorStyle { size: "small" }
                    visible: running
                    running: appWindow.networkBusy
                }
            }
        }

        Image {
            id: messageImage

            anchors.horizontalCenter: parent.horizontalCenter
            height: Math.min(100, implicitHeight)
            fillMode: Image.PreserveAspectFit

            ToolIcon {
                iconId: "browser-stop"
                visible: messageImage.status === Image.Ready && !sendIndicator.running
                anchors {
                    top: parent.top
                    topMargin: -height / 2
                    right: parent.right
                    rightMargin: -width / 2
                }

                onClicked: {
                    messageImage.source = "";
                }
            }
        }
    }
}
