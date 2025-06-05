import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.14
import QtQuick.LocalStorage 2.14
import QtQuick.Window 2.14
import "./warehouse"

Page {
    // 直接使用原始模型

    id: mainPage

    Component.onCompleted: {
        console.log("MainPage onCompleted");
        const size = librariesModel.moduleModel.count;
        if (size === 0)
            librariesModel.addModule();

        console.log("MainPage onCompleted", librariesModel.moduleModel.count);
        const module = librariesModel.moduleModel.get(0);
        console.log("MainPage onCompleted tags", module.tags);
        moduleData.selectModule(module, 0);
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1

            IndexPage {
                anchors.fill: parent
            }
        }

        // Item {
        //     Layout.fillWidth: true
        //     Layout.fillHeight: true
        //     Layout.preferredWidth: 3

        //     ModuleLayout {
        //         anchors.fill: parent
        //     }
        // }
    }

    EditorLabelModify {
        id: editorLabelModify

        anchors.centerIn: parent
    }

    EditorTagModify {
        id: editorTagModify

        anchors.centerIn: parent
    }
}
