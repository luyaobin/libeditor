import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.14
import QtQuick.LocalStorage 2.14
import QtQuick.Window 2.14
import "./loopeditor" as LoopEditor
import "../warehouse" as Warehouse
import "../wareproject" as WareProject

// import qmlcpplib.qmlsystem 1.0

Page {
    // 直接使用原始模型

    id: mainPage

    // 程序数据模型
    WareProject.ProgramModel {
        id: programModel

        // onProjectChanged: function (projectName) {
        //     console.log("项目已切换到:", projectName);
        // }

        // onDataLoaded: {
        //     console.log("项目数据加载完成");
        // }

        // onDataError: function (message) {
        //     console.error("数据错误:", message);
        // }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

        // 左侧模块信息面板
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1

            Libraries {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 2
            }
            ListError {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 1
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 3

            ModuleLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 2
            }

            Item {

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 1
                LoopEditor.IndexPage {
                    anchors.fill: parent
                }
            }
        }
    }

    // 仓库管理弹窗
    Popup {
        id: warehousePopup
        anchors.centerIn: parent
        width: parent.width * 0.95
        height: parent.height * 0.95
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: "#f8f9fa"
            radius: 8
            border.color: "#dee2e6"
            border.width: 2
        }

        // 禁用动画效果

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            // 标题栏
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#ffffff"
                border.color: "#dee2e6"
                border.width: 1
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    // 仓库图标
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: "#007bff"

                        Text {
                            anchors.centerIn: parent
                            text: "📦"
                            font.pixelSize: 16
                            color: "white"
                        }
                    }

                    Text {
                        text: "仓库管理"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#495057"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "按 ESC 键返回"
                        font.pixelSize: 10
                        color: "#6c757d"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Button {
                        text: "返回"
                        implicitWidth: 80
                        implicitHeight: 32
                        onClicked: warehousePopup.close()

                        background: Rectangle {
                            color: parent.hovered ? "#5a6268" : "#6c757d"
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 12
                        }
                    }
                }
            }

            // 仓库管理内容
            Warehouse.WarehouseContent {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    // 模块选择器组件
    ModuleSelect {
        id: moduleSelectionPopup

        onModuleSelected: function (module) {
            const success = projects.addModuleToProject(module);
            if (success) {
                console.log("模块添加成功");
            } else {
                console.log("模块添加失败或已存在");
            }
        }

        onSelectionCancelled: {
            console.log("取消模块选择");
        }
    }
}
