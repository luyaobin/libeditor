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

    // 背景图片容器 - 固定800x800尺寸
    Item {
        anchors.centerIn: parent
        width: 800
        height: 800
        // color: "transparent"
        // border.color: "#dee2e6"
        // border.width: backgroundImage.source !== "" ? 1 : 0
        // radius: 4
        visible: backgroundImage.source !== ""
        z: 0

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
                width: 100
                height: 100
                radius: 50
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
                // 显示模块名称
                Text {
                    anchors.centerIn: parent
                    text: model.name || "未知模块"
                    font.pixelSize: 12
                    font.family: "Microsoft YaHei"
                    color: "#333333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    width: parent.width - 10
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
                        if (moduleData && typeof moduleData.selectModule === "function") {
                            moduleData.selectModule(model, index);
                            // 打开模块详情弹出窗口
                            moduleDetailPopup.openModuleDetail(model, index);
                        }
                    }
                }

                // 移除所有动画和阴影效果以符合项目规则
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
        visible: backgroundImage.source === ""
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

    // 模块详情弹出窗口
    Popup {
        id: moduleDetailPopup

        property var currentModule: null
        property int currentIndex: -1
        property bool banSave: true

        anchors.centerIn: parent
        width: parent.width * 0.9
        height: parent.height * 0.9
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
            metaTextField.text = currentModule.meta || "";
            ioNumSpinBox.value = currentModule.ioNum || 0;
            airCheckBox.checked = currentModule.airNum === 1;
            banSave = false;
        }

        Rectangle {
            width: moduleDetailPopup.width
            height: moduleDetailPopup.height
            color: "#ffffff"
            border.color: "#dee2e6"
            border.width: 1
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // 工具栏
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "#f8f9fa"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 6

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text {
                            text: "模块详情 - " + (moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.meta || "未命名模块" : "")
                            font.pixelSize: 14
                            font.bold: true
                            color: "#495057"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "护套仓库"
                            implicitHeight: 32
                            onClicked: {
                                console.log("打开护套仓库");
                            }

                            background: Rectangle {
                                color: parent.hovered ? "#5a6268" : "#6c757d"
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12
                            }
                        }

                        Button {
                            text: "粘贴背景"
                            implicitHeight: 32
                            onClicked: popupModuleArea.pasteBackground()

                            background: Rectangle {
                                color: parent.hovered ? "#0056b3" : "#007bff"
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12
                            }
                        }

                        Button {
                            text: "背景左转"
                            implicitHeight: 32
                            onClicked: popupModuleArea.leftTransparent()

                            background: Rectangle {
                                color: parent.hovered ? "#138496" : "#17a2b8"
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12
                            }
                        }

                        Button {
                            text: "背景右转"
                            implicitHeight: 32
                            onClicked: popupModuleArea.rightTransparent()

                            background: Rectangle {
                                color: parent.hovered ? "#138496" : "#17a2b8"
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12
                            }
                        }

                        Button {
                            text: "关闭"
                            implicitHeight: 32
                            onClicked: moduleDetailPopup.close()

                            background: Rectangle {
                                color: parent.hovered ? "#c82333" : "#dc3545"
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12
                            }
                        }
                    }
                }

                // 主要内容区域
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    // 模块区域
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 2
                        color: "#ffffff"
                        border.color: "#dee2e6"
                        border.width: 1
                        radius: 6

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "模块视图"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#495057"
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.meta || "未命名模块" : ""
                                    font.pixelSize: 12
                                    color: "#6c757d"
                                }
                            }

                            ModuleArea {
                                id: popupModuleArea
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                points: moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.points : []
                                backgroundSource: moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.base64 || "" : ""
                                isEditing: true

                                // onPointSelected: function (index) {
                                //     console.log("模块区域选中点位:", index);
                                //     popupPointsArea.currentPointIndex = index;
                                // }

                                // onPointDeleted: function (index) {
                                //     console.log("删除点位:", index);
                                //     if (moduleDetailPopup.currentModule && typeof moduleDetailPopup.currentModule.deletePoint === "function") {
                                //         moduleDetailPopup.currentModule.deletePoint(index);
                                //     }
                                // }

                                // onPointAdded: function (x, y) {
                                //     console.log("添加点位:", x, y);
                                //     if (moduleDetailPopup.currentModule && typeof moduleDetailPopup.currentModule.addPoint === "function") {
                                //         moduleDetailPopup.currentModule.addPoint(x, y, "点位" + (moduleDetailPopup.currentModule.points.count + 1));
                                //     }
                                // }

                                // onPointMoved: function (index, x, y) {
                                //     console.log("移动点位:", index, x, y);
                                //     if (moduleDetailPopup.currentModule && typeof moduleDetailPopup.currentModule.movePoint === "function") {
                                //         moduleDetailPopup.currentModule.movePoint(index, x, y);
                                //     }
                                // }
                            }
                        }
                    }

                    // 右侧信息和点位区域
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        spacing: 10

                        // 模块信息编辑区域
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 280
                            color: "#ffffff"
                            border.color: "#dee2e6"
                            border.width: 1
                            radius: 6

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Text {
                                    text: "模块详情"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#495057"
                                }

                                ScrollView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true

                                    ColumnLayout {
                                        width: parent.width
                                        spacing: 8

                                        // 模块型号
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            Text {
                                                text: "模块型号:"
                                                font.pixelSize: 12
                                                color: "#495057"
                                                font.bold: true
                                                Layout.preferredWidth: 70
                                            }

                                            TextField {
                                                id: metaTextField
                                                Layout.fillWidth: true
                                                text: ""
                                                placeholderText: "请输入模块型号"
                                                font.pixelSize: 11
                                                onTextChanged: {
                                                    if (moduleDetailPopup.banSave || !moduleDetailPopup.currentModule)
                                                        return;
                                                    moduleDetailPopup.currentModule.meta = text;
                                                    if (typeof moduleDetailPopup.currentModule.dataChanged === "function") {
                                                        moduleDetailPopup.currentModule.dataChanged();
                                                    }
                                                }

                                                background: Rectangle {
                                                    color: "#ffffff"
                                                    border.color: parent.focus ? "#007bff" : "#ced4da"
                                                    border.width: 1
                                                    radius: 3
                                                }
                                            }
                                        }

                                        // 引脚数量
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            Text {
                                                text: "引脚数量:"
                                                font.pixelSize: 12
                                                color: "#495057"
                                                font.bold: true
                                                Layout.preferredWidth: 70
                                            }

                                            SpinBox {
                                                id: ioNumSpinBox
                                                Layout.preferredWidth: 100
                                                value: 0
                                                from: 0
                                                to: 99
                                                editable: true
                                                onValueChanged: {
                                                    if (moduleDetailPopup.banSave || !moduleDetailPopup.currentModule)
                                                        return;
                                                    moduleDetailPopup.currentModule.ioNum = value;
                                                    if (typeof moduleDetailPopup.currentModule.dataChanged === "function") {
                                                        moduleDetailPopup.currentModule.dataChanged();
                                                    }
                                                }

                                                background: Rectangle {
                                                    implicitHeight: 28
                                                    color: "#ffffff"
                                                    border.color: parent.focus ? "#007bff" : "#ced4da"
                                                    border.width: 1
                                                    radius: 3
                                                }

                                                contentItem: TextInput {
                                                    text: parent.textFromValue(parent.value, parent.locale)
                                                    color: "#212529"
                                                    selectByMouse: true
                                                    horizontalAlignment: Qt.AlignHCenter
                                                    verticalAlignment: Qt.AlignVCenter
                                                    font.pixelSize: 11
                                                }
                                            }

                                            Text {
                                                text: "实际: " + (moduleDetailPopup.currentModule && moduleDetailPopup.currentModule.points ? moduleDetailPopup.currentModule.points.count : 0)
                                                color: "#6c757d"
                                                font.pixelSize: 10
                                                Layout.fillWidth: true
                                            }

                                            Button {
                                                text: "删除尾点"
                                                implicitHeight: 28
                                                implicitWidth: 70
                                                onClicked: {
                                                    if (moduleDetailPopup.currentModule && typeof moduleDetailPopup.currentModule.deletePoint === "function") {
                                                        moduleDetailPopup.currentModule.deletePoint();
                                                    }
                                                }

                                                background: Rectangle {
                                                    color: parent.hovered ? "#c82333" : "#dc3545"
                                                    radius: 3
                                                }

                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "white"
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }
                                            }
                                        }

                                        // 锁片对数
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            Text {
                                                text: "锁片对数:"
                                                font.pixelSize: 12
                                                color: "#495057"
                                                font.bold: true
                                                Layout.preferredWidth: 70
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 4

                                                Repeater {
                                                    model: 7

                                                    delegate: Rectangle {
                                                        width: 24
                                                        height: 24
                                                        color: index === (moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.lockNum : 0) ? "#007bff" : "#f8f9fa"
                                                        border.color: index === (moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.lockNum : 0) ? "#0056b3" : "#dee2e6"
                                                        border.width: 1
                                                        radius: 3

                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: index
                                                            font.pixelSize: 10
                                                            font.bold: true
                                                            color: index === (moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.lockNum : 0) ? "white" : "#495057"
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: {
                                                                if (moduleDetailPopup.currentModule) {
                                                                    moduleDetailPopup.currentModule.lockNum = index;
                                                                    if (typeof moduleDetailPopup.currentModule.dataChanged === "function") {
                                                                        moduleDetailPopup.currentModule.dataChanged();
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        // 气密存在
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            Text {
                                                text: "气密存在:"
                                                font.pixelSize: 12
                                                color: "#495057"
                                                font.bold: true
                                                Layout.preferredWidth: 70
                                            }

                                            CheckBox {
                                                id: airCheckBox
                                                checked: false
                                                text: "存在气密"
                                                font.pixelSize: 11
                                                onCheckedChanged: {
                                                    if (moduleDetailPopup.banSave || !moduleDetailPopup.currentModule)
                                                        return;
                                                    moduleDetailPopup.currentModule.airNum = checked ? 1 : 0;
                                                    if (typeof moduleDetailPopup.currentModule.dataChanged === "function") {
                                                        moduleDetailPopup.currentModule.dataChanged();
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 点位列表区域
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#ffffff"
                            border.color: "#dee2e6"
                            border.width: 1
                            radius: 6

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: "点位列表"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#495057"
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "共 " + (moduleDetailPopup.currentModule && moduleDetailPopup.currentModule.points ? moduleDetailPopup.currentModule.points.count : 0) + " 个"
                                        font.pixelSize: 12
                                        color: "#6c757d"
                                    }
                                }

                                PointsArea {
                                    id: popupPointsArea
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    points: moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.points : []
                                    isEditing: true

                                    // onPointSelected: function (index) {
                                    //     console.log("点位列表选中点位:", index);
                                    //     popupModuleArea.currentPointIndex = index;
                                    // }

                                    // onPointDeleted: function (index) {
                                    //     console.log("从列表删除点位:", index);
                                    //     if (moduleDetailPopup.currentModule && typeof moduleDetailPopup.currentModule.deletePoint === "function") {
                                    //         moduleDetailPopup.currentModule.deletePoint(index);
                                    //     } else {
                                    //         if (moduleDetailPopup.currentModule && Array.isArray(moduleDetailPopup.currentModule.points))
                                    //             moduleDetailPopup.currentModule.points.splice(index, 1);
                                    //     }
                                    // }

                                    // onPointMoved: function (fromIndex, toIndex) {
                                    //     console.log("点位拖拽移动:", fromIndex, "->", toIndex);
                                    //     if (moduleDetailPopup.currentModule && typeof moduleDetailPopup.currentModule.movePointInList === "function") {
                                    //         moduleDetailPopup.currentModule.movePointInList(fromIndex, toIndex);
                                    //     } else {
                                    //         // 兼容处理：手动移动数组元素
                                    //         if (moduleDetailPopup.currentModule && Array.isArray(moduleDetailPopup.currentModule.points) && fromIndex !== toIndex) {
                                    //             var points = moduleDetailPopup.currentModule.points;
                                    //             var item = points.splice(fromIndex, 1)[0];
                                    //             points.splice(toIndex, 0, item);
                                    //             // 触发数据更新
                                    //             if (typeof moduleDetailPopup.currentModule.dataChanged === "function") {
                                    //                 moduleDetailPopup.currentModule.dataChanged();
                                    //             }
                                    //         }
                                    //     }
                                    // }
                                }
                            }
                        }
                    }
                }

                // 状态栏
                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    color: "#e9ecef"
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 15

                        Text {
                            text: "模块: " + (moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.code || "未知" : "")
                            font.pixelSize: 11
                            color: "#495057"
                        }

                        Text {
                            text: "点位: " + (moduleDetailPopup.currentModule && moduleDetailPopup.currentModule.points ? moduleDetailPopup.currentModule.points.count : 0)
                            font.pixelSize: 11
                            color: "#495057"
                        }

                        Text {
                            text: "引脚: " + (moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.ioNum || 0 : 0)
                            font.pixelSize: 11
                            color: "#495057"
                        }

                        Text {
                            text: "锁片: " + (moduleDetailPopup.currentModule ? moduleDetailPopup.currentModule.lockNum || 0 : 0)
                            font.pixelSize: 11
                            color: "#495057"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "编辑模式"
                            font.pixelSize: 11
                            color: "#28a745"
                            font.bold: true
                        }
                    }
                }
            }
        }

        // 监听模块数据变化
        Connections {
            target: moduleDetailPopup.currentModule
            function onDataChanged() {
                moduleDetailPopup.updateFields();
            }
        }
    }
}
