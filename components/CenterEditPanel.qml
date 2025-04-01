import QtGraphicalEffects 1.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: centerPanel

    property var currentModule
    property color primaryColor: "#2196F3"
    property color textColor: "#333333"
    property color surfaceColor: "#FFFFFF"
    property var onSaveModule
    property alias codeField: codeField
    property alias nameField: nameField
    property alias startPointField: startPointField
    property alias lightNumberField: lightNumberField
    property alias pinCountField: pinCountField
    property alias lockCountField: lockCountField
    property alias sealCountField: sealCountField

    color: surfaceColor
    radius: 8
    // 添加阴影效果
    layer.enabled: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // 基本信息编辑
        GroupBox {
            title: "基本信息"
            Layout.fillWidth: true

            GridLayout {
                columns: 2
                rowSpacing: 10
                columnSpacing: 10
                width: parent.width

                Label {
                    text: "模块代号:"
                    color: textColor
                }

                TextField {
                    id: codeField

                    Layout.fillWidth: true

                    background: Rectangle {
                        radius: 4
                        border.color: parent.activeFocus ? primaryColor : "#E0E0E0"
                        border.width: parent.activeFocus ? 2 : 1
                    }

                }

                Label {
                    text: "模块名称:"
                    color: textColor
                }

                TextField {
                    id: nameField

                    Layout.fillWidth: true

                    background: Rectangle {
                        radius: 4
                        border.color: parent.activeFocus ? primaryColor : "#E0E0E0"
                        border.width: parent.activeFocus ? 2 : 1
                    }

                }

                Label {
                    text: "模块起点:"
                    color: textColor
                }

                TextField {
                    id: startPointField

                    Layout.fillWidth: true

                    background: Rectangle {
                        radius: 4
                        border.color: parent.activeFocus ? primaryColor : "#E0E0E0"
                        border.width: parent.activeFocus ? 2 : 1
                    }

                }

                Label {
                    text: "模块灯号:"
                    color: textColor
                }

                TextField {
                    id: lightNumberField

                    Layout.fillWidth: true

                    background: Rectangle {
                        radius: 4
                        border.color: parent.activeFocus ? primaryColor : "#E0E0E0"
                        border.width: parent.activeFocus ? 2 : 1
                    }

                }

                Label {
                    text: "引脚数:"
                    color: textColor
                }

                SpinBox {
                    id: pinCountField

                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: 0

                    background: Rectangle {
                        radius: 4
                        border.color: parent.activeFocus ? primaryColor : "#E0E0E0"
                        border.width: parent.activeFocus ? 2 : 1
                    }

                }

                Label {
                    text: "锁片数:"
                    color: textColor
                }

                SpinBox {
                    id: lockCountField

                    Layout.fillWidth: true
                    from: 0
                    to: 9
                    value: 0

                    background: Rectangle {
                        radius: 4
                        border.color: parent.activeFocus ? primaryColor : "#E0E0E0"
                        border.width: parent.activeFocus ? 2 : 1
                    }

                }

                Label {
                    text: "气密数:"
                    color: textColor
                }

                SpinBox {
                    id: sealCountField

                    Layout.fillWidth: true
                    from: 0
                    to: 9
                    value: 0

                    background: Rectangle {
                        radius: 4
                        border.color: parent.activeFocus ? primaryColor : "#E0E0E0"
                        border.width: parent.activeFocus ? 2 : 1
                    }

                }

            }

            background: Rectangle {
                color: "transparent"
                border.color: "#E0E0E0"
                radius: 6
            }

            label: Label {
                text: parent.title
                color: textColor
                font.bold: true
                font.pixelSize: 14
                padding: 10
            }

        }

        // 保存按钮
        Button {
            text: "保存更改"
            Layout.fillWidth: true
            enabled: currentModule !== null
            onClicked: {
                if (onSaveModule)
                    onSaveModule();

            }

            background: Rectangle {
                implicitHeight: 40
                radius: 6
                color: parent.enabled ? (parent.hovered ? Qt.lighter(primaryColor, 1.1) : primaryColor) : "#BDBDBD"
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

    }

    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 2
        radius: 8
        samples: 17
        color: "#20000000"
    }

}
