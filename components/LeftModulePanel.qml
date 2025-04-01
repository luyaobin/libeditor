import QtGraphicalEffects 1.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: leftPanel

    property var modulesModel
    property var currentModule
    property color primaryColor: "#2196F3"
    property color textColor: "#333333"
    property color surfaceColor: "#FFFFFF"
    property var onModuleSelected
    property var onAddModule

    color: surfaceColor
    radius: 8
    // 添加阴影效果
    layer.enabled: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // 标题栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "模块库"
                color: textColor
                Layout.fillWidth: true

                font {
                    pixelSize: 18
                    bold: true
                }

            }

            Button {
                text: "+"
                font.pixelSize: 18
                onClicked: {
                    if (onAddModule)
                        onAddModule();

                }

                background: Rectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 16
                    color: primaryColor

                    // 悬停效果
                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: "white"
                        opacity: parent.parent.hovered ? 0.2 : 0
                    }

                }

                contentItem: Text {
                    text: "+"
                    color: "white"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

            }

        }

        // 模块列表
        ListView {
            id: moduleListView

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: modulesModel
            spacing: 10

            delegate: ItemDelegate {
                width: parent.width
                height: 80
                onClicked: {
                    if (onModuleSelected)
                        onModuleSelected(modulesModel.get(index));

                }

                background: Rectangle {
                    color: "white"
                    radius: 6
                    border.color: currentModule && currentModule.id === model.id ? primaryColor : "#E0E0E0"
                    border.width: currentModule && currentModule.id === model.id ? 2 : 1

                    // 悬停效果
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: primaryColor
                        opacity: parent.parent.hovered ? 0.1 : 0
                    }

                }

                contentItem: ColumnLayout {
                    spacing: 8
                    anchors.margins: 10

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true

                        Label {
                            text: code || "未命名"
                            font.pixelSize: 14
                            font.bold: true
                            color: textColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Label {
                            text: name || "无描述"
                            font.pixelSize: 12
                            color: "#666666"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "点位数量: " + (points ? points.length : 0)
                            font.pixelSize: 12
                            color: "#666666"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                    }

                }

            }

            // 滚动条样式
            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
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
