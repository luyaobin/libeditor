import QtGraphicalEffects 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: moduleInfoView

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        radius: 5
        border.color: "#e0e0e0"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 20

            // 标题部分
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#f8f8f8"
                radius: 5

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Text {
                        text: "模块详情"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333333"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: moduleData.uuid
                        font.pixelSize: 12
                        color: "#999999"
                        elide: Text.ElideMiddle
                        Layout.maximumWidth: 150
                    }

                }

            }

            // 模块信息表单
            GridLayout {
                // 字符串值

                Layout.fillWidth: true
                columns: 2
                columnSpacing: 15
                rowSpacing: 15

                // 模块代码
                Text {
                    text: "模块代码:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                TextField {
                    Layout.fillWidth: true
                    text: moduleData.code
                    placeholderText: "请输入模块代码"
                    onTextChanged: moduleData.code = text
                }

                // 模块名称
                Text {
                    text: "模块名称:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                TextField {
                    Layout.fillWidth: true
                    text: moduleData.name
                    placeholderText: "请输入模块名称"
                    onTextChanged: moduleData.name = text
                }
                // 模块名称

                Text {
                    text: "点位代号:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    color: "#f0f7ff"
                    border.color: "#c0d7ff"
                    border.width: 1
                    radius: 4

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("点击了");
                        }
                    }

                    ListView {
                        anchors.fill: parent
                        model: moduleData.tags
                        orientation: ListView.Horizontal
                        spacing: 5
                        clip: true

                        delegate: Rectangle {
                            height: 30
                            width: 80
                            radius: 4
                            color: "#f0f7ff"
                            border.color: "#c0d7ff"

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 12
                            }

                        }

                    }

                }

                Text {
                    text: "引脚数量:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                SpinBox {
                    Layout.fillWidth: true
                    value: moduleData.ioNum
                    from: 0
                    to: 99
                    editable: true
                    onValueChanged: moduleData.ioNum = value

                    background: Rectangle {
                        // 移除了导致绑定循环的 implicitWidth: parent.width
                        width: parent.width
                        implicitHeight: 30
                        color: "#f5f7fa"
                        border.color: parent.focus ? "#4a90e2" : "#c0c4cc"
                        border.width: parent.focus ? 2 : 1
                        radius: 4
                    }

                    contentItem: TextInput {
                        text: parent.textFromValue(parent.value, parent.locale)
                        font.pixelSize: 14
                        color: "#333333"
                        selectByMouse: true
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                    }

                }
                // 引脚数量

                Text {
                    text: "锁片对数:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                Row {
                    Layout.fillWidth: true
                    spacing: 5

                    Repeater {
                        model: 10

                        delegate: Rectangle {
                            width: 30
                            height: 30
                            color: index === moduleData.lockNum ? "#c0d7ff" : "#f0f7ff"
                            border.color: "#c0d7ff"
                            border.width: 1
                            radius: 4

                            Text {
                                anchors.centerIn: parent
                                text: index
                                font.pixelSize: 12
                                color: index === moduleData.lockNum ? "#333333" : "#999999"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    moduleData.lockNum = index;
                                }
                            }

                        }

                    }

                }

                Text {
                    text: "起点点位:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                TextField {
                    Layout.fillWidth: true
                    text: moduleData.strValue
                    placeholderText: "请输入字符串值"
                    onTextChanged: moduleData.strValue = text
                }
                // 探针数据显示区域

                Text {
                    text: "探点数据:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                Item {
                    Layout.fillWidth: true
                    height: 32

                    ListView {
                        anchors.fill: parent
                        model: serial.probeListModel
                        orientation: ListView.Horizontal
                        spacing: 5
                        clip: true
                        onCountChanged: {
                            console.log("探针数据列表数量:", count);
                            if (count === 1)
                                moduleData.strValue = serial.probeListModel.get(0).chunk;

                        }

                        delegate: Rectangle {
                            height: 30
                            width: 80
                            radius: 4
                            color: "#f0f7ff"
                            border.color: "#c0d7ff"

                            Text {
                                anchors.centerIn: parent
                                text: model.chunk
                                font.pixelSize: 12
                            }

                        }

                    }

                }

                Item {
                    Layout.fillWidth: true
                    height: 32
                    Layout.columnSpan: 2

                    RowLayout {
                        anchors.fill: parent
                        spacing: 5

                        // 实际点位, 理论点位
                        Text {
                            text: "实际点位:"
                        }

                        Text {
                            text: "理论点位:"
                        }

                    }

                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.columnSpan: 2

                    Rectangle {
                        anchors.fill: parent
                        color: "#f0f7ff"
                        border.color: "#c0d7ff"
                        border.width: 1
                        radius: 4

                        ModuleArea {
                            id: moduleArea

                            anchors.fill: parent
                            points: moduleData.points
                        }

                    }

                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.columnSpan: 2

                    Rectangle {
                        anchors.fill: parent
                        color: "#f0f7ff"
                        border.color: "#c0d7ff"
                        border.width: 1
                        radius: 4

                        ListView {
                            // 这里可以添加初始数据

                            id: pointsListView

                            anchors.fill: parent
                            anchors.margins: 10
                            clip: true
                            model: moduleData.points

                            delegate: Rectangle {
                                width: parent.width
                                height: 40
                                color: index % 2 === 0 ? "#f8f8f8" : "#ffffff"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    spacing: 10

                                    Text {
                                        text: "点位" + (index + 1)
                                        font.pixelSize: 14
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "X: " + (model.rx || 0) + ", Y: " + (model.ry || 0)
                                        font.pixelSize: 12
                                        color: "#666666"
                                    }

                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        pointsListView.currentIndex = index;
                                    }
                                }

                            }

                            ScrollBar.vertical: ScrollBar {
                            }

                        }

                    }

                }

            }

            Item {
                Layout.fillHeight: true
            }

        }

    }

}
