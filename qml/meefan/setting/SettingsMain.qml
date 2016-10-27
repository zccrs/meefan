// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

SettingsBase {
    id: settingsMain

    property variant userMap: new Object()
    property QtObject currentUser: QtObject {
        property string name
        property string token
        property string secret
        property bool savePass: false
        property string password
    }

    function setCurrentUserByName (name) {
        if (currentUser.name === name)
            return true;

        var user = userMap[name];

        if (user) {
            token = "";
            secret = "";
            savePass = false;
            password = ""

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
