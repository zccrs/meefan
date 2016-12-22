// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

SettingsBase {
    id: settingsMain

    property variant userMap: new Object()
    property QtObject currentUser: QtObject {
        property string userId
        property string userScreenName
        property string token
        property string secret
        property string password
        property bool savePass: false
        property bool autoLogin: false
        property bool chrismasSurprised: false
    }

    function setCurrentUserByUserId (id) {
        if (currentUser.userId === id)
            return true;

        var user = userMap[id];

        if (user) {
            currentUser.token = "";
            currentUser.secret = "";
            currentUser.password = "";
            currentUser.savePass = false;
            currentUser.autoLogin = false;

            jsObject2QObject(currentUser, user);
        }

        return Boolean(user);
    }

    function setUser (id, userObj) {
        var map = userMap;

        map[id] = userObj;
        userMap = map;
    }
}
