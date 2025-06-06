import QtQml.Models 2.14 // 使用此导入来支持 DelegateModelGroup
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Item {
    id: librariesView

    // 添加搜索过滤属性
    property string searchFilter: ""
    // 添加选中状态管理
    property var selectedIndices: []
    property bool selectAllChecked: false

    // 创建过滤模块函数
    function filterModules() {
        // 更新DelegateModel的过滤功能
        if (searchFilter.trim() === "") {
            // 如果没有搜索内容，直接使用原始模型
            libraryListView.model = librariesModel.moduleModel;
        } else {
            // 配置过滤模型并应用到ListView
            tempModel.model = librariesModel.moduleModel;
            tempModel.filterOnGroup = "filtered";
            libraryListView.model = tempModel;
        }
    }

    // 选中管理函数
    function toggleSelection(index) {
        var currentIndex = selectedIndices.indexOf(index);
        if (currentIndex === -1) {
            selectedIndices.push(index);
        } else {
            selectedIndices.splice(currentIndex, 1);
        }
        selectedIndices = selectedIndices.slice(); // 触发属性变化
        updateSelectAllState();
    }

    function selectAll() {
        selectedIndices = [];
        if (!selectAllChecked) {
            for (var i = 0; i < librariesModel.moduleModel.count; i++) {
                selectedIndices.push(i);
            }
        }
        selectedIndices = selectedIndices.slice(); // 触发属性变化
        selectAllChecked = !selectAllChecked;
    }

    function clearSelection() {
        selectedIndices = [];
        selectAllChecked = false;
    }

    function updateSelectAllState() {
        selectAllChecked = selectedIndices.length === librariesModel.moduleModel.count && librariesModel.moduleModel.count > 0;
    }

    function deleteSelectedModules() {
        if (selectedIndices.length === 0)
            return;

        // 按索引从大到小排序，避免删除时索引变化的问题
        var sortedIndices = selectedIndices.slice().sort(function (a, b) {
            return b - a;
        });

        for (var i = 0; i < sortedIndices.length; i++) {
            librariesModel.removeModule(sortedIndices[i]);
        }

        clearSelection();
    }

    // 当搜索过滤器变化时重新应用过滤
    onSearchFilterChanged: {
        if (tempModel.model)
            tempModel.updateFilter();

        filterModules();
    }
    // 组件加载完成后监听搜索过滤器变化
    Component.onCompleted: {
        // 初始时使用原始模型
        libraryListView.model = librariesModel.moduleModel;
    }

    // 临时模型用于存储过滤结果
    DelegateModel {
        id: tempModel

        // 更新过滤函数
        function updateFilter() {
            if (!model)
                return;

            for (var i = 0; i < items.count; i++) {
                var item = items.get(i);
                // 检查是否匹配搜索条件
                var matches = false;
                if (searchFilter.trim() === "") {
                    matches = true;
                } else {
                    var moduleItem = item.model;
                    if (moduleItem && moduleItem.code && moduleItem.name) {
                        // 检查是否包含搜索关键词（不区分大小写）
                        if (moduleItem.code.toLowerCase().indexOf(searchFilter.toLowerCase()) !== -1 || moduleItem.name.toLowerCase().indexOf(searchFilter.toLowerCase()) !== -1)
                            matches = true;
                    }
                }
                // 根据匹配结果设置组员资格
                if (matches) {
                    if (!filteredGroup.count(item))
                        filteredGroup.insert(item);
                } else {
                    if (filteredGroup.count(item))
                        filteredGroup.remove(item);
                }
            }
        }

        delegate: libraryListView.delegate // 确保使用相同的代理
        // 过滤器函数，用于动态确定项目是否应包含在过滤组中
        filterOnGroup: "filtered"
        // 定义项目过滤逻辑
        items.onChanged: updateFilter()
        // 当搜索关键词变化时更新过滤
        Component.onCompleted: {
            updateFilter();
        }
        // 配置代理组
        groups: [
            DelegateModelGroup {
                id: filteredGroup

                name: "filtered"
                includeByDefault: false
            }
        ]
    }

    // 显示列表
    ListView {
        id: libraryListView

        currentIndex: 0
        anchors.fill: parent
        model: librariesModel.moduleModel
        clip: true
        spacing: 5
        focus: true
        headerPositioning: ListView.OverlayHeader

        header: Rectangle {
            z: 100
            width: parent.width
            height: 200 // 增加高度以容纳选择控制
            color: "#f8f8f8"
            radius: 5
            border.color: "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Button {
                        text: "项目选择"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        onClicked: projectSelectionPopup.open()

                        background: Rectangle {
                            color: parent.pressed ? "#2d5a2d" : "#4caf50"
                            radius: 5
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "仓库管理"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        onClicked: warehousePopup.open()

                        background: Rectangle {
                            color: parent.pressed ? "#3a7ab3" : "#4a90e2"
                            radius: 5
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                // 添加搜索框
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    color: "#ffffff"
                    radius: 4
                    border.color: "#e0e0e0"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 5

                        // 搜索图标
                        Text {
                            text: "🔍"
                            font.pixelSize: 14
                            color: "#888888"
                        }

                        // 搜索输入框
                        TextField {
                            id: searchInput

                            Layout.fillWidth: true
                            placeholderText: "搜索模块名称或代码..."
                            font.pixelSize: 13
                            color: "#333333"
                            selectByMouse: true
                            onTextChanged: {
                                searchFilter = text;
                                filterModules();
                            }

                            background: Item {}
                        }

                        // 清除按钮
                        Text {
                            text: "✕"
                            font.pixelSize: 14
                            color: "#888888"
                            visible: searchInput.text.length > 0

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -5
                                onClicked: {
                                    searchInput.text = "";
                                    searchInput.focus = true;
                                }
                            }
                        }
                    }
                }

                // 添加选择控制行
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "#f0f7ff"
                    radius: 4
                    border.color: "#d0e7ff"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        CheckBox {
                            id: selectAllCheckBox
                            checked: selectAllChecked
                            onClicked: selectAll()

                            indicator: Rectangle {
                                implicitWidth: 18
                                implicitHeight: 18
                                x: selectAllCheckBox.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: selectAllCheckBox.checked ? "#4a90e2" : "#cccccc"
                                border.width: 2
                                color: selectAllCheckBox.checked ? "#4a90e2" : "#ffffff"

                                Text {
                                    anchors.centerIn: parent
                                    text: "✓"
                                    color: "white"
                                    font.pixelSize: 12
                                    visible: selectAllCheckBox.checked
                                }
                            }

                            contentItem: Text {
                                text: "全选"
                                font.pixelSize: 13
                                color: "#333333"
                                leftPadding: selectAllCheckBox.indicator.width + selectAllCheckBox.spacing
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Text {
                            text: "已选择 " + selectedIndices.length + " 个模块"
                            font.pixelSize: 13
                            color: "#666666"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "清除选择"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 28
                            enabled: selectedIndices.length > 0
                            onClicked: clearSelection()

                            background: Rectangle {
                                color: parent.enabled ? (parent.pressed ? "#e0e0e0" : "#f0f0f0") : "#f8f8f8"
                                radius: 4
                                border.color: "#cccccc"
                                border.width: 1
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: parent.enabled ? "#666666" : "#cccccc"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Button {
                        text: "添加模块"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        onClicked: moduleSelectionPopup.open()

                        background: Rectangle {
                            color: parent.pressed ? "#3a7ab3" : "#4a90e2"
                            radius: 5
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    Button {
                        text: "删除模块"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        enabled: selectedIndices.length > 0
                        onClicked: deleteConfirmDialog.open()

                        background: Rectangle {
                            color: parent.enabled ? (parent.pressed ? "#c82333" : "#dc3545") : "#cccccc"
                            radius: 5
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    Button {
                        // 显示提示信息

                        text: "回路导入"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        onClicked: {
                            editorLabelModify.open();
                        }

                        background: Rectangle {
                            color: parent.pressed ? "#3a7ab3" : "#4a90e2"
                            radius: 5
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        delegate: Rectangle {
            id: delegateItem

            width: libraryListView.width
            height: 60
            color: {
                if (selectedIndices.indexOf(index) !== -1)
                    return "#e3f2fd";
                if (libraryListView.currentIndex === index)
                    return "#f0f7ff";
                return index % 2 === 0 ? "#ffffff" : "#f9f9f9";
            }
            radius: 5
            border.color: selectedIndices.indexOf(index) !== -1 ? "#2196f3" : "#e0e0e0"
            border.width: selectedIndices.indexOf(index) !== -1 ? 2 : 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                // 添加复选框
                CheckBox {
                    id: itemCheckBox
                    checked: selectedIndices.indexOf(index) !== -1
                    onClicked: toggleSelection(index)

                    indicator: Rectangle {
                        implicitWidth: 16
                        implicitHeight: 16
                        x: itemCheckBox.leftPadding
                        y: parent.height / 2 - height / 2
                        radius: 3
                        border.color: itemCheckBox.checked ? "#4a90e2" : "#cccccc"
                        border.width: 2
                        color: itemCheckBox.checked ? "#4a90e2" : "#ffffff"

                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: "white"
                            font.pixelSize: 10
                            visible: itemCheckBox.checked
                        }
                    }
                }

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: model.nstate === 1 ? "red" : "green"

                    Text {
                        anchors.centerIn: parent
                        text: (index + 1)
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        text: model.code
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                        elide: Text.ElideRight
                    }

                    Text {
                        text: model.name
                        font.pixelSize: 13
                        color: "#666666"
                        elide: Text.ElideRight
                    }
                }
            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    libraryListView.currentIndex = index;
                    // 根据当前使用的模型确定如何获取数据
                    if (libraryListView.model === tempModel) {
                        // 如果使用DelegateModel，需要通过items获取实际数据
                        var item = tempModel.items.get(index);
                        if (item && item.model)
                            moduleData.selectModule(item.model);
                    } else {
                        // 直接使用原始模型
                        moduleData.selectModule(model);
                    }
                }
            }

            // 添加鼠标悬停效果
            states: State {
                name: "hovered"
                when: mouseArea.containsMouse

                PropertyChanges {
                    target: delegateItem
                    color: selectedIndices.indexOf(index) !== -1 ? "#bbdefb" : "#e8f4ff"
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
            width: 10

            contentItem: Rectangle {
                implicitWidth: 6
                implicitHeight: 100
                radius: 3
                color: parent.pressed ? "#606060" : "#909090"
            }
        }
    }

    // 删除确认对话框
    Popup {
        id: deleteConfirmDialog
        anchors.centerIn: parent
        width: 400
        height: 200
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#ffffff"
            radius: 8
            border.color: "#e0e0e0"
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // 标题栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: "#dc3545"

                    Text {
                        anchors.centerIn: parent
                        text: "⚠"
                        font.pixelSize: 16
                        color: "white"
                    }
                }

                Text {
                    text: "确认删除"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#333333"
                    font.family: "Microsoft YaHei"
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "✕"
                    width: 30
                    height: 30
                    onClicked: deleteConfirmDialog.close()

                    background: Rectangle {
                        color: parent.hovered ? "#f0f0f0" : "transparent"
                        radius: 15
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                    }
                }
            }

            // 确认信息
            Text {
                Layout.fillWidth: true
                text: "确定要删除选中的 " + selectedIndices.length + " 个模块吗？\n此操作不可撤销。"
                font.pixelSize: 14
                color: "#666666"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                font.family: "Microsoft YaHei"
            }

            // 底部按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "取消"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36

                    onClicked: {
                        deleteConfirmDialog.close();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#d0d0d0" : "#f0f0f0"
                        radius: 6
                        border.color: "#cccccc"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.family: "Microsoft YaHei"
                    }
                }

                Button {
                    text: "确认删除"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36

                    onClicked: {
                        deleteSelectedModules();
                        deleteConfirmDialog.close();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#c82333" : "#dc3545"
                        radius: 6
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.family: "Microsoft YaHei"
                    }
                }
            }
        }
    }

    // 项目选择弹窗
    Popup {
        id: projectSelectionPopup

        width: 600
        height: 500
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#ffffff"
            radius: 10
            border.color: "#e0e0e0"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // 标题栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: "#4caf50"

                    Text {
                        anchors.centerIn: parent
                        text: "📁"
                        font.pixelSize: 16
                    }
                }

                Text {
                    text: "项目选择"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#333333"
                    font.family: "Microsoft YaHei"
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "✕"
                    width: 30
                    height: 30
                    onClicked: projectSelectionPopup.close()

                    background: Rectangle {
                        color: parent.hovered ? "#f0f0f0" : "transparent"
                        radius: 15
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                    }
                }
            }

            // 当前选中项目显示
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "#f8f9fa"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Text {
                        text: "当前项目:"
                        font.pixelSize: 14
                        color: "#666666"
                        font.family: "Microsoft YaHei"
                    }

                    Text {
                        id: currentProjectText
                        text: "未选择项目"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                        font.family: "Microsoft YaHei"
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }
            }

            // 状态提示信息
            Rectangle {
                id: statusMessage
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: "#d4edda"
                border.color: "#c3e6cb"
                border.width: 1
                radius: 4
                visible: false

                Text {
                    id: statusText
                    anchors.centerIn: parent
                    font.pixelSize: 12
                    color: "#155724"
                    font.family: "Microsoft YaHei"
                }

                Timer {
                    id: statusTimer
                    interval: 3000
                    onTriggered: statusMessage.visible = false
                }
            }

            // 项目列表
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: projectListView

                    model: ListModel {
                        id: projectListModel
                    }

                    spacing: 5

                    delegate: Rectangle {
                        width: projectListView.width
                        height: 60
                        color: projectMouseArea.containsMouse ? "#f0f7ff" : "#ffffff"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 6

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 12
                                color: "#4caf50"

                                Text {
                                    anchors.centerIn: parent
                                    text: "📄"
                                    font.pixelSize: 12
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: model.displayName || model.name || ""
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333333"
                                    font.family: "Microsoft YaHei"
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: model.description || "无描述"
                                    font.pixelSize: 11
                                    color: "#888888"
                                    font.family: "Microsoft YaHei"
                                    elide: Text.ElideRight
                                }
                            }

                            Button {
                                text: "选择"
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 28

                                onClicked: {
                                    selectProject(model.name);
                                }

                                background: Rectangle {
                                    color: parent.pressed ? "#218838" : "#28a745"
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 10
                                    font.family: "Microsoft YaHei"
                                }
                            }

                            Button {
                                text: "删除"
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 28

                                onClicked: {
                                    deleteProject(model.name);
                                }

                                background: Rectangle {
                                    color: parent.pressed ? "#c82333" : "#dc3545"
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 10
                                    font.family: "Microsoft YaHei"
                                }
                            }
                        }

                        MouseArea {
                            id: projectMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }

            // 底部按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "新建项目"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36

                    onClicked: {
                        createProjectDialog.open();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#218838" : "#28a745"
                        radius: 6
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.family: "Microsoft YaHei"
                    }
                }

                Button {
                    text: "刷新列表"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36

                    onClicked: {
                        loadProjectList();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#3a7ab3" : "#4a90e2"
                        radius: 6
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.family: "Microsoft YaHei"
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "取消"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36

                    onClicked: {
                        projectSelectionPopup.close();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#d0d0d0" : "#f0f0f0"
                        radius: 6
                        border.color: "#cccccc"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.family: "Microsoft YaHei"
                    }
                }
            }
        }

        // 弹窗打开时加载项目列表
        onOpened: {
            loadProjectList();
        }
    }

    // 新建项目对话框
    Popup {
        id: createProjectDialog

        width: 400
        height: 300
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: "#ffffff"
            radius: 10
            border.color: "#e0e0e0"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // 标题栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: "#28a745"

                    Text {
                        anchors.centerIn: parent
                        text: "➕"
                        font.pixelSize: 16
                        color: "white"
                    }
                }

                Text {
                    text: "新建项目"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#333333"
                    font.family: "Microsoft YaHei"
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            // 项目名称输入
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "项目名称:"
                    font.pixelSize: 14
                    color: "#666666"
                    font.family: "Microsoft YaHei"
                }

                TextField {
                    id: projectNameField
                    Layout.fillWidth: true
                    placeholderText: "请输入项目名称"
                    font.pixelSize: 14
                    selectByMouse: true

                    background: Rectangle {
                        color: "#f8f9fa"
                        border.color: parent.focus ? "#007bff" : "#dcdfe6"
                        border.width: parent.focus ? 2 : 1
                        radius: 6
                    }
                }

                Text {
                    text: "项目描述:"
                    font.pixelSize: 14
                    color: "#666666"
                    font.family: "Microsoft YaHei"
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    clip: true

                    TextArea {
                        id: projectDescField
                        placeholderText: "请输入项目描述（可选）"
                        font.pixelSize: 12
                        selectByMouse: true
                        wrapMode: TextArea.Wrap

                        background: Rectangle {
                            color: "#f8f9fa"
                            border.color: parent.focus ? "#007bff" : "#dcdfe6"
                            border.width: parent.focus ? 2 : 1
                            radius: 6
                        }
                    }
                }
            }

            // 底部按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "取消"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36

                    onClicked: {
                        createProjectDialog.close();
                        clearCreateDialog();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#d0d0d0" : "#f0f0f0"
                        radius: 6
                        border.color: "#cccccc"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.family: "Microsoft YaHei"
                    }
                }

                Button {
                    text: "创建"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36

                    onClicked: {
                        createProject();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#218838" : "#28a745"
                        radius: 6
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.family: "Microsoft YaHei"
                    }
                }
            }
        }
    }

    // 删除项目确认对话框
    Popup {
        id: deleteProjectDialog

        width: 350
        height: 200
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        property string projectToDelete: ""

        background: Rectangle {
            color: "#ffffff"
            radius: 10
            border.color: "#e0e0e0"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // 标题栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: "#dc3545"

                    Text {
                        anchors.centerIn: parent
                        text: "⚠️"
                        font.pixelSize: 16
                    }
                }

                Text {
                    text: "删除项目"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#333333"
                    font.family: "Microsoft YaHei"
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            // 确认信息
            Text {
                Layout.fillWidth: true
                text: "确定要删除项目 \"" + deleteProjectDialog.projectToDelete + "\" 吗？\n\n此操作不可撤销！"
                font.pixelSize: 14
                color: "#666666"
                font.family: "Microsoft YaHei"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            // 底部按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "取消"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36

                    onClicked: {
                        deleteProjectDialog.close();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#d0d0d0" : "#f0f0f0"
                        radius: 6
                        border.color: "#cccccc"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.family: "Microsoft YaHei"
                    }
                }

                Button {
                    text: "确认删除"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36

                    onClicked: {
                        confirmDeleteProject();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#c82333" : "#dc3545"
                        radius: 6
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.family: "Microsoft YaHei"
                    }
                }
            }
        }
    }

    // 加载项目列表的函数
    function loadProjectList() {
        projectListModel.clear();

        // 使用QmlFileOpt获取projects目录下的文件列表
        if (typeof qmlFileOpt !== "undefined") {
            try {
                var projectFiles = qmlFileOpt.entryList("projects");
                console.log("获取到的文件列表:", projectFiles);

                for (var i = 0; i < projectFiles.length; i++) {
                    var fileName = projectFiles[i];
                    console.log("处理文件:", fileName);

                    // 过滤掉目录和隐藏文件
                    if (fileName !== "." && fileName !== ".." && !fileName.startsWith(".")) {
                        // 过滤项目文件（可以根据需要调整过滤条件）
                        if (fileName.endsWith(".json") || fileName.endsWith(".txt") || fileName.endsWith(".ini")) {
                            var projectInfo = getProjectInfo(fileName);
                            projectListModel.append(projectInfo);
                            console.log("添加项目文件:", fileName);
                        }
                    }
                }
            } catch (error) {
                console.error("加载项目列表时出错:", error);
            }
        } else {
            console.error("qmlFileOpt未定义，无法加载项目列表");
        }

        console.log("已加载项目列表，共", projectListModel.count, "个项目");
    }

    // 选择项目的函数
    function selectProject(projectName) {
        currentProjectText.text = projectName;

        // 加载项目数据到programModel
        console.log("选择项目:", projectName);

        // 如果存在programModel，加载项目数据
        if (typeof programModel !== "undefined") {
            if (programModel.loadProject(projectName)) {
                console.log("项目数据加载成功");
                // 可以在这里添加成功提示
            } else {
                console.error("项目数据加载失败");
                // 可以在这里添加错误提示
            }
        }

        // 通知其他组件项目已选择
        if (typeof moduleData !== "undefined") {
            moduleData.currentProject = projectName;
        }

        projectSelectionPopup.close();
    }

    // 创建项目的函数
    function createProject() {
        var projectName = projectNameField.text.trim();
        var description = projectDescField.text.trim();

        if (!projectName) {
            console.error("项目名称不能为空");
            showStatusMessage("项目名称不能为空", "error");
            return;
        }

        // 确保文件扩展名
        if (!projectName.endsWith(".json")) {
            projectName += ".json";
        }

        // 检查项目是否已存在
        var projectPath = "projects/" + projectName;
        if (typeof qmlFileOpt !== "undefined" && qmlFileOpt.isExist(projectPath)) {
            console.error("项目已存在:", projectName);
            showStatusMessage("项目已存在: " + projectName, "error");
            return;
        }

        // 创建项目数据结构
        var projectData = {
            "projectName": projectName.replace(".json", ""),
            "description": description,
            "version": "1.0.0",
            "createTime": qmlFileOpt ? qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss") : new Date().toISOString(),
            "updateTime": qmlFileOpt ? qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss") : new Date().toISOString(),
            "modules": [],
            "points": [],
            "loops": [],
            "config": {
                "autoSave": true,
                "backupEnabled": true,
                "maxHistory": 50
            }
        };

        try {
            // 保存项目文件
            var jsonContent = JSON.stringify(projectData, null, 2);
            if (typeof qmlFileOpt !== "undefined" && qmlFileOpt.write(projectPath, jsonContent)) {
                console.log("项目创建成功:", projectName);

                // 关闭对话框并清空输入
                createProjectDialog.close();
                clearCreateDialog();

                // 刷新项目列表
                loadProjectList();

                // 自动选择新创建的项目
                selectProject(projectName);

                // 显示成功消息
                showStatusMessage("项目创建成功: " + projectName, "success");
            } else {
                console.error("保存项目文件失败");
                showStatusMessage("保存项目文件失败", "error");
            }
        } catch (error) {
            console.error("创建项目失败:", error);
            showStatusMessage("创建项目失败: " + error.toString(), "error");
        }
    }

    // 删除项目的函数
    function deleteProject(projectName) {
        deleteProjectDialog.projectToDelete = projectName;
        deleteProjectDialog.open();
    }

    // 确认删除项目的函数
    function confirmDeleteProject() {
        var projectName = deleteProjectDialog.projectToDelete;
        if (!projectName) {
            return;
        }

        var projectPath = "projects/" + projectName;

        try {
            if (typeof qmlFileOpt !== "undefined" && qmlFileOpt.remove(projectPath)) {
                console.log("项目删除成功:", projectName);

                // 如果删除的是当前选中的项目，清空当前项目显示
                if (currentProjectText.text === projectName) {
                    currentProjectText.text = "未选择项目";
                }

                // 关闭对话框
                deleteProjectDialog.close();

                // 刷新项目列表
                loadProjectList();

                // 显示成功消息
                showStatusMessage("项目删除成功: " + projectName, "success");
            } else {
                console.error("删除项目文件失败");
                showStatusMessage("删除项目文件失败", "error");
            }
        } catch (error) {
            console.error("删除项目失败:", error);
            showStatusMessage("删除项目失败: " + error.toString(), "error");
        }
    }

    // 清空创建项目对话框的函数
    function clearCreateDialog() {
        projectNameField.text = "";
        projectDescField.text = "";
    }

    // 获取项目信息的函数
    function getProjectInfo(fileName) {
        var projectInfo = {
            "name": fileName,
            "displayName": fileName.replace(/\.(json|ini|txt)$/, ""),
            "description": "无描述",
            "version": "1.0.0",
            "createTime": "",
            "type": fileName.split('.').pop()
        };

        // 尝试读取项目文件获取详细信息
        if (typeof qmlFileOpt !== "undefined") {
            try {
                var projectPath = "projects/" + fileName;
                var content = qmlFileOpt.read(projectPath);

                if (content && content.trim() !== "" && fileName.endsWith(".json")) {
                    var data = JSON.parse(content);
                    projectInfo.displayName = data.projectName || projectInfo.displayName;
                    projectInfo.description = data.description || "无描述";
                    projectInfo.version = data.version || "1.0.0";
                    projectInfo.createTime = data.createTime || "";
                }
            } catch (error) {
                console.warn("读取项目信息失败:", fileName, error);
            }
        }

        return projectInfo;
    }

    // 显示状态消息的函数
    function showStatusMessage(message, type) {
        statusText.text = message;

        // 根据类型设置颜色
        if (type === "success") {
            statusMessage.color = "#d4edda";
            statusMessage.border.color = "#c3e6cb";
            statusText.color = "#155724";
        } else if (type === "error") {
            statusMessage.color = "#f8d7da";
            statusMessage.border.color = "#f5c6cb";
            statusText.color = "#721c24";
        } else {
            statusMessage.color = "#d1ecf1";
            statusMessage.border.color = "#bee5eb";
            statusText.color = "#0c5460";
        }

        statusMessage.visible = true;
        statusTimer.restart();
    }
}
