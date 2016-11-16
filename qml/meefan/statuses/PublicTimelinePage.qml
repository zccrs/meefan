// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

CommonListViewPage {
    title: qsTr("Just Looking Around")
    tools: commonTools
    type: "public_timeline"
    autoVisibleLoadButton: false
    loadButtonVisible: false
}
