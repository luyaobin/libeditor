import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

Rectangle {
    id: pointsArea

    property var points: []
    property bool isEditing: true
    property int currentPointIndex: -1

    signal pointSelected(int index)
    signal pointDeleted(int index)
    signal pointMoved(int fromIndex, int toIndex)

    color: "#f8f9fa"
    border.color: "#dee2e6"
    border.width: 1
    radius: 4

    ListView {
        id: pointsListView

        anchors.fill: parent
        anchors.margins: 5
        spacing: 4
        clip: true
        model: points

        // 启用拖拽重新排序
        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                easing.type: Easing.OutQuad
                duration: 200
            }
        }

        delegate: Rectangle {
            id: delegateItem

            property bool held: false
            width: pointsListView.width - 10
            height: 50
            color: pointsArea.currentPointIndex === index ? "#e3f2fd" : (held ? "#fff3cd" : (index % 2 === 0 ? "#ffffff" : "#f8f9fa"))
            border.color: held ? "#ffc107" : (pointsArea.currentPointIndex === index ? "#2196f3" : "#dee2e6")
            border.width: held ? 2 : (pointsArea.currentPointIndex === index ? 2 : 1)
            radius: 4

            // 拖拽时的阴影效果（简化版，不使用DropShadow）
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: "#00000020"
                border.width: held ? 3 : 0
                radius: 4
                z: -1
            }

            states: State {
                when: delegateItem.held
                PropertyChanges {
                    target: delegateItem
                    z: 10
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // 拖拽手柄
                    Rectangle {
                        width: 20
                        height: 30
                        color: "transparent"
                        visible: pointsArea.isEditing

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Repeater {
                                model: 3
                                Rectangle {
                                    width: 12
                                    height: 2
                                    color: "#6c757d"
                                    radius: 1
                                }
                            }
                        }
                    }

                    // 点位序号
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        color: pointsArea.currentPointIndex === index ? "#2196f3" : "#6c757d"

                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: "white"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    // 点位信息
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: (model.name && model.name !== "") ? model.name : "点位" + (index + 1)
                            font.pixelSize: 12
                            font.bold: true
                            color: "#212529"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "坐标: (" + Math.round(model.rx || 0) + ", " + Math.round(model.ry || 0) + ")"
                            font.pixelSize: 10
                            color: "#6c757d"
                            Layout.fillWidth: true
                        }
                    }

                    // 脚位标签
                    Rectangle {
                        width: tagText.width + 8
                        height: tagText.height + 4
                        color: "#e9ecef"
                        radius: 8
                        visible: moduleData.tags && moduleData.tags.count > index

                        Text {
                            id: tagText
                            anchors.centerIn: parent
                            text: moduleData.tags && moduleData.tags.count > index ? moduleData.tags.get(index).tag : ""
                            font.pixelSize: 9
                            color: "#495057"
                            font.bold: true
                        }
                    }

                    // 删除按钮
                    Button {
                        visible: pointsArea.isEditing && !delegateItem.held
                        text: "×"
                        implicitWidth: 20
                        implicitHeight: 20
                        onClicked: pointsArea.pointDeleted(index)

                        background: Rectangle {
                            color: parent.hovered ? "#dc3545" : "#6c757d"
                            radius: 10
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }

            MouseArea {
                id: dragArea
                anchors.fill: parent
                anchors.rightMargin: pointsArea.isEditing ? 30 : 0

                drag.target: pointsArea.isEditing ? delegateItem : null
                drag.axis: Drag.YAxis

                onClicked: {
                    if (!delegateItem.held) {
                        pointsArea.currentPointIndex = index;
                        pointsArea.pointSelected(index);
                    }
                }

                onPressAndHold: {
                    if (pointsArea.isEditing) {
                        delegateItem.held = true;
                    }
                }

                onReleased: {
                    if (delegateItem.held) {
                        delegateItem.held = false;

                        // 计算拖拽到的新位置
                        var itemHeight = delegateItem.height + pointsListView.spacing;
                        var listY = delegateItem.y + pointsListView.contentY;
                        var newIndex = Math.floor((listY + delegateItem.height / 2) / itemHeight);
                        newIndex = Math.max(0, Math.min(newIndex, pointsListView.count - 1));

                        if (newIndex !== index) {
                            console.log("移动点位从", index, "到", newIndex);
                            pointsArea.pointMoved(index, newIndex);
                        }

                        // 重置位置
                        delegateItem.x = 0;
                        delegateItem.y = 0;
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
            width: 6

            contentItem: Rectangle {
                implicitWidth: 4
                implicitHeight: 100
                radius: 2
                color: parent.pressed ? "#495057" : "#6c757d"
            }

            background: Rectangle {
                color: "#f8f9fa"
                radius: 2
            }
        }
    }

    // 空状态提示
    Rectangle {
        anchors.centerIn: parent
        width: 200
        height: 80
        color: "#ffffff"
        border.color: "#dee2e6"
        border.width: 1
        radius: 6
        visible: pointsListView.count === 0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "📍"
                font.pixelSize: 24
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "暂无点位数据"
                color: "#6c757d"
                font.pixelSize: 12
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "双击模块视图添加点位"
                color: "#adb5bd"
                font.pixelSize: 10
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // 拖拽提示
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 8
        width: dragHintText.width + 12
        height: dragHintText.height + 6
        color: "#343a40"
        radius: 3
        visible: pointsArea.isEditing && pointsListView.count > 1

        Text {
            id: dragHintText
            anchors.centerIn: parent
            text: "长按拖拽重新排序"
            color: "white"
            font.pixelSize: 9
        }
    }
}
