import QtQml.Models 2.14 // 使用此导入来支持 DelegateModelGroup
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

// 如果需要处理图片粘贴可以在这里添加相应的代码

ColumnLayout {
    spacing: 10

    property bool banSave: true

    // 工具栏
    Rectangle {
        Layout.fillWidth: true
        height: 50
        color: "#f8f9fa"
        border.color: "#dee2e6"
        border.width: 1
        radius: 6

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
                text: "模块操作"
                font.pixelSize: 14
                font.bold: true
                color: "#495057"
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: "护套仓库"
                implicitHeight: 32
                onClicked: {
                    console.log("打开护套仓库");
                }

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

            Button {
                text: "粘贴背景"
                implicitHeight: 32
                onClicked: moduleArea.pasteBackground()

                background: Rectangle {
                    color: parent.hovered ? "#0056b3" : "#007bff"
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

            Button {
                text: "背景左转"
                implicitHeight: 32
                onClicked: moduleArea.leftTransparent()

                background: Rectangle {
                    color: parent.hovered ? "#138496" : "#17a2b8"
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

            Button {
                text: "背景右转"
                implicitHeight: 32
                onClicked: moduleArea.rightTransparent()

                background: Rectangle {
                    color: parent.hovered ? "#138496" : "#17a2b8"
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

    // 主要内容区域
    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 10

        // 模块区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 2
            color: "#ffffff"
            border.color: "#dee2e6"
            border.width: 1
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "模块视图"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#495057"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: moduleData.meta || "未命名模块"
                        font.pixelSize: 12
                        color: "#6c757d"
                    }
                }

                ModuleArea {
                    id: moduleArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    points: moduleData.points
                    backgroundSource: moduleData.base64 || ""
                    isEditing: true

                    onPointSelected: function (index) {
                        console.log("模块区域选中点位:", index);
                        pointsArea.currentPointIndex = index;
                    }

                    onPointDeleted: function (index) {
                        console.log("删除点位:", index);
                        if (typeof moduleData.deletePoint === "function") {
                            moduleData.deletePoint(index);
                        }
                    }

                    onPointAdded: function (x, y) {
                        console.log("添加点位:", x, y);
                        if (typeof moduleData.addPoint === "function") {
                            moduleData.addPoint(x, y, "点位" + (moduleData.points.count + 1));
                        }
                    }

                    onPointMoved: function (index, x, y) {
                        console.log("移动点位:", index, x, y);
                        if (typeof moduleData.movePoint === "function") {
                            moduleData.movePoint(index, x, y);
                        }
                    }
                }
            }
        }

        // 右侧信息和点位区域
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            spacing: 10

            // 点位列表区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#ffffff"
                border.color: "#dee2e6"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

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
                        Button {
                            text: "×"
                            implicitWidth: 20
                            implicitHeight: 20
                            onClicked: pointsArea.pointDeleted(0)

                            background: Rectangle {
                                color: parent.hovered ? "#dc3545" : "#6c757d"
                                radius: 10
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
                        Text {
                            text: "共 " + (moduleData.points ? moduleData.points.count : 0) + " 个"
                            font.pixelSize: 12
                            color: "#6c757d"
                        }
                    }

                    PointsArea {
                        id: pointsArea
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        points: moduleData.points
                        isEditing: true

                        onPointSelected: function (index) {
                            console.log("点位列表选中点位:", index);
                            moduleArea.currentPointIndex = index;
                        }

                        onPointDeleted: function (index) {
                            console.log("从列表删除点位:", index);
                            if (typeof moduleData.deletePoint === "function") {
                                moduleData.deletePoint(index);
                            } else {
                                if (Array.isArray(moduleData.points))
                                    moduleData.points.splice(index, 1);
                            }
                        }

                        onPointMoved: function (fromIndex, toIndex) {
                            console.log("点位拖拽移动:", fromIndex, "->", toIndex);
                            if (typeof moduleData.movePointInList === "function") {
                                moduleData.movePointInList(fromIndex, toIndex);
                            } else {
                                // 兼容处理：手动移动数组元素
                                if (Array.isArray(moduleData.points) && fromIndex !== toIndex) {
                                    var points = moduleData.points;
                                    var item = points.splice(fromIndex, 1)[0];
                                    points.splice(toIndex, 0, item);
                                    // 触发数据更新
                                    if (typeof moduleData.dataChanged === "function") {
                                        moduleData.dataChanged();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 状态栏
    Rectangle {
        Layout.fillWidth: true
        height: 30
        color: "#e9ecef"
        radius: 4

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 15

            Text {
                text: "模块: " + (moduleData.code || "未知")
                font.pixelSize: 11
                color: "#495057"
            }

            Text {
                text: "点位: " + (moduleData.points ? moduleData.points.count : 0)
                font.pixelSize: 11
                color: "#495057"
            }

            Text {
                text: "引脚: " + (moduleData.ioNum || 0)
                font.pixelSize: 11
                color: "#495057"
            }

            Text {
                text: "锁片: " + (moduleData.lockNum || 0)
                font.pixelSize: 11
                color: "#495057"
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "编辑模式"
                font.pixelSize: 11
                color: "#28a745"
                font.bold: true
            }
        }
    }

    // 数据绑定函数
    function updateFields() {
        banSave = true;
        metaTextField.text = moduleData.meta || "";
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
