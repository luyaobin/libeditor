import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Item {
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // 标题栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: "#fff3e0"

                Text {
                    anchors.centerIn: parent
                    text: "⚙"
                    font.pixelSize: 14
                }
            }

            Text {
                text: "模块详情"
                font.pixelSize: 18
                font.bold: true
                color: "#333333"
                font.family: "Microsoft YaHei"
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 16

                // 模块型号
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "模块型号:"
                        font.pixelSize: 14
                        color: "#333333"
                        font.bold: true
                        font.family: "Microsoft YaHei"
                        Layout.preferredWidth: 90
                        Layout.alignment: Qt.AlignTop
                    }

                    TextField {
                        id: metaTextField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        text: ""
                        placeholderText: "请输入模块型号"
                        font.pixelSize: 13
                        font.family: "Microsoft YaHei"
                        verticalAlignment: TextInput.AlignVCenter

                        onTextChanged: {
                            if (moduleDetailPopup.banSave || !moduleDetailPopup.currentModule)
                                return;
                            moduleDetailPopup.currentModule.meta = text;
                            if (typeof moduleDetailPopup.currentModule.dataChanged === "function") {
                                moduleDetailPopup.currentModule.dataChanged();
                            }
                        }

                        background: Rectangle {
                            color: "#ffffff"
                            border.color: parent.focus ? "#409eff" : "#dcdfe6"
                            border.width: parent.focus ? 2 : 1
                            radius: 6
                        }
                    }
                }

                // 模块位置
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "模块位置:"
                        font.pixelSize: 14
                        color: "#333333"
                        font.bold: true
                        font.family: "Microsoft YaHei"
                        Layout.preferredWidth: 90
                        Layout.alignment: Qt.AlignTop
                    }

                    TextField {
                        id: siteTextField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        text: ""
                        placeholderText: "请输入模块位置(可不填)"
                        font.pixelSize: 13
                        font.family: "Microsoft YaHei"
                        verticalAlignment: TextInput.AlignVCenter

                        onTextChanged: {
                            if (banSave)
                                return;

                            moduleData.site = text;
                            moduleData.dataChanged();
                        }

                        background: Rectangle {
                            color: "#ffffff"
                            border.color: parent.focus ? "#409eff" : "#dcdfe6"
                            border.width: parent.focus ? 2 : 1
                            radius: 6
                        }
                    }
                }

                // 模块灯号
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "模块灯号:"
                        font.pixelSize: 14
                        color: "#333333"
                        font.bold: true
                        font.family: "Microsoft YaHei"
                        Layout.preferredWidth: 90
                        Layout.alignment: Qt.AlignTop
                    }

                    TextField {
                        id: strLightTextField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        text: ""
                        placeholderText: "请输入模块灯号(可忽略)"
                        font.pixelSize: 13
                        font.family: "Microsoft YaHei"
                        verticalAlignment: TextInput.AlignVCenter

                        onTextChanged: {
                            if (banSave)
                                return;

                            moduleData.strLight = text;
                            moduleData.dataChanged();
                        }

                        background: Rectangle {
                            color: "#ffffff"
                            border.color: parent.focus ? "#409eff" : "#dcdfe6"
                            border.width: parent.focus ? 2 : 1
                            radius: 6
                        }
                    }
                }

                // 锁片对数
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "锁片对数:"
                        font.pixelSize: 14
                        color: "#333333"
                        font.bold: true
                        font.family: "Microsoft YaHei"
                        Layout.preferredWidth: 90
                        Layout.alignment: Qt.AlignVCenter
                    }

                    SpinBox {
                        id: lockNumSpinBox
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 36
                        from: 0
                        to: 6
                        value: moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.lockNum || 0 : 0
                        font.pixelSize: 13
                        font.family: "Microsoft YaHei"

                        onValueChanged: {
                            if (moduleDetailPopup.banSave || !moduleDetailPopup.currentModule)
                                return;
                            moduleDetailPopup.currentModule.lockNum = value;
                            if (typeof moduleDetailPopup.currentModule.dataChanged === "function") {
                                moduleDetailPopup.currentModule.dataChanged();
                            }
                        }

                        background: Rectangle {
                            color: "#ffffff"
                            border.color: parent.focus ? "#409eff" : "#dcdfe6"
                            border.width: parent.focus ? 2 : 1
                            radius: 6
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                // 气密存在
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "气密存在:"
                        font.pixelSize: 14
                        color: "#333333"
                        font.bold: true
                        font.family: "Microsoft YaHei"
                        Layout.preferredWidth: 90
                        Layout.alignment: Qt.AlignVCenter
                    }

                    CheckBox {
                        id: airCheckBox
                        checked: false
                        text: "存在气密"
                        font.pixelSize: 13
                        font.family: "Microsoft YaHei"

                        onCheckedChanged: {
                            if (moduleDetailPopup.banSave || !moduleDetailPopup.currentModule)
                                return;
                            moduleDetailPopup.currentModule.airNum = checked ? 1 : 0;
                            if (typeof moduleDetailPopup.currentModule.dataChanged === "function") {
                                moduleDetailPopup.currentModule.dataChanged();
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                // 探点数据
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    Layout.alignment: Qt.AlignTop

                    Text {
                        text: "探点数据:"
                        font.pixelSize: 14
                        color: "#333333"
                        font.bold: true
                        font.family: "Microsoft YaHei"
                        Layout.preferredWidth: 90
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: 8
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        color: "#f8f9fa"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 6

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 8
                            model: serial.probeListModel
                            orientation: ListView.Horizontal
                            spacing: 8
                            clip: true

                            onCountChanged: {
                                console.log("探针数据列表数量:", count);
                                if (count === 1 && autoFillCheckBox.checked)
                                    strValueTextField.text = serial.probeListModel.get(0).chunk;
                            }

                            delegate: Rectangle {
                                height: 28
                                width: 88
                                radius: 14
                                color: "#e3f2fd"
                                border.color: "#2196f3"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: model.chunk
                                    font.pixelSize: 11
                                    font.family: "Microsoft YaHei"
                                    color: "#1976d2"
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // 标题和操作按钮行
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        Text {
                            text: "点位调整:"
                            font.pixelSize: 14
                            color: "#333333"
                            font.bold: true
                            font.family: "Microsoft YaHei"
                            Layout.preferredWidth: 90
                        }

                        Button {
                            text: "添加点位"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32

                            onClicked: {
                                startPointModel.append({
                                    "index": startPointModel.count // 内部索引从0开始
                                    ,
                                    "seek": ""
                                });
                            }

                            background: Rectangle {
                                color: parent.hovered ? "#67c23a" : "#85ce61"
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 11
                                font.family: "Microsoft YaHei"
                                font.bold: true
                            }
                        }

                        Button {
                            text: "删除点位"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            enabled: startPointModel.count > 1

                            onClicked: {
                                // 删除最后一项
                                if (startPointModel.count > 1) {
                                    startPointModel.remove(startPointModel.count - 1);
                                    updateStartPointData();
                                }
                            }

                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#f56c6c" : "#fa8c8c") : "#d3d3d3"
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "white" : "#999999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 11
                                font.family: "Microsoft YaHei"
                                font.bold: true
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    // 起点列表
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Repeater {
                            id: startPointRepeater
                            model: ListModel {
                                id: startPointModel
                                ListElement {
                                    index: 0
                                    seek: ""
                                }
                            }

                            delegate: RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Text {
                                    text: "点位"
                                    font.pixelSize: 12
                                    color: "#666666"
                                    font.family: "Microsoft YaHei"
                                    Layout.preferredWidth: 60
                                }

                                TextField {
                                    id: indexField
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 32
                                    text: (model.index + 1).toString()
                                    placeholderText: "序号"
                                    font.pixelSize: 12
                                    font.family: "Microsoft YaHei"
                                    verticalAlignment: TextInput.AlignVCenter

                                    onTextChanged: {
                                        if (banSave)
                                            return;
                                        var displayIndex = parseInt(text) || 1;
                                        if (displayIndex < 1)
                                            displayIndex = 1;
                                        var actualIndex = displayIndex - 1; // 转换为内部索引（从0开始）
                                        startPointModel.setProperty(index, "index", actualIndex);
                                        updateStartPointData();
                                    }

                                    background: Rectangle {
                                        color: "#ffffff"
                                        border.color: parent.focus ? "#409eff" : "#dcdfe6"
                                        border.width: 1
                                        radius: 4
                                    }
                                }

                                TextField {
                                    id: seekField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32
                                    text: model.seek
                                    placeholderText: "硬件编号(1-1-1)"
                                    font.pixelSize: 12
                                    font.family: "Microsoft YaHei"
                                    verticalAlignment: TextInput.AlignVCenter

                                    onTextChanged: {
                                        if (banSave)
                                            return;
                                        startPointModel.setProperty(index, "seek", text);
                                        updateStartPointData();
                                    }

                                    background: Rectangle {
                                        color: "#ffffff"
                                        border.color: parent.focus ? "#409eff" : "#dcdfe6"
                                        border.width: 1
                                        radius: 4
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 更新起点数据的函数
    function updateStartPointData() {
        if (banSave)
            return;

        var startPoints = [];
        for (var i = 0; i < startPointModel.count; i++) {
            var item = startPointModel.get(i);
            startPoints.push({
                index: item.index,
                seek: item.seek
            });
        }

        // 将数据保存到模块数据中
        if (typeof moduleData !== "undefined") {
            moduleData.startPoints = JSON.stringify(startPoints);
            moduleData.dataChanged();
        }

        console.log("起点数据更新:", JSON.stringify(startPoints));
    }
}
