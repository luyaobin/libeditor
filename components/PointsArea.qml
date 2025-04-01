import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property alias pointsModel: pointsModel
    property alias backgroundSource: backgroundImage.source
    property bool hasBackground: backgroundImage.source != ""
    property bool isEditing: true

    signal pointAdded(string name, int x, int y)
    signal pointMoved(int index, int x, int y)
    signal backgroundChanged(string source)

    color: "#F5F5F5"

    Image {
        id: backgroundImage

        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        visible: source != ""
    }

    // 点位显示
    Repeater {
        id: pointsRepeater

        model: ListModel {
            id: pointsModel
        }

        delegate: Rectangle {
            width: 10
            height: 10
            radius: 5
            color: "red"
            border.color: "black"
            border.width: 1
            x: model.x ? model.x - 5 : 0
            y: model.y ? model.y - 5 : 0

            // 显示点位名称
            Text {
                text: model.name
                anchors.bottom: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 10
                color: "blue"
            }

            // 拖动功能
            MouseArea {
                anchors.fill: parent
                drag.target: parent
                drag.axis: Drag.XAndY
                enabled: root.isEditing
                onReleased: {
                    if (root.isEditing) {
                        // 更新点位坐标
                        var newX = parseInt(parent.x + 5);
                        var newY = parseInt(parent.y + 5);
                        pointsModel.setProperty(index, "x", newX);
                        pointsModel.setProperty(index, "y", newY);
                        root.pointMoved(index, newX, newY);
                    }
                }
            }

        }

    }

    // 拖放区域
    DropArea {
        anchors.fill: parent
        onDropped: {
            if (drop.hasUrls) {
                var url = drop.urls[0];
                if (url.toString().toLowerCase().match(/\.(jpg|jpeg|png|gif|bmp)$/)) {
                    console.log("接收到图片文件:", url);
                    backgroundImage.source = url.toString();
                    root.hasBackground = true;
                    root.backgroundChanged(url.toString());
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "拖放图片或使用Ctrl+V粘贴"
        color: "#999999"
        visible: !backgroundImage.source
    }

    // 点击添加点位
    MouseArea {
        anchors.fill: parent
        enabled: root.isEditing
        onClicked: {
            if (root.isEditing) {
                // 添加新点位
                var pointName = "点位" + (pointsModel.count + 1);
                pointsModel.append({
                    "name": pointName,
                    "x": parseInt(mouseX),
                    "y": parseInt(mouseY)
                });
                root.pointAdded(pointName, parseInt(mouseX), parseInt(mouseY));
            }
        }
    }

}
