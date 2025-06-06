import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Item {
    id: projectWorkspace

    width: 1200
    height: 800

    // 程序数据模型
    ProgramModel {
        id: programModel

        onProjectLoaded: function (projectName) {
            console.log("项目已加载:", projectName);
        }

        onProjectSaved: function (projectName) {
            console.log("项目已保存:", projectName);
        }

        onProjectCreated: function (projectName) {
            console.log("项目已创建:", projectName);
        }

        onProjectDeleted: function (projectName) {
            console.log("项目已删除:", projectName);
        }

        onProjectError: function (errorMessage) {
            console.error("项目错误:", errorMessage);
        }
    }

    // 主布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#2c3e50"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 20

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: "#3498db"

                    Text {
                        anchors.centerIn: parent
                        text: "📁"
                        font.pixelSize: 20
                        color: "white"
                    }
                }

                Text {
                    text: "项目管理工作空间"
                    font.pixelSize: 20
                    font.bold: true
                    color: "white"
                    font.family: "Microsoft YaHei"
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "当前项目: " + (programModel.currentProjectName || "无")
                    font.pixelSize: 14
                    color: "#bdc3c7"
                    font.family: "Microsoft YaHei"
                }
            }
        }

        // 工具栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#34495e"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Button {
                    text: "新建项目"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 32

                    onClicked: {
                        projectManager.createProjectDialog.open();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#27ae60" : "#2ecc71"
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
                    text: "保存项目"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 32
                    enabled: programModel.isProjectLoaded

                    onClicked: {
                        programModel.saveProject();
                    }

                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#2980b9" : "#3498db") : "#7f8c8d"
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
                    text: "关闭项目"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 32
                    enabled: programModel.isProjectLoaded

                    onClicked: {
                        programModel.closeProject();
                    }

                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#c0392b" : "#e74c3c") : "#7f8c8d"
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

                Item {
                    Layout.fillWidth: true
                }

                // 项目状态指示器
                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 30
                    color: getProjectStatusColor()
                    radius: 15
                    visible: programModel.isProjectLoaded

                    Text {
                        anchors.centerIn: parent
                        text: getProjectStatusText()
                        color: "white"
                        font.pixelSize: 11
                        font.family: "Microsoft YaHei"
                    }
                }
            }
        }

        // 标签栏
        TabBar {
            id: tabBar
            Layout.fillWidth: true

            TabButton {
                text: "项目管理"
                font.family: "Microsoft YaHei"
            }

            TabButton {
                text: "项目统计"
                font.family: "Microsoft YaHei"
                enabled: programModel.isProjectLoaded
            }

            TabButton {
                text: "项目配置"
                font.family: "Microsoft YaHei"
                enabled: programModel.isProjectLoaded
            }
        }

        // 内容区域
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            // 项目管理页面
            ProjectManager {
                id: projectManager
                programModel: projectWorkspace.programModel

                onProjectSelected: function (projectName) {
                    console.log("已选择项目:", projectName);
                }

                onProjectCreated: function (projectName) {
                    console.log("项目创建成功:", projectName);
                }

                onProjectDeleted: function (projectName) {
                    console.log("项目删除成功:", projectName);
                }
            }

            // 项目统计页面
            ProjectStats {
                id: projectStats
                programModel: projectWorkspace.programModel

                onStatsUpdated: {
                    console.log("统计数据已更新");
                }

                onExportRequested: function (format) {
                    console.log("导出数据:", format);
                }
            }

            // 项目配置页面
            ProjectConfig {
                id: projectConfig
                programModel: projectWorkspace.programModel

                onConfigSaved: {
                    console.log("配置保存成功");
                }

                onConfigCancelled: {
                    console.log("配置编辑已取消");
                }
            }
        }

        // 状态栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "#ecf0f1"
            border.color: "#bdc3c7"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 15

                Text {
                    text: "就绪"
                    font.pixelSize: 11
                    color: "#2c3e50"
                    font.family: "Microsoft YaHei"
                    Layout.fillWidth: true
                }

                Text {
                    text: "项目: " + (programModel.currentProjectName || "无")
                    font.pixelSize: 11
                    color: "#7f8c8d"
                    font.family: "Microsoft YaHei"
                }

                Text {
                    text: "版本: " + (programModel.currentProjectData.version || "N/A")
                    font.pixelSize: 11
                    color: "#7f8c8d"
                    font.family: "Microsoft YaHei"
                    visible: programModel.isProjectLoaded
                }
            }
        }
    }

    // 获取项目状态颜色
    function getProjectStatusColor() {
        if (!programModel.isProjectLoaded) {
            return "#95a5a6";
        }

        if (programModel.hasUnsavedChanges) {
            return "#f39c12";
        }

        return "#27ae60";
    }

    // 获取项目状态文本
    function getProjectStatusText() {
        if (!programModel.isProjectLoaded) {
            return "无项目";
        }

        if (programModel.hasUnsavedChanges) {
            return "有更改";
        }

        return "已保存";
    }

    Component.onCompleted: {
        console.log("项目管理工作空间初始化完成");
    }
}
