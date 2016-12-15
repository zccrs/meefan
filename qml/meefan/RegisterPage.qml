import QtQuick 1.1
import com.nokia.meego 1.0
import "component"
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI

CustomPage {
    title: qsTr("Register")
    orientationLock: PageOrientation.LockPortrait

    Component.onCompleted: {
        findChildren(appWindow, "ToolBar").platformStyle.visibilityTransitionDuration = 0;
    }

    Component.onDestruction: {
        findChildren(appWindow, "ToolBar").platformStyle.visibilityTransitionDuration = 250;
    }

    Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: 30

        Text {
            text: qsTr("Welcome come to fanfou")
            color: UI.COLOR_UNCONSPLCUOUS
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: UI.FONT_XXLARGE
        }

        Item {
            width: 1
            height: 10
        }

        Rectangle {
            color: UI.COLOR_UNCONSPLCUOUS
            height: 2
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: UI.MARGIN_DEFAULT
                rightMargin: UI.MARGIN_DEFAULT
            }
        }

        TextField {
            id: inputEmail

            placeholderText: qsTr("Email")
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.85
            KeyNavigation.down: inputNickname
            KeyNavigation.up: inputPassword1
            KeyNavigation.tab: inputNickname

            onActiveFocusChanged: {
                if (!activeFocus) {
                    if (text) {
                        Service.registerCheck(text, undefined, function(obj) {
                                                  errorHighlight = Boolean(obj.error);
                                              });
                    } else {
                        errorHighlight = true;
                    }
                }
            }

            onTextChanged: {
                errorHighlight = false;
            }
        }

        TextField {
            id: inputNickname

            placeholderText: qsTr("Nickname")
            anchors.horizontalCenter: parent.horizontalCenter
            width: inputEmail.width
            KeyNavigation.down: inputPassword1
            KeyNavigation.up: inputEmail
            KeyNavigation.tab: inputPassword1

            onActiveFocusChanged: {
                if (!activeFocus) {
                    if (text) {
                        Service.registerCheck(undefined, text, function(obj) {
                                                  errorHighlight = Boolean(obj.error);
                                              });
                    } else {
                        errorHighlight = true;
                    }
                }
            }

            onTextChanged: {
                errorHighlight = false;
            }
        }

        TextField {
            id: inputPassword1

            placeholderText: qsTr("Password")
            anchors.horizontalCenter: parent.horizontalCenter
            width: inputEmail.width
            KeyNavigation.down: inputPassword2
            KeyNavigation.up:inputNickname
            KeyNavigation.tab: inputPassword2
            echoMode: TextInput.Password

            onActiveFocusChanged: {
                if (activeFocus)
                    return;

                if (!text) {
                    errorHighlight = true;
                    return;
                }

                if (inputPassword2.text && text != inputPassword2.text) {
                    errorHighlight = true;
                    showInfoBanner(qsTr("The two passwords are not the same"));
                }
            }

            onTextChanged: {
                errorHighlight = false;
            }
        }

        TextField {
            id: inputPassword2

            placeholderText: qsTr("Confirm Password")
            anchors.horizontalCenter: parent.horizontalCenter
            width: inputEmail.width
            KeyNavigation.down: inputEmail
            KeyNavigation.up:inputPassword1
            KeyNavigation.tab: inputEmail
            echoMode: TextInput.Password

            onActiveFocusChanged: {
                if (activeFocus)
                    return;

                if (!text) {
                    errorHighlight = true;
                    return;
                }

                if (inputPassword1.text && text != inputPassword1.text) {
                    errorHighlight = true;
                    showInfoBanner(qsTr("The two passwords are not the same"));
                }
            }

            onTextChanged: {
                errorHighlight = false;
            }
        }

        Item {
            width: 1
            height: UI.SPACING_DEFAULT
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: UI.SPACING_DEFAULT

            Button {
                id: loginButton

                text: qsTr("Login")
                width: (inputEmail.width - parent.spacing) / 2

                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("LoginPage.qml"));
                }
            }

            Button {
                text: qsTr("Register")
                width: (inputEmail.width - parent.spacing) / 2
                enabled: inputEmail.text && !inputEmail.errorHighlight
                         && inputNickname.text && !inputNickname.errorHighlight
                         && inputPassword1.text && !inputPassword1.errorHighlight
                         && inputPassword2.text && !inputPassword2.errorHighlight
                         && inputPassword1.text === inputPassword2.text
                         && inputPassword1.text.length > 3
                         && !pageBush

                onClicked: {
                    var obj = Service.registerFanfou(inputEmail.text, inputNickname.text, inputPassword1.text);

                    if (obj.error)
                        return;

                    showInfoBanner(qsTr("Registration finished"));
                    loginButton.clicked();
                }
            }
        }
    }
}
