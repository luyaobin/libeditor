QT += sql quick gui printsupport serialport network opengl websockets quickcontrols2
CONFIG += c++11
#CONFIG += console

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler)
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0


SOURCES += \
        $$PWD/main.cpp

SOURCES += \
    $$PWD/aes.cpp \
    $$PWD/caes.cpp \
    $$PWD/qmlfileopt.cpp \
    $$PWD/qmlregister.cpp \
    $$PWD/qmlserial.cpp \


HEADERS += \
    $$PWD/aes.h \
    $$PWD/caes.h \
    $$PWD/qmlfileopt.h \
    $$PWD/qmlregister.h \
    $$PWD/qmlserial.h \

LIBS += -luser32
LIBS += -lwinspool

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
