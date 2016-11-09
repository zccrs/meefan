import QtQuick 1.1
import com.nokia.meego 1.0
import "component"
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI

CustomPage {
    title: qsTr("Login")
    orientationLock: PageOrientation.LockPortrait

    Component.onCompleted: {
        findChildren(appWindow, "ToolBar").platformStyle.visibilityTransitionDuration = 0;
    }

    Component.onDestruction: {
        findChildren(appWindow, "ToolBar").platformStyle.visibilityTransitionDuration = 250;
    }

    Connections {
        target: ffkit

        onRequestAccessTokenFinished: {
            console.log("finished! token =", ffkit.oauthToken, "secret =", ffkit.oauthTokenSecret)

            settings.currentUser.token = ffkit.oauthToken;
            settings.currentUser.secret = ffkit.oauthTokenSecret;

            if (settings.currentUser.savePass)
                settings.currentUser.password = ffkit.stringEncrypt(inputPassword.text, "Sam.Minami");
            else
                settings.currentUser.password = ""

            showInfoBanner("Login Finished");
            pageStack.replace(Qt.resolvedUrl("statuses/HomeTimelinePage.qml"));
        }
        onRequestAccessTokenError: {
            console.log("error:", error)

            showInfoBanner(error)
        }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: 30

        Rectangle {
            width: parent.width / 3
            height: width
            radius: width / 2
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            border {
                width: 1
                color: UI.COLOR_UNCONSPLCUOUS
            }

            Column {
                anchors.centerIn: parent
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "MeeFan"
                    color: parent.parent.border.color
                    font.pixelSize: UI.FONT_XXLARGE
                }

                Text {
                    text: "米饭"
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: parent.parent.border.color
                    font.pixelSize: UI.FONT_XXLARGE
                }
            }
        }

        Item {
            width: 1
            height: 10
        }

        TextField {
            id: inputEmail

            placeholderText: qsTr("User Name/Email")
            text: settings.currentUser.userId
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.85
            KeyNavigation.down: inputPassword
            KeyNavigation.up: inputPassword
            KeyNavigation.tab: inputPassword

            onTextChanged: {
                settings.setCurrentUserByUserId(inputEmail.text)
            }
        }

        TextField {
            id: inputPassword

            placeholderText: qsTr("Password")
            text: ffkit.stringUncrypt(settings.currentUser.password, "Sam.Minami")
            anchors.horizontalCenter: parent.horizontalCenter
            width: inputEmail.width
            KeyNavigation.down: inputEmail
            KeyNavigation.up:inputEmail
            KeyNavigation.tab: inputEmail
            echoMode: TextInput.Password
        }

        Item {
            id: radioRow

            width: inputEmail.width
            height: savaPasswordRadio.height
            anchors.horizontalCenter: parent.horizontalCenter

            CheckBox {
                id: savaPasswordRadio

                text: qsTr("Save Password")
                checked: settings.currentUser.savePass

                onCheckedChanged: {
                    settings.currentUser.savePass = checked;

                    if (!checked)
                        autoLoginRadio.checked = false;
                }
            }

            CheckBox {
                id: autoLoginRadio

                text: qsTr("Auto Login")
                checked: settings.currentUser.autoLogin
                anchors.right: parent.right

                onCheckedChanged: {
                    settings.currentUser.autoLogin = checked;

                    if (checked)
                        savaPasswordRadio.checked = true;
                }
            }
        }

        Item {
            width: 1
            height: UI.SPACING_DEFAULT
        }

        Button {
            text: qsTr("Login")
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: inputEmail.text && inputPassword.text && !pageStack.busy

            onClicked: {
                settings.currentUser.userId = inputEmail.text;
                settings.setUser(settings.currentUser.userId, settings.currentUser);

                ffkit.requestAccessToken(inputEmail.text, inputPassword.text)
            }
        }
    }
}
