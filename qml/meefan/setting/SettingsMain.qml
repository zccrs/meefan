// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

SettingsBase {
    id: settingsMain

    property variant userMap: new Object()
    property QtObject currentUser: QtObject {
        property string loginName
        property string userId
        property string userScreenName
        property string token
        property string secret
        property string password
        property bool savePass: false
        property bool autoLogin: false
    }

    function setCurrentUserByLoginName (name) {
        if (currentUser.loginName === name)
            return true;

        var user = userMap[name];

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

    function setUser (name, userObj) {
        var map = userMap;

        map[name] = userObj;
        userMap = map;
    }
}
