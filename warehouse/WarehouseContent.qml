import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.14
import QtQuick.LocalStorage 2.14
import QtQuick.Window 2.14

Rectangle {
    id: warehouseContent
    color: "#ffffff"
    radius: 8
    border.color: "#dee2e6"
    border.width: 1

    Component.onCompleted: {
        console.log("WarehouseContent onCompleted");
        const size = librariesModel.moduleModel.count;
        if (size === 0)
            librariesModel.addModule();

        console.log("WarehouseContent onCompleted", librariesModel.moduleModel.count);
        const module = librariesModel.moduleModel.get(0);
        console.log("WarehouseContent onCompleted tags", module.tags);
        moduleData.selectModule(module, 0);
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // 模块库区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            Layout.maximumWidth: 300
            color: "#f8f9fa"
            radius: 6
            border.color: "#dee2e6"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "模块库"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#495057"
                }

                Libraries {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }

        // 模块编辑区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 3
            color: "#f8f9fa"
            radius: 6
            border.color: "#dee2e6"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "模块编辑"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#495057"
                }

                ModuleLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
