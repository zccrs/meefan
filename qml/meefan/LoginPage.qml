import QtQuick 1.1
import com.nokia.meego 1.0
import "../js/FanFouService.js" as Service

Page {
    orientationLock: PageOrientation.LockPortrait
    tools: ToolBarLayout {
        ToolButton {
            text: qsTr("Login")
            onClicked: {
                ffkit.requestAccessToken(inputEmail.text, inputPassword.text)
            }
        }
        ToolButton {
            text: qsTr("Sign In")
        }
    }

    Connections {
        target: ffkit

        onRequestAccessTokenFinished: {
            console.log("finished! token =", ffkit.oauthToken, "secret =", ffkit.oauthTokenSecret)
            var obj = Service.login()

            if (obj.error) {
                showInfoBanner(obj.error)
                return;
            }

            showInfoBanner("Login Finished " + obj.screen_name)

            obj = Service.homeTimeline()

            if (obj.error) {
                showInfoBanner(obj.error)
                return;
            }
        }
        onRequestAccessTokenError: {
            console.log("error:", error)

            showInfoBanner(error)
        }

        Component.onCompleted: {
            Service.initialize(ffkit)
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
                color: "#ccc"
            }

            Column {
                anchors.centerIn: parent
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "MeeFan"
                    color: parent.parent.border.color
                    font.pointSize: 26
                }

                Text {
                    text: "米饭"
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: parent.parent.border.color
                    font.pointSize: 26
                }
            }
        }

        Item {
            width: 1
            height: 30
        }

        TextField {
            id: inputEmail

            placeholderText: qsTr("User Name/Email")
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.85
            KeyNavigation.down: inputPassword
            KeyNavigation.up: inputPassword
            KeyNavigation.tab: inputPassword
        }

        TextField {
            id: inputPassword

            placeholderText: qsTr("Password")
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
            }

            CheckBox {
                text: qsTr("Auto Login")
                anchors.right: parent.right
            }
        }
    }
}
