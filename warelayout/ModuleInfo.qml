import QtGraphicalEffects 1.0
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Item {
    id: moduleInfoView

    property bool banSave: true

    Connections {
        function onSelectFinishedChanged(module) {
            banSave = true;
            codeTextField.text = module.code;
            nameTextField.text = module.name;
            metaTextField.text = module.meta;
            siteTextField.text = module.site;
            strLightTextField.text = module.strLight;
            ioNumSpinBox.value = module.ioNum;
            airCheckBox.checked = module.airNum === 1;
            strValueTextField.text = module.strValue;
            banSave = false;
        }

        target: moduleData
    }

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        radius: 5
        border.color: "#e0e0e0"
        border.width: 1

        ColumnLayout {
            // 标题部分

            anchors.fill: parent
            anchors.margins: 15
            spacing: 5

            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                Item {
                    Layout.fillWidth: true
                }

                TextField {
                    id: serialPortField

                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    placeholderText: "串口号"
                    text: serial.settings.portName
                    onEditingFinished: {
                        // 保存串口号到配置文件
                        serial.settings.portName = text;
                    }

                    background: Rectangle {
                        border.color: "#dcdfe6"
                        border.width: 1
                        radius: 4
                    }
                }

                Button {
                    // 显示提示信息

                    text: "列表导入"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40
                    onClicked: {
                        editorLabelModify.open();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#3a7ab3" : "#4a90e2"
                        radius: 5
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    // 显示提示信息

                    text: "导入回路"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40
                    ToolTip.text: "添加模块 (最后一个模块无名称时不允许添加)"
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                    onClicked: {
                        // 检查最后一个模块的名称是否为空
                        const size = librariesModel.moduleModel.count;
                        var lastModule = librariesModel.moduleModel.get(size - 1);
                        if (lastModule && lastModule.name === "")
                            return;

                        // 使用来自librariesModel的方法添加新模块
                        librariesModel.addModule();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#3a7ab3" : "#4a90e2"
                        radius: 5
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    // 显示提示信息

                    text: "模块布局"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40
                    ToolTip.text: "添加模块 (最后一个模块无名称时不允许添加)"
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                    onClicked: {
                        // 检查最后一个模块的名称是否为空
                        const size = librariesModel.moduleModel.count;
                        var lastModule = librariesModel.moduleModel.get(size - 1);
                        if (lastModule && lastModule.name === "")
                            return;

                        // 使用来自librariesModel的方法添加新模块
                        librariesModel.addModule();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#3a7ab3" : "#4a90e2"
                        radius: 5
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

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
                columnSpacing: 5
                rowSpacing: 5

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
                    enabled: false
                    placeholderText: "请输入模块代码"
                    onTextChanged: {
                        if (banSave)
                            return;

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
                    enabled: false
                    placeholderText: "请输入模块名称"
                    onTextChanged: {
                        if (banSave)
                            return;

                        moduleData.name = text;
                        moduleData.dataChanged();
                    }
                }
                // 模块名称

                // 模块代码
                Text {
                    text: "模块型号:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                TextField {
                    id: metaTextField

                    Layout.fillWidth: true
                    text: ""
                    enabled: false
                    placeholderText: "请输入模块型号"
                    onTextChanged: {
                        if (banSave)
                            return;

                        moduleData.meta = text;
                        moduleData.dataChanged();
                    }
                }
                // 模块代码

                Text {
                    text: "模块位置:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                TextField {
                    id: siteTextField

                    Layout.fillWidth: true
                    text: ""
                    placeholderText: "请输入模块位置(可不填)"
                    onTextChanged: {
                        if (banSave)
                            return;

                        moduleData.site = text;
                        moduleData.dataChanged();
                    }
                }
                // 模块代码

                Text {
                    text: "模块灯号:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                TextField {
                    id: strLightTextField

                    Layout.fillWidth: true
                    text: ""
                    placeholderText: "请输入模块灯号(可忽略)"
                    onTextChanged: {
                        if (banSave)
                            return;

                        moduleData.strLight = text;
                        moduleData.dataChanged();
                    }
                }

                Text {
                    text: "起点点位:"
                    font.pixelSize: 14
                    color: "#555555"
                }

                TextField {
                    id: strValueTextField

                    Layout.fillWidth: true
                    text: ""
                    placeholderText: "请输入起点点位(必填)"
                    onTextChanged: {
                        if (banSave)
                            return;

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
                                strValueTextField.text = serial.probeListModel.get(0).chunk;
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

                    Button {
                        id: fillProbeButton

                        anchors.right: autoFillCheckBox.left
                        anchors.rightMargin: 10
                        text: "填入"
                        implicitHeight: 30
                        implicitWidth: 60
                        onClicked: {
                            if (serial.probeListModel.count > 0)
                                strValueTextField.text = serial.probeListModel.get(0).chunk;
                        }

                        background: Rectangle {
                            color: parent.hovered ? "#409EFF" : "#66b1ff"
                            radius: 4

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

                    CheckBox {
                        id: autoFillCheckBox

                        anchors.right: parent.right
                        text: "探点自动填入"
                        onCheckedChanged: {
                            console.log("autoFillCheckBox", checked, serial.probeListModel.count);
                            if (checked && serial.probeListModel.count === 1)
                                strValueTextField.text = serial.probeListModel.get(0).chunk;
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
                }

                Item {
                    Layout.fillWidth: true
                    height: 32
                    Layout.columnSpan: 2

                    ModuleLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.columnSpan: 2
                        moduleData: moduleData
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
                                return;

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
                                    return;

                                moduleData.airNum = checked ? 1 : 0;
                                moduleData.dataChanged();
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
