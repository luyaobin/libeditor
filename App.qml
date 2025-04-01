import QtQuick 2.14
import QtQuick.Controls 2.0
import QtQuick.Window 2.14

Window {
    visible: true
    Component.onCompleted: {
        try {
            if (isNotQmlsence) {
                width = 1920;
                height = 1040;
            }
        } catch (error) {
            const i = 1;
            width = Qt.application.screens[i].width;
            height = Qt.application.screens[i].height;
            flags = Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint;
            x = Qt.application.screens[i].virtualX; //+ width * 1.5;
            y = Qt.application.screens[i].virtualY;
        }
        visible = true;
    }

    MainPage {
        id: mainPage

        anchors.fill: parent
    }

    Shortcut {
        sequence: "Ctrl+Return"
        onActivated: set.checked = !set.checked
    }

    Shortcut {
        sequence: "Ctrl+Enter"
        onActivated: Qt.quit()
    }

    Shortcut {
        sequence: "Ctrl+Alt+M"
        onActivated: Qt.quit()
    }

}
