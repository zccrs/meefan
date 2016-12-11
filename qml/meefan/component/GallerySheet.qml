import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.gallery 1.1
import "../../js/UIConstants.js" as UI

Sheet {
    id: root;

    property int __isPage;  //to make sheet happy
    property bool __isClosing: false;

    signal imageSelected(string url)

    onStatusChanged: {
        if (status == DialogStatus.Closing){
            __isClosing = true;
        } else if (status == DialogStatus.Closed && __isClosing){
            root.destroy(250);
        }
    }

    acceptButtonText: qsTr("Cancle");

    title: Text {
        color: UI.COLOR_FOREGROUND;
        anchors { left: parent.left; leftMargin: UI.PADDING_DOUBLE; verticalCenter: parent.verticalCenter; }
        text: qsTr("Select Image");
        font.pixelSize: UI.FONT_XLARGE
    }

    DocumentGalleryModel {
        id: galleryModel;
        autoUpdate: true;
        rootType: DocumentGallery.Image;
        properties: ["url", "title", "lastModified", "dateTaken"];
        sortProperties: ["-lastModified","-dateTaken", "+title"];
    }

    content: GridView {
        id: galleryView;
        model: galleryModel;
        anchors.fill: parent;
        clip: true;
        cellWidth: Math.floor(width / 5);
        cellHeight: cellWidth;

        delegate: MouseArea {
            implicitWidth: GridView.view.cellWidth;
            implicitHeight: GridView.view.cellHeight;

            onClicked: {
                root.accept();
                imageSelected(url)
            }

            Image {
                anchors.fill: parent;
                sourceSize.width: parent.width;
                asynchronous: true;
                source: model.url;
                fillMode: Image.PreserveAspectCrop;
                clip: true;
                opacity: parent.pressed ? 0.7 : 1;
            }
        }
    }
}
