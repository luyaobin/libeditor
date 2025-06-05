import QtQuick 2.14
import QtQuick.Controls 2.14

Rectangle {
    id: listErrorRoot
    color: "#f8f9fa"
    border.color: "#dee2e6"
    border.width: 1
    radius: 6

    // 标题栏
    Rectangle {
        id: headerRect
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        color: "#ffffff"
        border.color: "#dee2e6"
        border.width: 1
        radius: 6

        Text {
            anchors.centerIn: parent
            text: "错误列表"
            font.pixelSize: 14
            font.bold: true
            color: "#495057"
        }
    }

    // 列表视图
    ListView {
        id: errorListView
        anchors.top: headerRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        spacing: 4
        clip: true

        model: ["连接超时", "数据解析错误", "设备未响应", "权限不足", "网络异常", "配置文件损坏", "内存不足", "文件读取失败", "端口占用", "版本不兼容"]

        delegate: Rectangle {
            width: errorListView.width
            height: 36
            color: mouseArea.containsMouse ? "#fff3cd" : "#ffffff"
            border.color: "#ffeaa7"
            border.width: 1
            radius: 4

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // 错误图标
                Rectangle {
                    width: 16
                    height: 16
                    color: "#dc3545"
                    radius: 8
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "!"
                        color: "white"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }

                // 错误信息
                Text {
                    text: "错误 " + (index + 1) + ": " + modelData
                    font.pixelSize: 12
                    color: "#495057"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // 时间戳
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "12:3" + index + ":0" + (index % 6)
                font.pixelSize: 10
                color: "#6c757d"
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    console.log("点击错误项:", index, modelData);
                }
            }
        }

        // 滚动条
        ScrollBar.vertical: ScrollBar {
            width: 8
            policy: ScrollBar.AsNeeded

            background: Rectangle {
                color: "#f8f9fa"
                radius: 4
            }

            contentItem: Rectangle {
                color: "#6c757d"
                radius: 4
            }
        }
    }

    // 空状态提示
    Item {
        anchors.centerIn: errorListView
        visible: errorListView.count === 0

        Column {
            anchors.centerIn: parent
            spacing: 8

            Rectangle {
                width: 48
                height: 48
                color: "#28a745"
                radius: 24
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                }
            }

            Text {
                text: "暂无错误"
                font.pixelSize: 14
                color: "#6c757d"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
