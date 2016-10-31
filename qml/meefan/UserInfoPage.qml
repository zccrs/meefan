// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../js/FanFouService.js" as Service

CustomPage {
    property string userId
    property variant object: null

    title: qsTr("User Info")
    tools: commonTools

    Component.onCompleted: {
        object = Service.usersShow();
    }

    Image {
        source: object.profile_background_image_url
        width: parent.width
        height: 100
        fillMode: Image.PreserveAspectCrop
    }
}
