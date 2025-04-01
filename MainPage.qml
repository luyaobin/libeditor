import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.15
import QtQuick.LocalStorage 2.15
import QtQuick.Window 2.15
import qmlcpplib.qmlsystem 1.0

Page {
    id: mainPage

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1

            Libraries {
                anchors.fill: parent
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1

            ModuleInfo {
                anchors.fill: parent
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 2
        }

    }

    EditorLabelModify {
        id: editorLabelModify

        anchors.centerIn: parent
    }

}
