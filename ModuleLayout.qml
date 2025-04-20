import QtGraphicalEffects 1.0
import QtQml.Models 2.14 // 使用此导入来支持 DelegateModelGroup
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import qmlcpplib.qmlsystem 1.0

Item {
    // 如果需要处理图片粘贴可以在这里添加相应的代码

    id: librariesView

    // 添加背景图片相关属性
    property alias backgroundSource: backgroundImage.source
    property bool hasBackground: backgroundImage.source != ""

    signal backgroundChanged(string source)
    signal pasteBackground

    // 计算拖放位置对应的索引
    function calculateDropIndex(x, y) {
        // 在自由布局中，我们可以根据位置找到最近的模块
        var minDistance = Number.MAX_VALUE;
        var closestIndex = -1;
        for (var i = 0; i < librariesModel.moduleModel.count; i++) {
            var item = moduleContainer.children[i];
            if (item) {
                var dx = x - (item.x + item.width / 2);
                var dy = y - (item.y + item.height / 2);
                var distance = Math.sqrt(dx * dx + dy * dy);
                if (distance < minDistance) {
                    minDistance = distance;
                    closestIndex = i;
                }
            }
        }
        return closestIndex;
    }

    onPasteBackground: {
        qmlSystem.ctrlV();
        backgroundImage.source = qmlSystem.image;
        if (moduleData) {
            moduleData.base64 = qmlSystem.image;
            moduleData.dataChanged();
        }
        librariesView.hasBackground = true;
    }
    // 键盘事件处理，用于复制粘贴等操作
    Keys.onPressed: function (event) {
        if ((event.key === Qt.Key_V) && (event.modifiers & Qt.ControlModifier)) {
            if (qmlSystem && typeof qmlSystem.ctrlV === "function") {
                qmlSystem.ctrlV();
                backgroundImage.source = qmlSystem.image;
                if (moduleData) {
                    moduleData.base64 = qmlSystem.image;
                    moduleData.dataChanged();
                }
                librariesView.hasBackground = true;
            }
        }
    }
    Component.onCompleted: {
        forceActiveFocus();
    }
    focus: true

    // 添加QmlSystem
    QmlSystem {
        id: qmlSystem
    }

    // 背景图片
    Image {
        id: backgroundImage

        anchors.fill: parent
        visible: source != ""
        z: 0
    }

    // 自由布局容器
    Item {
        id: moduleContainer

        anchors.fill: parent
        z: 1

        Repeater {
            id: libraryListView

            model: librariesModel.moduleModel

            delegate: Rectangle {
                id: delegateItem

                // 拖拽属性
                property bool isDragging: false
                property int startX: 0
                property int startY: 0
                property bool isDropArea: false

                // 使用模型中保存的位置或默认位置
                x: model.rx > 0 ? model.rx : (index % 3) * 220
                y: model.ry > 0 ? model.ry : Math.floor(index / 3) * 120
                width: 200
                height: 100
                radius: 5
                border.color: isDropArea ? "#4a90e2" : "#e0e0e0"
                border.width: isDropArea ? 2 : 1
                layer.enabled: true
                // 拖拽时的视觉效果
                states: [
                    State {
                        name: "dragging"
                        when: isDragging

                        PropertyChanges {
                            target: delegateItem
                            scale: 1.05
                            opacity: 0.8
                            z: 10
                        }
                    },
                    State {
                        name: "dropTarget"
                        when: isDropArea

                        PropertyChanges {
                            target: delegateItem
                            border.color: "#4a90e2"
                            border.width: 2
                            scale: 1.02
                        }
                    }
                ]

                // 内容布局
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Item {
                        width: 40
                        height: 40
                        Layout.alignment: Qt.AlignVCenter

                        // 如果有图片则显示图片，否则显示默认圆形
                        Image {
                            id: moduleImage

                            anchors.fill: parent
                            source: model.base64 ? model.base64 : ""
                            fillMode: Image.PreserveAspectFit
                            visible: source !== ""
                            layer.enabled: visible

                            layer.effect: OpacityMask {

                                maskSource: Rectangle {
                                    width: moduleImage.width
                                    height: moduleImage.height
                                    radius: 20
                                }
                            }
                        }

                        // 默认圆形（当没有图片时显示）
                        Rectangle {
                            anchors.fill: parent
                            radius: 20
                            color: "#4a90e2"
                            visible: !moduleImage.visible || moduleImage.source === ""

                            Text {
                                anchors.centerIn: parent
                                text: model.code ? model.code.substring(0, 1) : ""
                                font.pixelSize: 16
                                font.bold: true
                                color: "white"
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 5

                        Text {
                            text: model.code ? model.code : ""
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                            elide: Text.ElideRight
                        }

                        Text {
                            text: model.name ? model.name : ""
                            font.pixelSize: 12
                            color: "#666666"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: model.meta ? model.meta : ""
                            font.pixelSize: 10
                            color: "#999999"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                MouseArea {
                    id: dragArea

                    anchors.fill: parent
                    drag.target: parent
                    drag.smoothed: true
                    drag.threshold: 5
                    onPressed: {
                        delegateItem.isDragging = true;
                        delegateItem.startX = delegateItem.x;
                        delegateItem.startY = delegateItem.y;
                        delegateItem.z = 100; // 确保拖动的项在最上层
                        // 选中当前模块
                        if (moduleData && typeof moduleData.selectModule === "function")
                            moduleData.selectModule(model, index);
                    }
                    onPositionChanged: {
                        if (delegateItem.isDragging) {
                            // 在拖动过程中，检查是否悬停在其他模块上
                            for (var i = 0; i < moduleContainer.children.length; i++) {
                                var item = moduleContainer.children[i];
                                if (item && item !== delegateItem) {
                                    var itemGlobalPos = item.mapToGlobal(0, 0);
                                    var dragGlobalPos = delegateItem.mapToGlobal(mouseX, mouseY);
                                    // 检查项目是否具有isDropArea属性
                                    if (item.hasOwnProperty("isDropArea")) {
                                        if (dragGlobalPos.x >= itemGlobalPos.x && dragGlobalPos.x <= itemGlobalPos.x + item.width && dragGlobalPos.y >= itemGlobalPos.y && dragGlobalPos.y <= itemGlobalPos.y + item.height)
                                            item.isDropArea = true;
                                        else
                                            item.isDropArea = false;
                                    }
                                }
                            }
                        }
                    }
                    onReleased: {
                        delegateItem.isDragging = false;
                        delegateItem.z = 1;
                        // 清除所有高亮状态
                        for (var i = 0; i < moduleContainer.children.length; i++) {
                            var item = moduleContainer.children[i];
                            if (item && item.hasOwnProperty("isDropArea"))
                                item.isDropArea = false;
                        }
                        // 在自由布局中，我们可以保存新位置到模型
                        if (delegateItem.x !== delegateItem.startX || delegateItem.y !== delegateItem.startY) {
                            // 记录新的坐标值
                            var newRx = delegateItem.x;
                            var newRy = delegateItem.y;
                            console.log("位置已更改 - 模块索引:", index, "rx:", newRx, "ry:", newRy);
                            // 保存新位置
                            if (model && moduleData && typeof moduleData.dataChanged === "function") {
                                // 直接更新模型数据
                                if (typeof librariesModel.moduleModel.setProperty === "function") {
                                    librariesModel.moduleModel.setProperty(index, "rx", newRx);
                                    librariesModel.moduleModel.setProperty(index, "ry", newRy);
                                    console.log("已更新模型 rx:", newRx, "ry:", newRy);
                                }
                                // 同时更新moduleData
                                moduleData.rx = newRx;
                                moduleData.ry = newRy;
                                console.log("已更新moduleData rx:", moduleData.rx, "ry:", moduleData.ry);
                                moduleData.dataChanged();
                                // 使用模型的updateModule来确保更改被保存
                                if (typeof librariesModel.updateModule === "function") {
                                    librariesModel.updateModule(index, moduleData);
                                    console.log("已调用updateModule更新模块位置");
                                }
                            }
                            // 如果需要交换位置，可以计算最近的模块
                            var newIndex = calculateDropIndex(delegateItem.x + mouseX, delegateItem.y + mouseY);
                            if (newIndex !== index && newIndex >= 0 && newIndex < librariesModel.moduleModel.count && typeof librariesModel.moveModule === "function") {
                                librariesModel.moveModule(index, newIndex);
                                console.log("已移动模块从索引", index, "到", newIndex);
                            }
                        }
                    }
                    onClicked: {
                        if (moduleData && typeof moduleData.selectModule === "function")
                            moduleData.selectModule(model, index);
                    }
                }

                // 平滑过渡效果
                Behavior on x {
                    NumberAnimation {
                        duration: 100
                    }
                }

                Behavior on y {
                    NumberAnimation {
                        duration: 100
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 100
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 100
                    }
                }

                Behavior on border.width {
                    NumberAnimation {
                        duration: 100
                    }
                }

                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: delegateItem.isDragging ? 3 : 0
                    verticalOffset: delegateItem.isDragging ? 3 : 1
                    radius: delegateItem.isDragging ? 8 : 3
                    samples: delegateItem.isDragging ? 17 : 7
                    color: "#30000000"
                }
            }
        }
    }

    // 拖放区域
    DropArea {
        anchors.fill: parent
        z: 0
        onDropped: {
            if (drop.hasUrls) {
                var url = drop.urls[0];
                if (url.toString().toLowerCase().match(/\.(jpg|jpeg|png|gif|bmp)$/)) {
                    console.log("接收到图片文件:", url);
                    backgroundImage.source = url.toString();
                    librariesView.hasBackground = true;
                    librariesView.backgroundChanged(url.toString());
                    // 更新moduleData
                    if (moduleData) {
                        moduleData.base64 = url.toString();
                        moduleData.dataChanged();
                    }
                }
            } else {
                console.log("droped", drop.text);
            }
        }
    }

    // 没有背景时的提示文字
    Text {
        anchors.centerIn: parent
        text: "拖放图片或使用Ctrl+V粘贴"
        color: "#999999"
        visible: !backgroundImage.source
        z: 0
    }

    // 添加滚动视图支持
    ScrollView {
        anchors.fill: parent
        clip: true
        // 设置内容大小，确保可以滚动查看所有模块
        contentWidth: moduleContainer.width
        contentHeight: Math.max(moduleContainer.height, librariesModel.moduleModel.count * 40)
    }
}
