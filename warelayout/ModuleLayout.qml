import QtQml.Models 2.14 // 使用此导入来支持 DelegateModelGroup
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

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

    // 背景图片容器 - 固定800x800尺寸
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: hasBackground ? "#409eff" : "#dcdfe6"
        border.width: hasBackground ? 2 : 1
        radius: 8
        visible: backgroundImage.source !== ""
        z: 0

        // 背景装饰
        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            color: "transparent"
            border.color: "#f0f2f5"
            border.width: 1
            radius: 6
        }

        Image {
            id: backgroundImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit

            // 确保图片不会超出800x800的范围
            onImplicitWidthChanged: {
                if (implicitWidth > 0 && implicitHeight > 0) {
                    var scale = Math.min(792 / implicitWidth, 792 / implicitHeight);
                    width = implicitWidth * scale;
                    height = implicitHeight * scale;
                }
            }

            onImplicitHeightChanged: {
                if (implicitWidth > 0 && implicitHeight > 0) {
                    var scale = Math.min(792 / implicitWidth, 792 / implicitHeight);
                    width = implicitWidth * scale;
                    height = implicitHeight * scale;
                }
            }
        }
    }

    // 自由布局容器
    Item {
        id: moduleContainer

        anchors.fill: parent
        z: 1

        Repeater {
            id: libraryListView

            model: projects.currentProjectModules

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
                width: 120
                height: 120
                radius: 12

                // 美化的渐变背景
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: isDragging ? "#e3f2fd" : "#ffffff"
                    }
                    GradientStop {
                        position: 1.0
                        color: isDragging ? "#bbdefb" : "#f8f9fa"
                    }
                }

                border.color: {
                    if (isDropArea)
                        return "#4caf50";
                    if (isDragging)
                        return "#2196f3";
                    return "#e0e0e0";
                }
                border.width: {
                    if (isDropArea || isDragging)
                        return 3;
                    return 1;
                }

                // 内部装饰边框
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    color: "transparent"
                    border.color: "#f0f2f5"
                    border.width: 1
                    radius: 9
                }

                // 模块图标背景
                Rectangle {
                    id: iconBackground
                    anchors.centerIn: parent
                    width: 60
                    height: 60
                    radius: 30
                    color: "#409eff"

                    // 模块编号显示
                    Text {
                        anchors.centerIn: parent
                        text: (index + 1).toString()
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                        font.family: "Microsoft YaHei"
                    }
                }

                // 显示模块名称
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8
                    text: model.name || "未知模块"
                    font.pixelSize: 12
                    font.family: "Microsoft YaHei"
                    font.bold: true
                    color: "#333333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    width: parent.width - 10
                }

                // 状态指示器
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 8
                    width: 12
                    height: 12
                    radius: 6
                    color: model.airNum === 1 ? "#4caf50" : "#ff9800"
                }

                // 拖拽时的视觉效果
                states: [
                    State {
                        name: "dragging"
                        when: isDragging

                        PropertyChanges {
                            target: delegateItem
                            scale: 1.05
                            opacity: 0.9
                            z: 10
                        }
                    },
                    State {
                        name: "dropTarget"
                        when: isDropArea

                        PropertyChanges {
                            target: delegateItem
                            scale: 1.02
                        }
                    }
                ]

                MouseArea {
                    id: dragArea

                    anchors.fill: parent
                    drag.target: parent
                    drag.smoothed: true
                    drag.threshold: 5
                    hoverEnabled: true

                    onEntered: {
                        if (!isDragging) {
                            delegateItem.border.color = "#2196f3";
                            delegateItem.border.width = 2;
                        }
                    }

                    onExited: {
                        if (!isDragging && !isDropArea) {
                            delegateItem.border.color = "#e0e0e0";
                            delegateItem.border.width = 1;
                        }
                    }

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
                        if (moduleData && typeof moduleData.selectModule === "function") {
                            moduleData.selectModule(model, index);
                            // 打开模块详情弹出窗口
                            moduleDetailPopup.openModuleDetail(model, index);
                        }
                    }
                }
            }
        }
    }

    // 没有背景时的提示区域
    Rectangle {
        anchors.centerIn: parent
        width: 400
        height: 200
        color: "#ffffff"
        border.color: "#e0e0e0"
        border.width: 2
        radius: 12
        visible: backgroundImage.source === ""
        z: 0

        // 虚线边框效果
        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            color: "transparent"
            border.color: "#409eff"
            border.width: 1
            radius: 8
            opacity: 0.5
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16

            // 图标
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 60
                height: 60
                radius: 30
                color: "#e3f2fd"

                Text {
                    anchors.centerIn: parent
                    text: "📷"
                    font.pixelSize: 24
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "拖放图片或使用 Ctrl+V 粘贴"
                color: "#666666"
                font.pixelSize: 16
                font.family: "Microsoft YaHei"
                font.bold: true
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "支持 JPG、PNG、GIF、BMP 格式"
                color: "#999999"
                font.pixelSize: 12
                font.family: "Microsoft YaHei"
            }
        }
    }

    // 添加滚动视图支持
    ScrollView {
        anchors.fill: parent
        clip: true
        // 设置内容大小，确保可以滚动查看所有模块
        contentWidth: moduleContainer.width
        contentHeight: Math.max(moduleContainer.height, librariesModel.moduleModel.count * 40)
    }

    // 模块详情弹出窗口
    Popup {
        id: moduleDetailPopup

        property var currentModule: null
        property int currentIndex: -1
        property bool banSave: true

        anchors.centerIn: parent
        width: parent.width * 0.95
        height: parent.height * 0.95
        padding: 0
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        function openModuleDetail(module, index) {
            currentModule = module;
            currentIndex = index;
            updateFields();
            open();
        }

        function updateFields() {
            if (!currentModule)
                return;
            banSave = true;
            // metaTextField.text = currentModule.meta || "";
            // ioNumSpinBox.value = currentModule.ioNum || 0;
            // airCheckBox.checked = currentModule.airNum === 1;
            banSave = false;
        }

        Rectangle {
            width: moduleDetailPopup.width
            height: moduleDetailPopup.height
            color: "#ffffff"
            border.color: "#e0e0e0"
            border.width: 2
            radius: 12

            // 添加阴影效果的替代方案 - 多层边框
            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                color: "transparent"
                border.color: "#f0f0f0"
                border.width: 1
                radius: 13
                z: -1
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // 主要内容区域
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 16

                    // 模块信息编辑区域
                    Rectangle {

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        color: "#ffffff"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 8
                        ModuleDetails {
                            anchors.fill: parent
                        }
                    }
                    // 模块区域
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 2
                        color: "#ffffff"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 8

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 12
                                    color: "#e3f2fd"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "🖼"
                                        font.pixelSize: 12
                                    }
                                }

                                Text {
                                    text: "模块视图"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333333"
                                    font.family: "Microsoft YaHei"
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    height: 24
                                    width: moduleNameText.width + 16
                                    color: "#e8f5e8"
                                    radius: 12

                                    Text {
                                        id: moduleNameText
                                        anchors.centerIn: parent
                                        text: moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.meta || "未命名模块" : ""
                                        font.pixelSize: 12
                                        color: "#4caf50"
                                        font.family: "Microsoft YaHei"
                                        font.bold: true
                                    }
                                }
                            }

                            ModuleArea {
                                id: popupModuleArea
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                points: moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.points : []
                                backgroundSource: moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.base64 || "" : ""
                                isEditing: true
                            }
                        }
                    }

                    // 点位列表区域
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#ffffff"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 8

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true

                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 12
                                    color: "#e8f5e8"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "📍"
                                        font.pixelSize: 12
                                    }
                                }

                                Text {
                                    text: "点位列表"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333333"
                                    font.family: "Microsoft YaHei"
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    height: 24
                                    width: countText.width + 16
                                    color: "#fff3e0"
                                    radius: 12

                                    Text {
                                        id: countText
                                        anchors.centerIn: parent
                                        text: "共 " + (moduleDetailPopup.currentModule && moduleDetailPopup.currentModule.points ? moduleDetailPopup.currentModule.points.count : 0) + " 个"
                                        font.pixelSize: 12
                                        color: "#ff9800"
                                        font.family: "Microsoft YaHei"
                                        font.bold: true
                                    }
                                }
                            }

                            PointsArea {
                                id: popupPointsArea
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                points: moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.points : []
                                isEditing: true
                            }
                        }
                    }
                }
            }
        }
    }
}
