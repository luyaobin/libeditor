import QtGraphicalEffects 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: moduleInfoView

    property bool banSave: false

    Connections {
        function onSelectFinishedChanged(module) {
            banSave = true;
            codeTextField.text = module.code;
            nameTextField.text = module.name;
            ioNumSpinBox.value = module.ioNum;
            airCheckBox.checked = module.airNum === 1;
            strValueTextField.text = module.strValue;
            banSave = false;
        }

        //enabled: bool
        //ignoreUnknownSignals: bool
        //target: Object
        target: moduleData
    }

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
                    id: codeTextField

                    Layout.fillWidth: true
                    text: ""
                    placeholderText: "请输入模块代码"
                    onTextChanged: {
                        if (banSave)
                            return ;

                        moduleData.code = text;
                        moduleData.dataChanged();
                    }
                }

                // 模块名称
                Text {
                    text: "模块名称:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                TextField {
                    id: nameTextField

                    Layout.fillWidth: true
                    text: ""
                    placeholderText: "请输入模块名称"
                    onTextChanged: {
                        if (banSave)
                            return ;

                        moduleData.name = text;
                        moduleData.dataChanged();
                    }
                }
                // 模块名称

                Text {
                    text: "起点点位:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                TextField {
                    id: strValueTextField

                    Layout.fillWidth: true
                    text: moduleData.strValue
                    placeholderText: "请输入字符串值"
                    onTextChanged: {
                        if (banSave)
                            return ;

                        moduleData.strValue = text;
                        moduleData.dataChanged();
                    }
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
                            if (count === 1 && autoFillCheckBox.checked)
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

                    CheckBox {
                        id: autoFillCheckBox

                        anchors.right: parent.right
                        text: "探点自动填入"
                        onCheckedChanged: {
                            if (checked && serial.probeListModel.count === 1)
                                moduleData.strValue = serial.probeListModel.get(0).chunk;

                        }
                    }

                }

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
                                text: tag
                                font.pixelSize: 12
                            }

                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("点击了");
                            const tags = [];
                            for (let i = 0; i < moduleData.tags.count; i++) {
                                tags.push(moduleData.tags.get(i).tag);
                            }
                            editorTagModify.setCallback(tags.join("\n"), function(data) {
                                const tagsResult = data.split("\n");
                                const models = [];
                                console.log("tags", tagsResult);
                                for (let i = 0; i < tagsResult.length; i++) {
                                    console.log("tags[i]", tagsResult[i]);
                                    models.push({
                                        "tag": tagsResult[i]
                                    });
                                }
                                moduleData.tags.clear();
                                moduleData.tags.append(models);
                                console.log("moduleData.tags", moduleData.tags.count);
                                moduleData.dataChanged();
                            });
                            editorTagModify.open();
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

                        Button {
                            text: "粘贴背景"
                            onClicked: {
                                moduleArea.pasteBackground();
                            }
                        }

                        Button {
                            text: "背景左转"
                            onClicked: {
                                moduleArea.leftTransparent();
                            }
                        }

                        Button {
                            text: "背景右转"
                            onClicked: {
                                moduleArea.rightTransparent();
                            }
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

                Text {
                    text: "引脚数量:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                Row {
                    Layout.fillWidth: true
                    spacing: 10

                    SpinBox {
                        id: ioNumSpinBox

                        width: parent.width - addPointButton.width - pointCountText.width - 15
                        value: moduleData.ioNum
                        from: 0
                        to: 99
                        editable: true
                        onValueChanged: {
                            if (banSave)
                                return ;

                            moduleData.ioNum = value;
                            moduleData.dataChanged();
                        }

                        background: Rectangle {
                            width: parent.width
                            implicitHeight: 32
                            color: "#f5f7fa"
                            border.color: parent.focus ? "#409EFF" : "#dcdfe6"
                            border.width: parent.focus ? 2 : 1
                            radius: 6
                            // 添加轻微阴影效果
                            layer.enabled: parent.focus

                            layer.effect: DropShadow {
                                horizontalOffset: 0
                                verticalOffset: 1
                                radius: 4
                                samples: 8
                                color: "#20000000"
                            }

                        }

                        contentItem: TextInput {
                            text: parent.textFromValue(parent.value, parent.locale)
                            color: "#333333"
                            selectByMouse: true
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter

                            font {
                                pixelSize: 14
                                family: "Microsoft YaHei"
                            }

                        }

                    }

                    Text {
                        id: pointCountText

                        text: "实际数量: " + (moduleData.points ? moduleData.points.count : 0)
                        color: "#555555"
                        anchors.verticalCenter: parent.verticalCenter

                        font {
                            pixelSize: 14
                            family: "Microsoft YaHei"
                        }

                    }

                    Button {
                        id: addPointButton

                        text: "删除尾点"
                        implicitHeight: 32
                        onClicked: {
                            moduleData.deletePoint();
                        }

                        background: Rectangle {
                            color: parent.hovered ? "#f56c6c" : "#fa8c8c"
                            radius: 6

                            // 添加按钮悬停效果
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            font {
                                pixelSize: 14
                                family: "Microsoft YaHei"
                                bold: true
                            }

                        }

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
                        model: 7

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
                                    moduleData.dataChanged();
                                }
                            }

                        }

                    }

                    Row {
                        spacing: 5

                        Text {
                            text: "气密存在:"
                            font.pixelSize: 14
                            color: "#555555"
                            font.family: "Microsoft YaHei"
                            leftPadding: 5
                            verticalAlignment: Text.AlignVCenter
                        }

                        CheckBox {
                            id: airCheckBox

                            checked: false
                            onCheckedChanged: {
                                if (banSave)
                                    return ;

                                moduleData.airNum = checked ? 1 : 0;
                                moduleData.dataChanged();
                            }
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

                        PointsArea {
                            id: pointsArea

                            anchors.fill: parent
                            anchors.margins: 5
                            points: moduleData.points
                            isEditing: true
                            // 处理点位选择
                            onPointSelected: function(index) {
                                // 可以在这里实现选中点位的处理逻辑
                                console.log("选中点位:", index);
                                // 同步选中状态到ModuleArea
                                moduleArea.currentPointIndex = index;
                            }
                            // 处理点位删除
                            onPointDeleted: function(index) {
                                // 使用moduleData的deletePoint函数删除点位
                                if (typeof moduleData.deletePoint === "function") {
                                    moduleData.deletePoint(index);
                                } else {
                                    // 兼容旧代码，直接操作数组
                                    if (Array.isArray(moduleData.points))
                                        moduleData.points.splice(index, 1);

                                }
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
