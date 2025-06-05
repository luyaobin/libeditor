import QtGraphicalEffects 1.0
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Popup {
    id: selectLabelPopup

    property string tagsString: ""
    property var callback: () => {
    }

    function setCallback(data, callback) {
        selectLabelPopup.tagsString = data;
        selectLabelPopup.callback = callback;
    }

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
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 4
                    spacing: 10

                    // 模块名称标题
                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        color: "#f2f6fc"
                        radius: 4

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            text: "引脚列表（格式：引脚代码）"
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
                            text: selectLabelPopup.tagsString
                            placeholderText: "请输入引脚信息，格式：\nA001\nB002\n..."

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
                        selectLabelPopup.callback(namesTextArea.text.split("\n").filter((item) => {
                            return item.trim() !== "";
                        }).join("\n"));
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
