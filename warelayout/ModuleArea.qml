import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import qmlcpplib.qmlsystem 1.0

Rectangle {
    id: moduleArea

    property var points: []
    property alias backgroundSource: backgroundImage.source
    property bool hasBackground: backgroundImage.source != ""
    property bool isEditing: true
    property bool isDraggingPoint: false
    property int currentPointIndex: -1

    signal pasteBackground
    signal leftTransparent
    signal rightTransparent
    signal pointAdded(string name, int x, int y)
    signal pointMoved(int index, int x, int y)
    signal backgroundChanged(string source)

    onPasteBackground: {
        qmlSystem.ctrlV();
        backgroundImage.source = qmlSystem.image;
        moduleData.base64 = qmlSystem.image;
        moduleData.dataChanged();
        moduleArea.hasBackground = true;
    }
    color: "#F5F5F5"
    // 粘贴功能
    Keys.onPressed: function (event) {
        if ((event.key === Qt.Key_V) && (event.modifiers & Qt.ControlModifier)) {
            qmlSystem.ctrlV();
            backgroundImage.source = qmlSystem.image;
            moduleData.base64 = qmlSystem.image;
            moduleData.dataChanged();
            moduleArea.hasBackground = true;
        }
    }
    // 确保组件可以接收按键事件
    Component.onCompleted: {
        forceActiveFocus();
    }
    // 设置为可聚焦
    focus: true

    QmlSystem {
        id: qmlSystem
    }

    // 背景图片容器 - 固定800x800尺寸
    Rectangle {
        anchors.centerIn: parent
        width: 800
        height: 800
        color: "transparent"
        border.color: "#dee2e6"
        border.width: backgroundImage.source != "" ? 1 : 0
        radius: 4
        visible: backgroundImage.source != ""

        Image {
            id: backgroundImage
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            width: Math.min(800, implicitWidth)
            height: Math.min(800, implicitHeight)

            // 确保图片不会超出800x800的范围
            onImplicitWidthChanged: {
                if (implicitWidth > 0 && implicitHeight > 0) {
                    var scale = Math.min(800 / implicitWidth, 800 / implicitHeight);
                    width = implicitWidth * scale;
                    height = implicitHeight * scale;
                }
            }

            onImplicitHeightChanged: {
                if (implicitWidth > 0 && implicitHeight > 0) {
                    var scale = Math.min(800 / implicitWidth, 800 / implicitHeight);
                    width = implicitWidth * scale;
                    height = implicitHeight * scale;
                }
            }
        }
    }

    // 点位显示
    Repeater {
        id: pointsRepeater

        model: moduleData.points

        delegate: Rectangle {
            id: pointItem

            width: 10
            height: 10
            radius: 5
            x: model.rx ? model.rx - 5 : 0
            y: model.ry ? model.ry - 5 : 0
            z: 1
            // 高亮显示选中的点位
            scale: moduleArea.currentPointIndex === index ? 1.5 : 1
            border.width: moduleArea.currentPointIndex === index ? 2 : 1
            border.color: moduleArea.currentPointIndex === index ? "#4a90e2" : "black"

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
                // drag.axis: Drag.XAndY
                enabled: moduleArea.isEditing
                onPressed: {
                    moduleArea.isDraggingPoint = true;
                }
                onReleased: {
                    moduleArea.isDraggingPoint = false;
                    if (moduleArea.isEditing) {
                        // 更新点位坐标
                        var newX = parseInt(parent.x + 5);
                        var newY = parseInt(parent.y + 5);
                        // 使用updatePoint函数更新坐标
                        if (typeof moduleData.updatePoint === "function") {
                            moduleData.updatePoint(index, "rx", newX);
                            moduleData.updatePoint(index, "ry", newY);
                        } else {
                            // 兼容旧代码
                            if (typeof moduleData.points.setProperty === "function") {
                                moduleData.points.setProperty(index, "rx", newX);
                                moduleData.points.setProperty(index, "ry", newY);
                            } else if (Array.isArray(moduleData.points) && moduleData.points[index]) {
                                moduleData.points[index].rx = newX;
                                moduleData.points[index].ry = newY;
                            }
                        }
                        moduleArea.pointMoved(index, newX, newY);
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
                    moduleArea.hasBackground = true;
                    moduleArea.backgroundChanged(url.toString());
                }
            } else {
                console.log("droped", drop.text);
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "拖放图片或使用Ctrl+V粘贴"
        color: "#999999"
        visible: backgroundImage.source === ""
    }

    // 点击添加点位
    MouseArea {
        // 可以在这里添加拖拽预览效果

        property bool isDragging: false
        property int startX: 0
        property int startY: 0

        anchors.fill: parent
        enabled: moduleArea.isEditing
        hoverEnabled: true
        onDoubleClicked: {
            if (moduleArea.isEditing && !moduleArea.isDraggingPoint) {
                // 双击添加新点位
                var pointName = "点位" + (moduleData.points.count + 1);
                const rWidth = moduleArea.width;
                const rHeight = moduleArea.height;
                // 使用模型操作方法添加点位
                if (typeof moduleData.addPoint === "function") {
                    moduleData.addPoint(parseInt(mouseX), parseInt(mouseY), pointName);
                } else {
                    // 为了兼容性，尝试不同的方法添加点位
                    if (Array.isArray(moduleData.points))
                        moduleData.points.push({
                            "name": pointName,
                            "rx": parseInt(mouseX),
                            "ry": parseInt(mouseY)
                        });
                }
                moduleArea.pointAdded(pointName, parseInt(mouseX), parseInt(mouseY));
            }
        }
        onPressed: {
            if (moduleArea.isEditing && !moduleArea.isDraggingPoint) {
                startX = mouseX;
                startY = mouseY;
                isDragging = true;
            }
        }
        onPositionChanged: {
            if (isDragging && moduleArea.isEditing && !moduleArea.isDraggingPoint) {}
        }
        onReleased: {
            if (isDragging && moduleArea.isEditing && !moduleArea.isDraggingPoint) {
                return;
                isDragging = false;
                // 计算拖拽距离
                var dragDistance = Math.sqrt(Math.pow(mouseX - startX, 2) + Math.pow(mouseY - startY, 2));
                // 如果拖拽距离足够大，添加点位
                if (dragDistance > 5) {
                    var pointName = "点位" + (moduleData.points.length + 1);
                    // 使用模型操作方法添加点位
                    if (typeof moduleData.addPoint === "function") {
                        moduleData.addPoint(parseInt(mouseX), parseInt(mouseY), pointName);
                    } else {
                        // 为了兼容性，尝试不同的方法添加点位
                        if (Array.isArray(moduleData.points))
                            moduleData.points.push({
                                "name": pointName,
                                "rx": parseInt(mouseX),
                                "ry": parseInt(mouseY)
                            });
                    }
                    moduleArea.pointAdded(pointName, parseInt(mouseX), parseInt(mouseY));
                }
            }
        }
    }
}
