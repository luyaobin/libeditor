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
                spacing: 10

                TextField {
                    id: serialPortField

                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    placeholderText: "串口号"
                    text: serial.settings.portName
                    onEditingFinished: {
                        // 保存串口号到配置文件
                        serial.settings.portName = text;
                    }

                    background: Rectangle {
                        color: "#ffffff"
                        border.color: parent.focus ? "#409EFF" : "#dcdfe6"
                        border.width: parent.focus ? 2 : 1
                        radius: 4
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "模块仓库"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36
                    onClicked: {
                        editorLabelModify.open();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#3a7ab3" : (parent.hovered ? "#5ba0f2" : "#4a90e2")
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 13
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Microsoft YaHei"
                    }
                }

                Button {
                    text: "选择模块"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36
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
                        color: parent.pressed ? "#3a7ab3" : (parent.hovered ? "#5ba0f2" : "#4a90e2")
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 13
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Microsoft YaHei"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 45
                color: "#f8f9fa"
                radius: 4
                border.color: "#e9ecef"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: "模块详情"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                        font.family: "Microsoft YaHei"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: moduleData.uuid
                        font.pixelSize: 11
                        color: "#6c757d"
                        elide: Text.ElideMiddle
                        Layout.maximumWidth: 120
                        font.family: "Consolas"
                    }
                }
            }

            // // 模块信息表单
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 8

                // 模块代码
                Text {
                    text: "模块代码:"
                    font.pixelSize: 14
                    color: "#495057"
                    font.family: "Microsoft YaHei"
                    font.weight: Font.Medium
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

                    background: Rectangle {
                        color: parent.enabled ? "#ffffff" : "#f5f7fa"
                        border.color: parent.focus ? "#409EFF" : "#dcdfe6"
                        border.width: parent.focus ? 2 : 1
                        radius: 4
                    }
                }

                // 模块名称
                Text {
                    text: "模块名称:"
                    font.pixelSize: 14
                    color: "#495057"
                    font.family: "Microsoft YaHei"
                    font.weight: Font.Medium
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

                    background: Rectangle {
                        color: parent.enabled ? "#ffffff" : "#f5f7fa"
                        border.color: parent.focus ? "#409EFF" : "#dcdfe6"
                        border.width: parent.focus ? 2 : 1
                        radius: 4
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

                    background: Rectangle {
                        color: parent.enabled ? "#ffffff" : "#f5f7fa"
                        border.color: parent.focus ? "#409EFF" : "#dcdfe6"
                        border.width: parent.focus ? 2 : 1
                        radius: 4
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

                    background: Rectangle {
                        color: "#ffffff"
                        border.color: parent.focus ? "#409EFF" : "#dcdfe6"
                        border.width: parent.focus ? 2 : 1
                        radius: 4
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

                    background: Rectangle {
                        color: "#ffffff"
                        border.color: parent.focus ? "#409EFF" : "#dcdfe6"
                        border.width: parent.focus ? 2 : 1
                        radius: 4
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

                    background: Rectangle {
                        color: "#ffffff"
                        border.color: parent.focus ? "#409EFF" : "#dcdfe6"
                        border.width: parent.focus ? 2 : 1
                        radius: 4
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
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
