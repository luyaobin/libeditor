import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Rectangle {
    id: moduleArea

    property var points: []
    property bool isEditing: true
    property int currentPointIndex: -1
    property string backgroundSource: ""
    property real scaleFactor: 1.0
    property point offset: Qt.point(0, 0)

    signal pointSelected(int index)
    signal pointDeleted(int index)
    signal pointAdded(real x, real y)
    signal pointMoved(int index, real x, real y)

    color: "#f8f9fa"
    border.color: "#dee2e6"
    border.width: 1
    radius: 6

    // 背景图片容器 - 固定800x800尺寸
    Rectangle {
        anchors.centerIn: parent
        width: 800
        height: 800
        color: "transparent"
        border.color: "#dee2e6"
        border.width: moduleArea.backgroundSource !== "" ? 1 : 0
        radius: 4
        visible: moduleArea.backgroundSource !== ""

        Image {
            id: backgroundImage
            anchors.centerIn: parent
            source: moduleArea.backgroundSource
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

            // 图片加载状态提示
            Rectangle {
                anchors.centerIn: parent
                width: 120
                height: 40
                color: "#f8f9fa"
                border.color: "#dee2e6"
                radius: 4
                visible: backgroundImage.status === Image.Loading

                Text {
                    anchors.centerIn: parent
                    text: "加载中..."
                    color: "#6c757d"
                    font.pixelSize: 12
                }
            }
        }

        // 尺寸标识
        Text {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 5
            text: "800×800"
            color: "#6c757d"
            font.pixelSize: 10
            // background: Rectangle {
            //     color: "#ffffff"
            //     opacity: 0.8
            //     radius: 2
            // }
        }
    }

    // 点位显示
    Repeater {
        model: moduleArea.points

        delegate: Rectangle {
            id: pointItem

            property bool isSelected: index === moduleArea.currentPointIndex
            property bool isDragging: false

            x: (model.rx || 0) * moduleArea.scaleFactor + moduleArea.offset.x - width / 2
            y: (model.ry || 0) * moduleArea.scaleFactor + moduleArea.offset.y - height / 2
            width: 24
            height: 24
            radius: 12

            color: isSelected ? "#007bff" : (isDragging ? "#28a745" : "#6c757d")
            border.color: isSelected ? "#0056b3" : "#495057"
            border.width: 2

            // 点位标签
            Text {
                anchors.centerIn: parent
                text: index + 1
                color: "white"
                font.pixelSize: 10
                font.bold: true
            }

            // 点位名称标签
            Rectangle {
                anchors.top: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 5
                width: nameText.width + 8
                height: nameText.height + 4
                color: "#343a40"
                radius: 3
                visible: model.name && model.name !== ""

                Text {
                    id: nameText
                    anchors.centerIn: parent
                    text: model.name || ""
                    color: "white"
                    font.pixelSize: 10
                }
            }

            // 坐标显示
            Rectangle {
                anchors.bottom: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 5
                width: coordText.width + 8
                height: coordText.height + 4
                color: "#6c757d"
                radius: 3
                visible: isSelected

                Text {
                    id: coordText
                    anchors.centerIn: parent
                    text: "(" + Math.round(model.rx || 0) + "," + Math.round(model.ry || 0) + ")"
                    color: "white"
                    font.pixelSize: 9
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                drag.target: moduleArea.isEditing ? parent : null
                drag.axis: Drag.XAndYAxis
                hoverEnabled: true
                cursorShape: moduleArea.isEditing ? Qt.OpenHandCursor : Qt.ArrowCursor

                onClicked: function (mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        moduleArea.currentPointIndex = index;
                        moduleArea.pointSelected(index);
                    } else if (mouse.button === Qt.RightButton && moduleArea.isEditing) {
                        contextMenu.popup();
                    }
                }

                onPressed: function (mouse) {
                    if (moduleArea.isEditing && mouse.button === Qt.LeftButton) {
                        pointItem.isDragging = true;
                        cursorShape = Qt.ClosedHandCursor;
                    }
                }

                onReleased: function (mouse) {
                    if (pointItem.isDragging) {
                        pointItem.isDragging = false;
                        cursorShape = Qt.OpenHandCursor;
                        // 更新点位坐标，考虑中心偏移
                        var newX = (pointItem.x + pointItem.width / 2 - moduleArea.offset.x) / moduleArea.scaleFactor;
                        var newY = (pointItem.y + pointItem.height / 2 - moduleArea.offset.y) / moduleArea.scaleFactor;
                        moduleArea.pointMoved(index, newX, newY);
                    }
                }

                // 右键菜单
                Menu {
                    id: contextMenu

                    MenuItem {
                        text: "删除点位"
                        enabled: moduleArea.isEditing
                        onTriggered: moduleArea.pointDeleted(index)
                    }

                    MenuItem {
                        text: "编辑名称"
                        enabled: moduleArea.isEditing
                        onTriggered: {
                            nameDialog.pointIndex = index;
                            nameDialog.currentName = model.name || "";
                            nameDialog.open();
                        }
                    }
                }
            }
        }
    }

    // 添加点位的鼠标区域
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        enabled: moduleArea.isEditing

        onDoubleClicked: function (mouse) {
            var newX = (mouse.x - moduleArea.offset.x) / moduleArea.scaleFactor;
            var newY = (mouse.y - moduleArea.offset.y) / moduleArea.scaleFactor;
            moduleArea.pointAdded(newX, newY);
        }
    }

    // 工具栏
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        width: toolRow.width + 16
        height: toolRow.height + 12
        color: "#ffffff"
        border.color: "#dee2e6"
        radius: 6
        visible: moduleArea.isEditing

        RowLayout {
            id: toolRow
            anchors.centerIn: parent
            spacing: 8

            Button {
                text: "+"
                implicitWidth: 32
                implicitHeight: 32
                onClicked: moduleArea.scaleFactor = Math.min(moduleArea.scaleFactor * 1.2, 3.0)

                background: Rectangle {
                    color: parent.hovered ? "#e9ecef" : "#f8f9fa"
                    border.color: "#dee2e6"
                    radius: 4
                }
            }

            Button {
                text: "-"
                implicitWidth: 32
                implicitHeight: 32
                onClicked: moduleArea.scaleFactor = Math.max(moduleArea.scaleFactor / 1.2, 0.5)

                background: Rectangle {
                    color: parent.hovered ? "#e9ecef" : "#f8f9fa"
                    border.color: "#dee2e6"
                    radius: 4
                }
            }
        }
    }

    // 状态信息
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 10
        width: statusText.width + 16
        height: statusText.height + 8
        color: "#343a40"
        radius: 4

        Text {
            id: statusText
            anchors.centerIn: parent
            text: "点位数: " + moduleArea.points.length + " | 双击添加点位 | 拖拽移动点位"
            color: "white"
            font.pixelSize: 11
        }
    }

    // 点位名称编辑对话框
    Dialog {
        id: nameDialog

        property int pointIndex: -1
        property string currentName: ""

        title: "编辑点位名称"
        modal: true
        anchors.centerIn: parent
        width: 300
        height: 150

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: "点位 " + (nameDialog.pointIndex + 1) + " 名称:"
                font.pixelSize: 14
            }

            TextField {
                id: nameInput
                Layout.fillWidth: true
                text: nameDialog.currentName
                placeholderText: "请输入点位名称"
                selectByMouse: true
            }

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "取消"
                    onClicked: nameDialog.close()

                    background: Rectangle {
                        color: parent.hovered ? "#e9ecef" : "#f8f9fa"
                        border.color: "#dee2e6"
                        radius: 4
                    }
                }

                Button {
                    text: "确定"
                    onClicked: {
                        if (nameDialog.pointIndex >= 0 && nameDialog.pointIndex < moduleArea.points.length) {
                            moduleArea.points[nameDialog.pointIndex].name = nameInput.text;
                        }
                        nameDialog.close();
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#0056b3" : "#007bff"
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // 功能函数
    function pasteBackground() {
        // 从剪贴板粘贴背景图片的功能
        console.log("粘贴背景图片");
    }

    function leftTransparent() {
        // 背景左转功能
        console.log("背景左转");
    }

    function rightTransparent() {
        // 背景右转功能
        console.log("背景右转");
    }

    function addPoint(x, y, name) {
        var newPoint = {
            "rx": x,
            "ry": y,
            "name": name || ""
        };
        moduleArea.points.push(newPoint);
        moduleArea.pointAdded(x, y);
    }

    function removePoint(index) {
        if (index >= 0 && index < moduleArea.points.length) {
            moduleArea.points.splice(index, 1);
            if (moduleArea.currentPointIndex >= moduleArea.points.length) {
                moduleArea.currentPointIndex = moduleArea.points.length - 1;
            }
        }
    }
}
