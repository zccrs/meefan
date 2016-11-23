import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: page

    property string title
    property Component titleComponent

    orientationLock: PageOrientation.LockPortrait
}
