import QtGraphicalEffects 1.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: rightPanel

    property var currentModule
    property color primaryColor: "#2196F3"
    property color secondaryColor: "#4CAF50"
    property color textColor: "#333333"
    property color surfaceColor: "#FFFFFF"
    property alias pointsArea: pointsArea
    property var onSaveModule
    property var onDeleteModule
    property var onDuplicateModule
    property var onExportAll
    property var onImportModules
    property var onExportModule

    color: surfaceColor
    radius: 8
    // 添加阴影效果
    layer.enabled: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "背景和点位编辑"
                font.pixelSize: 18
                font.bold: true
                color: textColor
                Layout.fillWidth: true
            }

            Label {
                text: currentModule ? "编辑模式" : "请选择模块"
                color: currentModule ? secondaryColor : "#999999"
                font.pixelSize: 14
            }

        }

        // 背景图片和点位编辑区域
        PointsArea {
            id: pointsArea

            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.6
        }

        // 在点位列表上方添加一个添加点位的按钮
        Button {
            text: "添加新点位"
            Layout.fillWidth: true
            enabled: currentModule !== null
            onClicked: {
                // 显示添加点位对话框
                addPointDialog.open();
            }

            background: Rectangle {
                implicitHeight: 40
                radius: 6
                color: parent.enabled ? (parent.hovered ? Qt.lighter(secondaryColor, 1.1) : secondaryColor) : "#BDBDBD"
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

        // 点位列表
        GroupBox {
            title: "点位列表"
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                anchors.fill: parent
                model: pointsArea.pointsModel
                clip: true
                spacing: 8

                delegate: RowLayout {
                    width: parent.width
                    height: 36
                    spacing: 8

                    TextField {
                        text: name
                        Layout.preferredWidth: 100
                        onEditingFinished: {
                            pointsArea.pointsModel.setProperty(index, "name", text);
                            if (currentModule && onSaveModule)
                                onSaveModule();

                        }

                        background: Rectangle {
                            radius: 4
                            border.color: parent.activeFocus ? primaryColor : "#E0E0E0"
                            border.width: parent.activeFocus ? 2 : 1
                        }

                    }

                    Label {
                        text: "X:"
                        color: textColor
                    }

                    SpinBox {
                        from: 0
                        to: 1000
                        value: x
                        onValueModified: {
                            pointsArea.pointsModel.setProperty(index, "x", value);
                            if (currentModule && onSaveModule)
                                onSaveModule();

                        }
                    }

                    Label {
                        text: "Y:"
                        color: textColor
                    }

                    SpinBox {
                        from: 0
                        to: 1000
                        value: y
                        onValueModified: {
                            pointsArea.pointsModel.setProperty(index, "y", value);
                            if (currentModule && onSaveModule)
                                onSaveModule();

                        }
                    }

                    Button {
                        text: "删除"
                        onClicked: {
                            pointsArea.pointsModel.remove(index);
                            if (currentModule && onSaveModule)
                                onSaveModule();

                        }

                        background: Rectangle {
                            implicitWidth: 60
                            implicitHeight: 32
                            radius: 4
                            color: parent.hovered ? "#FFE0E0" : "#FFEBEE"
                            border.color: "#E57373"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#D32F2F"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

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

        // 添加删除和更多操作按钮
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: currentModule !== null

            Button {
                text: "删除模块"
                onClicked: {
                    if (currentModule && onDeleteModule)
                        onDeleteModule(currentModule.id);

                }

                background: Rectangle {
                    implicitHeight: 36
                    radius: 6
                    color: parent.hovered ? "#E53935" : "#F44336"
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

            }

            Button {
                text: "复制模块"
                onClicked: {
                    if (currentModule && onDuplicateModule)
                        onDuplicateModule(currentModule.id);

                }

                background: Rectangle {
                    implicitHeight: 36
                    radius: 6
                    color: parent.hovered ? Qt.lighter(secondaryColor, 1.1) : secondaryColor
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

            }

            Button {
                text: "更多操作"
                onClicked: moreActionsMenu.popup()

                Menu {
                    id: moreActionsMenu

                    MenuItem {
                        text: "导出所有模块"
                        onTriggered: {
                            if (onExportAll)
                                onExportAll();

                        }
                    }

                    MenuItem {
                        text: "导入模块数据"
                        onTriggered: {
                            if (onImportModules)
                                onImportModules();

                        }
                    }

                    MenuItem {
                        text: "导出当前模块"
                        enabled: currentModule !== null
                        onTriggered: {
                            if (currentModule && onExportModule)
                                onExportModule(currentModule.id);

                        }
                    }

                }

                background: Rectangle {
                    implicitHeight: 36
                    radius: 6
                    color: parent.hovered ? Qt.lighter(primaryColor, 1.1) : primaryColor
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

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
