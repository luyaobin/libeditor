import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Item {
    id: projectManager

    // ==================== 属性定义 ====================

    property alias programModel: programModel
    property string currentFilter: ""
    property bool showCreateDialog: false
    property bool showDeleteDialog: false
    property string selectedProject: ""

    // ==================== 信号定义 ====================

    signal projectSelected(string projectName)
    signal projectCreated(string projectName)
    signal projectDeleted(string projectName)

    // ==================== 数据模型 ====================

    ProgramModel {
        id: programModel

        onProjectLoaded: function (projectName) {
            projectSelected(projectName);
        }

        onProjectCreated: function (projectName) {
            projectCreated(projectName);
        }

        onProjectDeleted: function (projectName) {
            projectDeleted(projectName);
        }

        onProjectError: function (errorMessage) {
            errorDialog.showError(errorMessage);
        }
    }

    // ==================== 主界面布局 ====================

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15

        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: "#007bff"

                    Text {
                        anchors.centerIn: parent
                        text: "📁"
                        font.pixelSize: 20
                        color: "white"
                    }
                }

                Text {
                    text: "项目管理"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#495057"
                    font.family: "Microsoft YaHei"
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "项目总数: " + programModel.projectListModel.count
                    font.pixelSize: 14
                    color: "#6c757d"
                    font.family: "Microsoft YaHei"
                }
            }
        }

        // 工具栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#ffffff"
            border.color: "#dee2e6"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // 搜索框
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: "#f8f9fa"
                    border.color: "#ced4da"
                    border.width: 1
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            text: "🔍"
                            font.pixelSize: 14
                            color: "#6c757d"
                        }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            placeholderText: "搜索项目..."
                            font.pixelSize: 12
                            color: "#495057"
                            selectByMouse: true
                            background: Item {}

                            onTextChanged: {
                                currentFilter = text;
                                filterProjects();
                            }
                        }

                        Text {
                            text: "✕"
                            font.pixelSize: 12
                            color: "#6c757d"
                            visible: searchField.text.length > 0

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4
                                onClicked: {
                                    searchField.text = "";
                                    searchField.focus = true;
                                }
                            }
                        }
                    }
                }

                // 创建项目按钮
                Button {
                    text: "创建项目"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 32

                    onClicked: {
                        createProjectDialog.open();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#0056b3" : "#007bff"
                        radius: 4
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

                // 刷新按钮
                Button {
                    text: "刷新"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32

                    onClicked: {
                        programModel.loadProjectList();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#5a6268" : "#6c757d"
                        radius: 4
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

        // 项目列表
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: projectListView

                model: filteredProjectModel
                spacing: 8
                currentIndex: -1

                delegate: Rectangle {
                    width: projectListView.width
                    height: 80
                    color: projectMouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
                    border.color: projectListView.currentIndex === index ? "#007bff" : "#dee2e6"
                    border.width: projectListView.currentIndex === index ? 2 : 1
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        // 项目图标
                        Rectangle {
                            width: 50
                            height: 50
                            radius: 25
                            color: getProjectTypeColor(model.type)

                            Text {
                                anchors.centerIn: parent
                                text: getProjectTypeIcon(model.type)
                                font.pixelSize: 20
                                color: "white"
                            }
                        }

                        // 项目信息
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: model.displayName || model.name
                                font.pixelSize: 16
                                font.bold: true
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                                elide: Text.ElideRight
                            }

                            Text {
                                text: model.description || "无描述"
                                font.pixelSize: 12
                                color: "#6c757d"
                                font.family: "Microsoft YaHei"
                                elide: Text.ElideRight
                            }

                            RowLayout {
                                spacing: 15

                                Text {
                                    text: "类型: " + (model.type || "unknown")
                                    font.pixelSize: 10
                                    color: "#868e96"
                                    font.family: "Microsoft YaHei"
                                }

                                Text {
                                    text: "版本: " + (model.version || "1.0.0")
                                    font.pixelSize: 10
                                    color: "#868e96"
                                    font.family: "Microsoft YaHei"
                                }

                                Text {
                                    text: "创建: " + (model.createTime || "未知")
                                    font.pixelSize: 10
                                    color: "#868e96"
                                    font.family: "Microsoft YaHei"
                                }
                            }
                        }

                        // 操作按钮
                        ColumnLayout {
                            spacing: 8

                            Button {
                                text: "打开"
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 28

                                onClicked: {
                                    openProject(model.name);
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
                                    selectedProject = model.name;
                                    deleteConfirmDialog.open();
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
                    }

                    MouseArea {
                        id: projectMouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            projectListView.currentIndex = index;
                        }

                        onDoubleClicked: {
                            openProject(model.name);
                        }
                    }
                }
            }
        }

        // 状态栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 15

                Text {
                    text: "当前项目: " + (programModel.currentProjectName || "无")
                    font.pixelSize: 11
                    color: "#495057"
                    font.family: "Microsoft YaHei"
                }

                Text {
                    text: programModel.hasUnsavedChanges ? "● 有未保存更改" : "已保存"
                    font.pixelSize: 11
                    color: programModel.hasUnsavedChanges ? "#dc3545" : "#28a745"
                    font.family: "Microsoft YaHei"
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "最后保存: " + (programModel.lastSaveTime || "从未")
                    font.pixelSize: 11
                    color: "#6c757d"
                    font.family: "Microsoft YaHei"
                }
            }
        }
    }

    // ==================== 过滤模型 ====================

    ListModel {
        id: filteredProjectModel
    }

    // ==================== 对话框 ====================

    // 创建项目对话框
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
            radius: 8
            border.color: "#dee2e6"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: "创建新项目"
                font.pixelSize: 18
                font.bold: true
                color: "#495057"
                font.family: "Microsoft YaHei"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "项目名称:"
                    font.pixelSize: 14
                    color: "#495057"
                    font.family: "Microsoft YaHei"
                }

                TextField {
                    id: projectNameField
                    Layout.fillWidth: true
                    placeholderText: "请输入项目名称"
                    font.pixelSize: 14
                    selectByMouse: true
                }

                Text {
                    text: "项目描述:"
                    font.pixelSize: 14
                    color: "#495057"
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
                    }
                }

                Text {
                    text: "项目模板:"
                    font.pixelSize: 14
                    color: "#495057"
                    font.family: "Microsoft YaHei"
                }

                ComboBox {
                    id: templateCombo
                    Layout.fillWidth: true
                    model: ["空项目", "传感器项目", "控制器项目", "混合项目"]
                    currentIndex: 0
                }
            }

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
                        color: parent.pressed ? "#5a6268" : "#6c757d"
                        radius: 4
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
                    text: "创建"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36
                    enabled: projectNameField.text.trim() !== ""

                    onClicked: {
                        createProject();
                    }

                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#0056b3" : "#007bff") : "#6c757d"
                        radius: 4
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

    // 删除确认对话框
    Popup {
        id: deleteConfirmDialog

        width: 350
        height: 200
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: "#ffffff"
            radius: 8
            border.color: "#dc3545"
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#f8d7da"
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Text {
                        text: "⚠️"
                        font.pixelSize: 24
                        color: "#721c24"
                    }

                    Text {
                        text: "确认删除项目"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#721c24"
                        font.family: "Microsoft YaHei"
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: "您确定要删除项目 \"" + selectedProject + "\" 吗？\n\n此操作不可撤销！"
                font.pixelSize: 14
                color: "#495057"
                font.family: "Microsoft YaHei"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

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
                        color: parent.pressed ? "#5a6268" : "#6c757d"
                        radius: 4
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
                    text: "删除"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36

                    onClicked: {
                        deleteProject();
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
                        font.pixelSize: 12
                        font.family: "Microsoft YaHei"
                    }
                }
            }
        }
    }

    // 错误对话框
    Popup {
        id: errorDialog

        property string errorMessage: ""

        width: 400
        height: 200
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        function showError(message) {
            errorMessage = message;
            open();
        }

        background: Rectangle {
            color: "#ffffff"
            radius: 8
            border.color: "#dc3545"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            RowLayout {
                spacing: 15

                Text {
                    text: "❌"
                    font.pixelSize: 24
                }

                Text {
                    text: "错误"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#dc3545"
                    font.family: "Microsoft YaHei"
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Text {
                    width: parent.width
                    text: errorDialog.errorMessage
                    font.pixelSize: 14
                    color: "#495057"
                    font.family: "Microsoft YaHei"
                    wrapMode: Text.WordWrap
                }
            }

            Button {
                text: "确定"
                Layout.preferredWidth: 80
                Layout.preferredHeight: 36
                Layout.alignment: Qt.AlignHCenter

                onClicked: {
                    errorDialog.close();
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
                    font.pixelSize: 12
                    font.family: "Microsoft YaHei"
                }
            }
        }
    }

    // ==================== 功能函数 ====================

    // 过滤项目
    function filterProjects() {
        filteredProjectModel.clear();

        for (var i = 0; i < programModel.projectListModel.count; i++) {
            var project = programModel.projectListModel.get(i);

            if (currentFilter === "" || project.name.toLowerCase().indexOf(currentFilter.toLowerCase()) !== -1 || (project.displayName && project.displayName.toLowerCase().indexOf(currentFilter.toLowerCase()) !== -1) || (project.description && project.description.toLowerCase().indexOf(currentFilter.toLowerCase()) !== -1)) {
                filteredProjectModel.append(project);
            }
        }
    }

    // 打开项目
    function openProject(projectName) {
        if (programModel.loadProject(projectName)) {
            console.log("项目打开成功:", projectName);
        }
    }

    // 创建项目
    function createProject() {
        var projectName = projectNameField.text.trim();
        var description = projectDescField.text.trim();
        var templateType = ["empty", "sensor", "controller", "mixed"][templateCombo.currentIndex];

        if (programModel.createProject(projectName, description, templateType)) {
            createProjectDialog.close();
            clearCreateDialog();
            console.log("项目创建成功:", projectName);
        }
    }

    // 删除项目
    function deleteProject() {
        if (programModel.deleteProject(selectedProject)) {
            deleteConfirmDialog.close();
            console.log("项目删除成功:", selectedProject);
        }
        selectedProject = "";
    }

    // 清空创建对话框
    function clearCreateDialog() {
        projectNameField.text = "";
        projectDescField.text = "";
        templateCombo.currentIndex = 0;
    }

    // 获取项目类型颜色
    function getProjectTypeColor(type) {
        switch (type) {
        case "json":
            return "#007bff";
        case "ini":
            return "#28a745";
        case "txt":
            return "#ffc107";
        default:
            return "#6c757d";
        }
    }

    // 获取项目类型图标
    function getProjectTypeIcon(type) {
        switch (type) {
        case "json":
            return "📄";
        case "ini":
            return "⚙️";
        case "txt":
            return "📝";
        default:
            return "📁";
        }
    }

    // ==================== 初始化 ====================

    Component.onCompleted: {
        // 监听项目列表变化
        programModel.projectListModel.onCountChanged.connect(filterProjects);

        // 初始化过滤
        filterProjects();
    }
}
