import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Item {
    id: moduleInfoView

    property bool banSave: true

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        radius: 6
        border.color: "#dee2e6"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8

            // 标题部分
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#f8f9fa"
                radius: 6
                border.color: "#dee2e6"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Text {
                        text: "模块详情"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#212529"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: moduleData.uuid
                        font.pixelSize: 11
                        color: "#6c757d"
                        elide: Text.ElideMiddle
                        Layout.maximumWidth: 150
                    }
                }
            }

            // 模块信息表单
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 12

                // 模块型号
                Text {
                    text: "模块型号:"
                    font.pixelSize: 14
                    color: "#495057"
                    font.bold: true
                }

                TextField {
                    id: metaTextField
                    Layout.fillWidth: true
                    text: ""
                    placeholderText: "请输入模块型号"
                    onTextChanged: {
                        if (banSave)
                            return;
                        moduleData.meta = text;
                        moduleData.dataChanged();
                    }

                    background: Rectangle {
                        color: "#ffffff"
                        border.color: parent.focus ? "#007bff" : "#ced4da"
                        border.width: parent.focus ? 2 : 1
                        radius: 4
                    }
                }

                // 引脚数量
                Text {
                    text: "引脚数量:"
                    font.pixelSize: 14
                    color: "#495057"
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: false

                    SpinBox {
                        id: ioNumSpinBox
                        Layout.preferredWidth: 120
                        value: moduleData.ioNum
                        from: 0
                        to: 99
                        editable: true
                        onValueChanged: {
                            if (banSave)
                                return;
                            moduleData.ioNum = value;
                            moduleData.dataChanged();
                        }

                        background: Rectangle {
                            implicitHeight: 32
                            color: "#ffffff"
                            border.color: parent.focus ? "#007bff" : "#ced4da"
                            border.width: parent.focus ? 2 : 1
                            radius: 4
                        }

                        contentItem: TextInput {
                            text: parent.textFromValue(parent.value, parent.locale)
                            color: "#212529"
                            selectByMouse: true
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text: "实际数量: " + (moduleData.points ? moduleData.points.count : 0)
                        color: "#6c757d"
                        font.pixelSize: 12
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "删除尾点"
                        implicitHeight: 32
                        onClicked: moduleData.deletePoint()

                        background: Rectangle {
                            color: parent.hovered ? "#c82333" : "#dc3545"
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }

                // 锁片对数
                Text {
                    text: "锁片对数:"
                    font.pixelSize: 14
                    color: "#495057"
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: 7

                        delegate: Rectangle {
                            width: 32
                            height: 32
                            color: index === moduleData.lockNum ? "#007bff" : "#f8f9fa"
                            border.color: index === moduleData.lockNum ? "#0056b3" : "#dee2e6"
                            border.width: index === moduleData.lockNum ? 2 : 1
                            radius: 4

                            Text {
                                anchors.centerIn: parent
                                text: index
                                font.pixelSize: 12
                                font.bold: true
                                color: index === moduleData.lockNum ? "white" : "#495057"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    moduleData.lockNum = index;
                                    moduleData.dataChanged();
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        spacing: 8

                        Text {
                            text: "气密存在:"
                            font.pixelSize: 14
                            color: "#495057"
                            font.bold: true
                        }

                        CheckBox {
                            id: airCheckBox
                            checked: false
                            onCheckedChanged: {
                                if (banSave)
                                    return;
                                moduleData.airNum = checked ? 1 : 0;
                                moduleData.dataChanged();
                            }
                        }
                    }
                }
            }

            // 点位列表区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#f8f9fa"
                border.color: "#dee2e6"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    // 点位列表标题
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "点位列表"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#495057"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "共 " + (moduleData.points ? moduleData.points.count : 0) + " 个点位"
                            font.pixelSize: 12
                            color: "#6c757d"
                        }
                    }

                    // 点位列表
                    PointsArea {
                        id: pointsArea
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        points: moduleData.points
                        isEditing: true

                        onPointSelected: function (index) {
                            console.log("选中点位:", index);
                        }

                        onPointDeleted: function (index) {
                            if (typeof moduleData.deletePoint === "function") {
                                moduleData.deletePoint(index);
                            } else {
                                if (Array.isArray(moduleData.points))
                                    moduleData.points.splice(index, 1);
                            }
                        }
                    }
                }
            }
        }
    }

    // 数据绑定函数
    function updateFields() {
        banSave = true;
        metaTextField.text = moduleData.meta || "";
        strLightTextField.text = moduleData.strLight || "";
        strValueTextField.text = moduleData.strValue || "";
        ioNumSpinBox.value = moduleData.ioNum || 0;
        airCheckBox.checked = moduleData.airNum === 1;
        banSave = false;
    }

    // 监听模块数据变化
    Connections {
        target: moduleData
        function onDataChanged() {
            updateFields();
        }
    }

    Component.onCompleted: {
        updateFields();
    }
}
