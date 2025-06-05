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

            // 模块信息编辑区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 280
                color: "#ffffff"
                border.color: "#dee2e6"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Text {
                        text: "模块详情"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#495057"
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 8

                            // 模块型号
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "模块型号:"
                                    font.pixelSize: 12
                                    color: "#495057"
                                    font.bold: true
                                    Layout.preferredWidth: 70
                                }

                                TextField {
                                    id: metaTextField
                                    Layout.fillWidth: true
                                    readOnly: true
                                    text: ""
                                    placeholderText: "请输入模块型号"
                                    font.pixelSize: 11
                                    // onTextChanged: {
                                    //     if (banSave)
                                    //         return;
                                    //     moduleData.meta = text;
                                    //     moduleData.dataChanged();
                                    // }

                                    background: Rectangle {
                                        color: "#ffffff"
                                        border.color: parent.focus ? "#007bff" : "#ced4da"
                                        border.width: 1
                                        radius: 3
                                    }
                                }
                            }

                            // 引脚数量
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                visible: false
                                Text {
                                    text: "引脚数量:"
                                    font.pixelSize: 12
                                    color: "#495057"
                                    font.bold: true
                                    Layout.preferredWidth: 70
                                }

                                SpinBox {
                                    id: ioNumSpinBox
                                    Layout.preferredWidth: 100
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
                                        implicitHeight: 28
                                        color: "#ffffff"
                                        border.color: parent.focus ? "#007bff" : "#ced4da"
                                        border.width: 1
                                        radius: 3
                                    }

                                    contentItem: TextInput {
                                        text: parent.textFromValue(parent.value, parent.locale)
                                        color: "#212529"
                                        selectByMouse: true
                                        horizontalAlignment: Qt.AlignHCenter
                                        verticalAlignment: Qt.AlignVCenter
                                        font.pixelSize: 11
                                    }
                                }

                                Text {
                                    text: "实际: " + (moduleData.points ? moduleData.points.count : 0)
                                    color: "#6c757d"
                                    font.pixelSize: 10
                                    Layout.fillWidth: true
                                }

                                Button {
                                    text: "删除尾点"
                                    implicitHeight: 28
                                    implicitWidth: 70
                                    onClicked: moduleData.deletePoint()

                                    background: Rectangle {
                                        color: parent.hovered ? "#c82333" : "#dc3545"
                                        radius: 3
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }

                            // 锁片对数
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "锁片对数:"
                                    font.pixelSize: 12
                                    color: "#495057"
                                    font.bold: true
                                    Layout.preferredWidth: 70
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Repeater {
                                        model: 7

                                        delegate: Rectangle {
                                            width: 24
                                            height: 24
                                            color: index === moduleData.lockNum ? "#007bff" : "#f8f9fa"
                                            border.color: index === moduleData.lockNum ? "#0056b3" : "#dee2e6"
                                            border.width: 1
                                            radius: 3

                                            Text {
                                                anchors.centerIn: parent
                                                text: index
                                                font.pixelSize: 10
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
                                }
                            }

                            // 气密存在
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "气密存在:"
                                    font.pixelSize: 12
                                    color: "#495057"
                                    font.bold: true
                                    Layout.preferredWidth: 70
                                }

                                CheckBox {
                                    id: airCheckBox
                                    checked: false
                                    text: "存在气密"
                                    font.pixelSize: 11
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
                }
            }

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
