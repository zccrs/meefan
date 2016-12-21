QT += network script webkit
CONFIG += c++11 mobility
MOBILITY = feedback

TARGET = meefan
VERSION = 0.0.1

DEFINES += CONSUMER_KEY=\\\"$${CONSUMER_KEY}\\\" CONSUMER_SECRET=\\\"$${CONSUMER_SECRET}\\\"

# Add more folders to ship with the application, here
folder_01.source = qml/meefan
folder_01.target = qml

folder_js.source = qml/js
folder_js.target = qml

zhihu.source = qml/zhihu
zhihu.target = qml

DEPLOYMENTFOLDERS = folder_01 folder_js zhihu

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:TARGET.UID3 = 0xE3FFDC9B

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
CONFIG += qdeclarative-boostable

# Add dependency to Symbian components
# CONFIG += qt-components

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    src/fanfoukit.cpp \
    src/httprequest.cpp \
    src/monitormouseevent.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

# Splash For MeeGo
contains(MEEGO_EDITION, harmattan){
    message(harmattan build)
    DEFINES += Q_OS_HARMATTAN

    splash.files = splash.png
    splash.path = /opt/$${TARGET}/data

    export(splash.files)
    export(splash.path)

    INSTALLS += splash
}

# Lib oauth
include($$PWD/src/oauth/oauth.pri)
include($$PWD/src/mywidgets/mywidgets.pri)

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qml/js/FanFouAPI.js \
    qml/js/FanFouService.js \
    qml/zhihu/NewsListPage.qml

HEADERS += \
    src/fanfoukit.h \
    src/httprequest.h \
    src/monitormouseevent.h

INCLUDEPATH += $$PWD/src

RESOURCES += \
    images.qrc \
    translate.qrc

TRANSLATIONS += $$PWD/$${TARGET}_zh_CN.ts

simulator {
    DEFINES += QML_ROOT_PATH=\\\"$${OUT_PWD}/qml/\\\"
}

contains(MEEGO_EDITION, harmattan) {
    DEFINES += QML_ROOT_PATH=\\\"/opt/$${TARGET}/qml/\\\"
}
