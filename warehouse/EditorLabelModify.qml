import QtGraphicalEffects 1.0
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Popup {
    id: selectLabelPopup

    anchors.centerIn: parent
    width: parent.width * 0.7
    height: parent.height * 0.8
    padding: 0
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Rectangle {
        width: selectLabelPopup.width
        height: selectLabelPopup.height
        border.color: "#dcdfe6"
        border.width: 2
        color: "#ffffff"
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 15

            // 标题栏
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#409EFF"
                radius: 6

                Text {
                    anchors.centerIn: parent
                    text: "批量导入模块"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#ffffff"
                }

            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 10
                spacing: 20

                ColumnLayout {
                    // 模块名称标题

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 4
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        color: "#f2f6fc"
                        radius: 4

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            text: "模块列表（每行一个模块，格式：模块型号,模块代码,模块名称,引脚数量,锁片数量,存在气密）"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#606266"
                        }

                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        TextArea {
                            id: namesTextArea

                            width: parent.width
                            wrapMode: TextInput.WrapAnywhere
                            selectByMouse: true
                            font.pixelSize: 14
                            color: "#303133"
                            placeholderText: "请输入模块信息，格式：\nAAA,A001,温度传感器,1,0,0\nBBB,B002,压力传感器,2,1,1\n..."

                            background: Rectangle {
                                color: "transparent"
                            }

                        }

                        background: Rectangle {
                            border.color: "#dcdfe6"
                            border.width: 1
                            radius: 4
                        }

                    }

                }

            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                Layout.margins: 10
                spacing: 15

                Button {
                    implicitWidth: 100
                    implicitHeight: 36
                    text: "测试数据"
                    onClicked: {
                        namesTextArea.text = "AAA,A001,温度传感器,1,0,0\nBBB,B002,压力传感器,2,1,1";
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#e0e0e0" : "#f0f0f0"
                        border.color: "#dcdfe6"
                        border.width: 1
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "#606266"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }

                Button {
                    text: "取消"
                    implicitWidth: 100
                    implicitHeight: 36
                    onClicked: {
                        selectLabelPopup.close();
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#e0e0e0" : "#f0f0f0"
                        border.color: "#dcdfe6"
                        border.width: 1
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "#606266"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }

                Button {
                    text: "确定导入"
                    implicitWidth: 100
                    implicitHeight: 36
                    onClicked: {
                        // 解析文本并导入模块
                        console.log("导入模块", librariesModel);
                        librariesModel.clear();
                        const codeSet = new Set();
                        const nameSet = new Set();
                        var lines = namesTextArea.text.split('\n');
                        for (var i = 0; i < lines.length; i++) {
                            var line = lines[i].trim();
                            // console.log("line", line);
                            // 如果数据中没有逗号，尝试使用制表符分割
                            if (!line.includes(','))
                                line = line.replace(/\s+/g, ',');

                            console.log("line", line);
                            if (line) {
                                var parts = line.split(',');
                                if (parts.length >= 3) {
                                    var moduleCode = parts[0].trim();
                                    var moduleMeta = parts[1].trim();
                                    var moduleName = parts[2].trim();
                                    if (codeSet.has(moduleCode)) {
                                        console.log("模块代码重复", moduleCode);
                                        continue;
                                    }
                                    if (nameSet.has(moduleName)) {
                                        console.log("模块名称重复", moduleName);
                                        continue;
                                    }
                                    codeSet.add(moduleCode);
                                    nameSet.add(moduleName);
                                    var ioNum = 0;
                                    var airNum = 0;
                                    var lockNum = 0;
                                    if (parts.length >= 4)
                                        ioNum = parseInt(parts[3].trim());

                                    if (parts.length >= 5)
                                        lockNum = parseInt(parts[4].trim());

                                    if (parts.length >= 6)
                                        airNum = parseInt(parts[5].trim());

                                    if (librariesModel) {
                                        var newModule = librariesModel.addModule();
                                        librariesModel.fixModule(i, moduleCode, moduleName, moduleMeta, ioNum, lockNum, airNum);
                                    }
                                }
                            }
                        }
                        console.log("MainPage onCompleted");
                        const size = librariesModel.moduleModel.count;
                        if (size === 0)
                            librariesModel.addModule();

                        console.log("MainPage onCompleted", librariesModel.moduleModel.count);
                        const module = librariesModel.moduleModel.get(0);
                        console.log("MainPage onCompleted tags", module.tags);
                        moduleData.selectModule(module, 0);
                        selectLabelPopup.close();
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#66b1ff" : "#409EFF"
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }

            }

        }

    }

    // 添加背景阴影效果
    background: Rectangle {
        color: "transparent"
        radius: 8
        layer.enabled: true

        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 10
            samples: 17
            color: "#80000000"
        }

    }

    // 添加打开和关闭动画
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 200
        }

        NumberAnimation {
            property: "scale"
            from: 0.9
            to: 1
            duration: 200
        }

    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 150
        }

        NumberAnimation {
            property: "scale"
            from: 1
            to: 0.9
            duration: 150
        }

    }

}
