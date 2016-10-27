// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

QtObject {
    id: qtobject

    property string json
    property variant memberfilter: ["objectName", "json", "memberfilter"]

    function jsObject2QObject(qtobject, jsobject) {
        var propertys = Object.getOwnPropertyNames(jsobject);

        for (var i in propertys) {
            var p = propertys[i];

            if (!qtobject.hasOwnProperty(p))
                continue;

            if (qtobject[p].toString().match(/^QObject_QML_/)) {
                jsObject2QObject(qtobject[p], jsobject[p]);
            } else {
                qtobject[p] = jsobject[p];
            }
        }
    }

    Component.onCompleted: {
        if (!json)
            return

        var object = JSON.parse(json);

        if (object)
            jsObject2QObject(qtobject, object)
    }

    Component.onDestruction: {
        var propertys = Object.getOwnPropertyNames(qtobject);
        var object = new Object()

        for (var i in propertys) {
            var p = propertys[i]

            if (memberfilter.indexOf(p) < 0 && !String(p).match(/Changed$/))
                object[p] = qtobject[p]
        }

        json = JSON.stringify(object)
    }
}
