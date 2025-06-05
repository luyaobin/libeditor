import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.14
import QtQuick.LocalStorage 2.14
import QtQuick.Window 2.14

// import qmlcpplib.qmlsystem 1.0

Page {
    // 直接使用原始模型

    id: mainPage

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

        // 左侧模块信息面板
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
            Layout.preferredWidth: 3
            ModuleLayout {
                anchors.fill: parent
            }
        }
    }
}
