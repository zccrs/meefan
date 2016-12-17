// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

Rectangle {
    id:image_zoom

    property alias imageUrl: imagePreview.source
    property alias currentImage: imagePreview
    property alias flickable: imageFlickable
    signal closed
    signal saveButtonClicked(variant image)

    anchors.fill: parent
    color: "black"
    opacity: 0.8

    onOpacityChanged: {
        if(opacity===1)
            save.visible=true
    }

    function show() {
        opacity = 1;
        forceActiveFocus();
    }

    function hide() {
        focus = false;
        opacity = 0;
        closed();
    }

    Keys.onEscapePressed: timerClose.start()

    Behavior on opacity{
        NumberAnimation{duration: 100}
    }

    Timer{
        id: timerClose
        interval: 100
        onTriggered: hide()
    }

    Flickable {
        id: imageFlickable

        width: parent.width
        height: parent.height
        interactive: image_zoom.opacity
        contentWidth: imageContainer.width;
        contentHeight: imageContainer.height

        onHeightChanged: if (imagePreview.status === Image.Ready) imagePreview.fitToScreen()

        Item {

            id: imageContainer
            width: Math.max(imagePreview.width * imagePreview.scale, imageFlickable.width)
            height: Math.max(imagePreview.height * imagePreview.scale, imageFlickable.height)

            Image {
                id: imagePreview
                property real prevScale

                anchors.centerIn: parent
                //asynchronous: true
                smooth: true

                function fitToScreen() {
                    scale = Math.min(imageFlickable.width / width, imageFlickable.height / height, 1)
                    //pinchArea.minScale = scale
                    prevScale = scale
                }

                onStatusChanged: {
                    if (status == Image.Ready) {
                        fitToScreen()
                        loadedAnimation.start()
                    }
                }

                onScaleChanged: {
                    if ((width * scale) > imageFlickable.width) {
                        var xoff = (imageFlickable.width / 2 + imageFlickable.contentX) * scale / prevScale;
                        imageFlickable.contentX = xoff - imageFlickable.width / 2
                    }
                    if ((height * scale) > imageFlickable.height) {
                        var yoff = (imageFlickable.height / 2 + imageFlickable.contentY) * scale / prevScale;
                        imageFlickable.contentY = yoff - imageFlickable.height / 2
                    }
                    prevScale = scale
                }

                NumberAnimation {
                    id: loadedAnimation

                    target: imagePreview
                    property: "opacity"
                    duration: 250
                    from: 0; to: 1
                    easing.type: Easing.InOutQuad
                }
            }
        }

        PinchArea {
            id: pinchArea

            property real minScale: 0.5//最小比例
            property real maxScale: 3.0//最大比例

            anchors.fill: parent
            enabled: imagePreview.status === Image.Ready
            pinch.target: imagePreview
            pinch.minimumScale: minScale * 0.5 // This is to create "bounce back effect"
            pinch.maximumScale: maxScale * 1.5 // when over zoomed

            onPinchFinished: {
                imageFlickable.returnToBounds()
                if (imagePreview.scale < pinchArea.minScale) {
                    bounceBackAnimation.to = pinchArea.minScale
                    bounceBackAnimation.start()
                }
                else if (imagePreview.scale > pinchArea.maxScale) {
                    bounceBackAnimation.to = pinchArea.maxScale
                    bounceBackAnimation.start()
                }
            }

            NumberAnimation {
                id: bounceBackAnimation
                target: imagePreview
                duration: 250
                property: "scale"
                from: imagePreview.scale
            }
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                image_zoom.opacity = 0
                timerClose.start()
            }
        }
        MouseArea {
            id: mouseArea
            width: imagePreview.width* imagePreview.scale
            height: imagePreview.height*imagePreview.scale
            y:parent.height/2-height/2+imageFlickable.contentY
            x:parent.width/2-width/2+imageFlickable.contentX
            enabled: imagePreview.status === Image.Ready

            onDoubleClicked: {
                if (Math.ceil(imagePreview.scale) != Math.ceil(Math.min(imageFlickable.width / imagePreview.width, imageFlickable.height / imagePreview.height,1))){
                    bounceBackAnimation.to = Math.min(imageFlickable.width / imagePreview.width, imageFlickable.height / imagePreview.height,1)
                    bounceBackAnimation.start()
                } else if (imagePreview.scale<Math.min(imageFlickable.width / imagePreview.width, imageFlickable.height / imagePreview.height,1)) {
                    bounceBackAnimation.to = Math.min(imageFlickable.width / imagePreview.width, imageFlickable.height / imagePreview.height,1)
                    bounceBackAnimation.start()
                } else {
                    bounceBackAnimation.to = pinchArea.maxScale
                    bounceBackAnimation.start()
                }
            }

            onClicked: {
                if(save.opacity===1)
                    save.opacity=0
                else
                    save.opacity=1
            }
        }

        Connections{
            target: imagePreview
            onScaleChanged:{
                save.opacity=0           ///
            }                                        ///
        }                                            ///
        Connections{                                 ///图片移动或者缩放时停止计时
            target: imageFlickable                ///
            onMovementStarted:{                           ///
                save.opacity=0           ///
            }
        }
    }

    ScrollDecorator {
        flickableItem: imageFlickable
    }

    Image{
        id:save
        z:1
        anchors.bottom: parent.bottom
        anchors.bottomMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/images/save_button_shadow.png"

        Behavior on opacity{
            NumberAnimation{
                duration: 200
            }
        }
        Image{
            source: "qrc:/images/save_button.svg"
            anchors.centerIn: parent
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                saveButtonClicked(imagePreview)
            }
        }
    }
}
