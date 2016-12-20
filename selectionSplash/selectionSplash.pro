CONFIG += console

TARGET = selectionSplash
VERSION = 0.0.1

SOURCES += $$PWD/main.cpp

contains(MEEGO_EDITION,harmattan) {
    target.path = /opt/meefan/bin
    INSTALLS += target
}
