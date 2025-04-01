import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: pointsArea

    property var points: []
    property bool isEditing: true

    signal pointSelected(int index)
    signal pointDeleted(int index)

    color: "#F5F5F5"
    border.color: "#e0e0e0"
    border.width: 1
    radius: 4

    ListView {
        id: pointsListView

        anchors.fill: parent
        anchors.margins: 5
        spacing: 5
        clip: true
        model: points

        delegate: Rectangle {
            width: pointsListView.width - 10
            height: 40
            color: index % 2 === 0 ? "#f8f8f8" : "#ffffff"
            border.color: pointsListView.currentIndex === index ? "#4a90e2" : "transparent"
            border.width: 1
            radius: 3

            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 10

                Text {
                    text: (model.name) ? model.name : "点位" + (index + 1)
                    font.pixelSize: 14
                    color: "#333333"
                    Layout.fillWidth: true
                }

                Text {
                    text: "X: " + (model.rx || 0) + ", Y: " + (model.ry || 0)
                    font.pixelSize: 12
                    color: "#666666"
                }

                Button {
                    visible: pointsArea.isEditing
                    text: "删除"
                    implicitWidth: 60
                    implicitHeight: 30
                    onClicked: {
                        pointsArea.pointDeleted(index);
                    }
                }

            }

            MouseArea {
                anchors.fill: parent
                anchors.rightMargin: pointsArea.isEditing ? 70 : 0 // 避免与删除按钮冲突
                onClicked: {
                    pointsListView.currentIndex = index;
                    pointsArea.pointSelected(index);
                }
            }

        }

        ScrollBar.vertical: ScrollBar {
        }

    }

    // 如果没有点位，显示提示信息
    Text {
        anchors.centerIn: parent
        text: "暂无点位数据"
        color: "#999999"
        font.pixelSize: 14
        visible: pointsListView.count === 0
    }

    // 添加点位按钮
    Button {
        visible: isEditing
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        text: "+"
        width: 40
        height: 40
        font.pixelSize: 20
        onClicked: {
            // 创建一个函数用于添加新点位，可以与ModuleArea联动
            if (Array.isArray(points)) {
                // 如果是数组，添加到数组
                const newPoint = {
                    "name": "点位" + (points.length + 1),
                    "rx": 50,
                    "ry": 50
                };
                if (typeof points.push === "function")
                    points.push(newPoint);

            } else if (typeof points.count === "number") {
                // 如果是ListModel，调用append
                if (typeof points.append === "function")
                    points.append({
                        "name": "点位" + (points.count + 1),
                        "rx": 50,
                        "ry": 50
                    });

            }
        }
    }

}
