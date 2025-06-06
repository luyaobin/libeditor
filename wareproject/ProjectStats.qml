import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtCharts 2.14

Item {
    id: projectStats

    // ==================== 属性定义 ====================

    property var programModel: null
    property var statsData: ({})
    property bool autoRefresh: true
    property int refreshInterval: 5000 // 5秒

    // ==================== 信号定义 ====================

    signal statsUpdated
    signal exportRequested(string format)

    // ==================== 定时器 ====================

    Timer {
        id: refreshTimer
        interval: refreshInterval
        running: autoRefresh && programModel && programModel.isProjectLoaded
        repeat: true
        onTriggered: updateStats()
    }

    // ==================== 主界面布局 ====================

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 20

        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: "#6f42c1"

                    Text {
                        anchors.centerIn: parent
                        text: "📊"
                        font.pixelSize: 16
                    }
                }

                Text {
                    text: "项目统计"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#495057"
                    font.family: "Microsoft YaHei"
                }

                Item {
                    Layout.fillWidth: true
                }

                Switch {
                    id: autoRefreshSwitch
                    text: "自动刷新"
                    checked: autoRefresh
                    onCheckedChanged: autoRefresh = checked
                }

                Button {
                    text: "刷新"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32

                    onClicked: updateStats()

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

        // 统计卡片区域
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 20

                // 基本统计卡片
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    color: "#ffffff"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        Text {
                            text: "基本统计"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#495057"
                            font.family: "Microsoft YaHei"
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 4
                            columnSpacing: 30
                            rowSpacing: 10

                            // 模块数量
                            ColumnLayout {
                                spacing: 5

                                Text {
                                    text: statsData.moduleCount || "0"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#007bff"
                                    font.family: "Microsoft YaHei"
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Text {
                                    text: "模块数量"
                                    font.pixelSize: 12
                                    color: "#6c757d"
                                    font.family: "Microsoft YaHei"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            // 点位数量
                            ColumnLayout {
                                spacing: 5

                                Text {
                                    text: statsData.pointCount || "0"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#28a745"
                                    font.family: "Microsoft YaHei"
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Text {
                                    text: "点位数量"
                                    font.pixelSize: 12
                                    color: "#6c757d"
                                    font.family: "Microsoft YaHei"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            // 回路数量
                            ColumnLayout {
                                spacing: 5

                                Text {
                                    text: statsData.loopCount || "0"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#ffc107"
                                    font.family: "Microsoft YaHei"
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Text {
                                    text: "回路数量"
                                    font.pixelSize: 12
                                    color: "#6c757d"
                                    font.family: "Microsoft YaHei"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            // 配置项数量
                            ColumnLayout {
                                spacing: 5

                                Text {
                                    text: statsData.configCount || "0"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#dc3545"
                                    font.family: "Microsoft YaHei"
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Text {
                                    text: "配置项"
                                    font.pixelSize: 12
                                    color: "#6c757d"
                                    font.family: "Microsoft YaHei"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }

                // 项目信息卡片
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    color: "#ffffff"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        Text {
                            text: "项目信息"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#495057"
                            font.family: "Microsoft YaHei"
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 30
                            rowSpacing: 8

                            Text {
                                text: "项目名称:"
                                font.pixelSize: 12
                                color: "#6c757d"
                                font.family: "Microsoft YaHei"
                            }

                            Text {
                                text: statsData.projectName || "无"
                                font.pixelSize: 12
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "项目版本:"
                                font.pixelSize: 12
                                color: "#6c757d"
                                font.family: "Microsoft YaHei"
                            }

                            Text {
                                text: statsData.version || "1.0.0"
                                font.pixelSize: 12
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                            }

                            Text {
                                text: "创建时间:"
                                font.pixelSize: 12
                                color: "#6c757d"
                                font.family: "Microsoft YaHei"
                            }

                            Text {
                                text: statsData.createTime || "未知"
                                font.pixelSize: 12
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                            }

                            Text {
                                text: "最后保存:"
                                font.pixelSize: 12
                                color: "#6c757d"
                                font.family: "Microsoft YaHei"
                            }

                            Text {
                                text: statsData.lastSaveTime || "从未"
                                font.pixelSize: 12
                                color: statsData.hasUnsavedChanges ? "#dc3545" : "#495057"
                                font.family: "Microsoft YaHei"
                            }

                            Text {
                                text: "项目状态:"
                                font.pixelSize: 12
                                color: "#6c757d"
                                font.family: "Microsoft YaHei"
                            }

                            Rectangle {
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 20
                                color: getStatusColor()
                                radius: 10

                                Text {
                                    anchors.centerIn: parent
                                    text: getStatusText()
                                    font.pixelSize: 10
                                    color: "white"
                                    font.family: "Microsoft YaHei"
                                }
                            }
                        }
                    }
                }

                // 模块类型分布图表
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    color: "#ffffff"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        Text {
                            text: "模块类型分布"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#495057"
                            font.family: "Microsoft YaHei"
                        }

                        ChartView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            antialiasing: true
                            legend.visible: true
                            legend.alignment: Qt.AlignBottom

                            PieSeries {
                                id: moduleTypePieSeries
                                name: "模块类型"
                            }
                        }
                    }
                }

                // 历史记录
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 250
                    color: "#ffffff"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "操作历史"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Button {
                                text: "清空历史"
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 28

                                onClicked: clearHistory()

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

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ListView {
                                id: historyListView

                                model: programModel ? programModel.historyModel : null
                                spacing: 5

                                delegate: Rectangle {
                                    width: historyListView.width
                                    height: 40
                                    color: index % 2 === 0 ? "#f8f9fa" : "#ffffff"
                                    radius: 4

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 15

                                        Rectangle {
                                            width: 24
                                            height: 24
                                            radius: 12
                                            color: getActionColor(model.action)

                                            Text {
                                                anchors.centerIn: parent
                                                text: getActionIcon(model.action)
                                                font.pixelSize: 12
                                                color: "white"
                                            }
                                        }

                                        Text {
                                            text: model.action || ""
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: "#495057"
                                            font.family: "Microsoft YaHei"
                                            Layout.preferredWidth: 80
                                        }

                                        Text {
                                            text: model.target || ""
                                            font.pixelSize: 12
                                            color: "#495057"
                                            font.family: "Microsoft YaHei"
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: model.timestamp || ""
                                            font.pixelSize: 10
                                            color: "#6c757d"
                                            font.family: "Microsoft YaHei"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // 导出功能
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#f8f9fa"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 6

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        Text {
                            text: "数据导出"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#495057"
                            font.family: "Microsoft YaHei"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "导出JSON"
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 32

                            onClicked: exportRequested("json")

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

                        Button {
                            text: "导出CSV"
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 32

                            onClicked: exportRequested("csv")

                            background: Rectangle {
                                color: parent.pressed ? "#218838" : "#28a745"
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
        }
    }

    // ==================== 功能函数 ====================

    // 更新统计数据
    function updateStats() {
        if (!programModel || !programModel.isProjectLoaded) {
            statsData = {};
            return;
        }

        try {
            statsData = programModel.getProjectStats();

            // 添加额外的统计信息
            statsData.configCount = programModel.configModel.count;

            // 更新模块类型分布图表
            updateModuleTypeChart();

            console.log("统计数据更新完成");
            statsUpdated();
        } catch (error) {
            console.error("更新统计数据失败:", error);
        }
    }

    // 更新模块类型分布图表
    function updateModuleTypeChart() {
        if (!programModel)
            return;

        moduleTypePieSeries.clear();

        var typeCount = {};

        // 统计模块类型
        for (var i = 0; i < programModel.moduleModel.count; i++) {
            var module = programModel.moduleModel.get(i);
            var type = module.type || "unknown";

            if (typeCount[type]) {
                typeCount[type]++;
            } else {
                typeCount[type] = 1;
            }
        }

        // 添加到图表
        for (var type in typeCount) {
            moduleTypePieSeries.append(type + " (" + typeCount[type] + ")", typeCount[type]);
        }
    }

    // 获取状态颜色
    function getStatusColor() {
        if (!programModel || !programModel.isProjectLoaded) {
            return "#6c757d";
        }

        if (programModel.hasUnsavedChanges) {
            return "#ffc107";
        }

        return "#28a745";
    }

    // 获取状态文本
    function getStatusText() {
        if (!programModel || !programModel.isProjectLoaded) {
            return "未加载";
        }

        if (programModel.hasUnsavedChanges) {
            return "有更改";
        }

        return "已保存";
    }

    // 获取操作颜色
    function getActionColor(action) {
        switch (action) {
        case "创建项目":
        case "打开项目":
            return "#28a745";
        case "保存项目":
            return "#007bff";
        case "删除项目":
            return "#dc3545";
        default:
            return "#6c757d";
        }
    }

    // 获取操作图标
    function getActionIcon(action) {
        switch (action) {
        case "创建项目":
            return "➕";
        case "打开项目":
            return "📂";
        case "保存项目":
            return "💾";
        case "删除项目":
            return "🗑️";
        default:
            return "📝";
        }
    }

    // 清空历史记录
    function clearHistory() {
        if (programModel && programModel.historyModel) {
            programModel.historyModel.clear();
            console.log("历史记录已清空");
        }
    }

    // 导出统计数据
    function exportStats(format) {
        if (!programModel) {
            return "";
        }

        return programModel.exportProject(format);
    }

    // ==================== 监听器 ====================

    // 监听项目变化
    Connections {
        target: programModel

        function onProjectLoaded() {
            updateStats();
        }

        function onDataLoaded() {
            updateStats();
        }

        function onDataChanged() {
            if (autoRefresh) {
                updateStats();
            }
        }

        function onModelUpdated() {
            if (autoRefresh) {
                updateStats();
            }
        }
    }

    // ==================== 初始化 ====================

    Component.onCompleted: {
        if (programModel && programModel.isProjectLoaded) {
            updateStats();
        }
    }
}
