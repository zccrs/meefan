import QtQuick 1.1
import com.nokia.meego 1.0
import "component"
import "../js/FanFouService.js" as Service
import "../js/UIConstants.js" as UI

CustomPage {
    title: qsTr("Login")

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

            var obj = Service.usersShow();

            if (obj) {
                settings.currentUser.userId = obj.id;
                settings.currentUser.userScreenName = obj.screen_name;
            }

            showInfoBanner(qsTr("Login Finished"));

            if (!toolbar_home_button.checked)
                toolbar_home_button.checked = true;
            else
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

            placeholderText: qsTr("Phone Number/Email")
            text: settings.currentUser.loginName
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.85
            KeyNavigation.down: inputPassword
            KeyNavigation.up: inputPassword
            KeyNavigation.tab: inputPassword

            onTextChanged: {
                settings.setCurrentUserByLoginName(inputEmail.text)
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

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: UI.SPACING_DEFAULT

            Button {
                enabled: !appWindow.networkBusy
                width: (inputEmail.width - parent.spacing) / 2
                text: qsTr("Register")

                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("RegisterPage.qml"));
                }
            }

            Button {
                text: qsTr("Login")
                width: (inputEmail.width - parent.spacing) / 2
                enabled: inputEmail.text && inputPassword.text && !pageBush && !appWindow.networkBusy

                onClicked: {
                    settings.currentUser.loginName = inputEmail.text;
                    settings.setUser(settings.currentUser.loginName, settings.currentUser);

                    ffkit.requestAccessToken(inputEmail.text, inputPassword.text)
                }
            }
        }
    }
}
