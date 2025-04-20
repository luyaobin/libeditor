import QtGraphicalEffects 1.0
import QtQml.Models 2.14 // 使用此导入来支持 DelegateModelGroup
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Item {
    id: librariesView

    // 显示列表
    ListView {
        id: libraryListView

        currentIndex: 0
        anchors.fill: parent
        model: librariesModel.moduleModel
        clip: true
        spacing: 5
        focus: true
        orientation: ListView.Horizontal // 设置为横向布局

        delegate: Rectangle {
            id: delegateItem

            width: 200 // 设置固定宽度
            height: libraryListView.height // 高度填充ListView
            color: libraryListView.currentIndex === index ? "#f0f7ff" : (index % 2 === 0 ? "#ffffff" : "#f9f9f9")
            radius: 5
            border.color: "#e0e0e0"
            border.width: 1
            // 添加阴影效果
            layer.enabled: true

            // 改为纵向布局
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 60
                    height: 60
                    radius: 30
                    color: "#4a90e2"

                    Text {
                        anchors.centerIn: parent
                        text: code.substring(0, 1)
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: code
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: name
                        font.pixelSize: 14
                        color: "#666666"
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    libraryListView.currentIndex = index;
                    moduleData.selectModule(model);
                }
            }

            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 1
                radius: 3
                samples: 7
                color: "#20000000"
            }

            // 添加鼠标悬停效果
            states: State {
                name: "hovered"
                when: mouseArea.containsMouse

                PropertyChanges {
                    target: delegateItem
                    color: "#e8f4ff"
                }
            }
        }

        // 改为水平滚动条
        ScrollBar.horizontal: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
            height: 10

            contentItem: Rectangle {
                implicitHeight: 6
                implicitWidth: 100
                radius: 3
                color: parent.pressed ? "#606060" : "#909090"
            }
        }
    }
}
