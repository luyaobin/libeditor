import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.14
import QtQuick.LocalStorage 2.14
import QtQuick.Window 2.14

Page {
    id: mainPage

    // 设置简洁的背景
    background: Rectangle {
        color: "#f8f9fa"
    }

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

    // 标题栏
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
        color: "#ffffff"
        border.color: "#dee2e6"
        border.width: 1
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // 应用图标
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: "#007bff"

                Text {
                    anchors.centerIn: parent
                    text: "📦"
                    font.pixelSize: 20
                    color: "white"
                }
            }

            // 标题
            Text {
                text: "智能仓储管理系统"
                font.pixelSize: 22
                font.bold: true
                color: "#212529"
                Layout.fillWidth: true
            }

            // 状态指示器
            Rectangle {
                width: 80
                height: 30
                radius: 15
                color: "#28a745"
                border.color: "#1e7e34"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "在线"
                    font.pixelSize: 12
                    font.bold: true
                    color: "white"
                }
            }
        }
    }

    // 主内容区域
    Rectangle {
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        anchors.topMargin: 10

        color: "#ffffff"
        radius: 8
        border.color: "#dee2e6"
        border.width: 1

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

            // 模块编辑区域（包含原来的布局和信息）
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
}
