import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Item {
    id: projectConfig

    // ==================== 属性定义 ====================

    property var programModel: null
    property bool isEditing: false
    property var currentConfig: ({})

    // ==================== 信号定义 ====================

    signal configSaved
    signal configCancelled
    signal configChanged

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
                    color: "#17a2b8"

                    Text {
                        anchors.centerIn: parent
                        text: "⚙️"
                        font.pixelSize: 16
                    }
                }

                Text {
                    text: "项目配置"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#495057"
                    font.family: "Microsoft YaHei"
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: programModel ? ("项目: " + (programModel.currentProjectName || "无")) : "无项目"
                    font.pixelSize: 12
                    color: "#6c757d"
                    font.family: "Microsoft YaHei"
                }
            }
        }

        // 配置内容
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 20

                // 基本信息配置
                GroupBox {
                    Layout.fillWidth: true
                    title: "基本信息"
                    font.family: "Microsoft YaHei"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 15

                        // 项目名称
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "项目名称:"
                                font.pixelSize: 14
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                                Layout.preferredWidth: 100
                            }

                            TextField {
                                id: projectNameField
                                Layout.fillWidth: true
                                font.pixelSize: 14
                                selectByMouse: true
                                enabled: isEditing

                                onTextChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }
                        }

                        // 项目描述
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Layout.alignment: Qt.AlignTop

                            Text {
                                text: "项目描述:"
                                font.pixelSize: 14
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                                Layout.preferredWidth: 100
                                Layout.alignment: Qt.AlignTop
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 80
                                clip: true

                                TextArea {
                                    id: projectDescField
                                    font.pixelSize: 12
                                    selectByMouse: true
                                    enabled: isEditing
                                    wrapMode: TextArea.Wrap

                                    onTextChanged: {
                                        if (isEditing) {
                                            configChanged();
                                        }
                                    }
                                }
                            }
                        }

                        // 项目版本
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "项目版本:"
                                font.pixelSize: 14
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                                Layout.preferredWidth: 100
                            }

                            TextField {
                                id: projectVersionField
                                Layout.preferredWidth: 150
                                font.pixelSize: 14
                                selectByMouse: true
                                enabled: isEditing

                                onTextChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // 系统配置
                GroupBox {
                    Layout.fillWidth: true
                    title: "系统配置"
                    font.family: "Microsoft YaHei"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 15

                        // 自动保存
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            CheckBox {
                                id: autoSaveCheck
                                text: "启用自动保存"
                                font.pixelSize: 14
                                font.family: "Microsoft YaHei"
                                enabled: isEditing

                                onCheckedChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "保存间隔(分钟):"
                                font.pixelSize: 12
                                color: "#6c757d"
                                font.family: "Microsoft YaHei"
                                visible: autoSaveCheck.checked
                            }

                            SpinBox {
                                id: autoSaveIntervalSpin
                                from: 1
                                to: 60
                                value: 5
                                enabled: isEditing && autoSaveCheck.checked

                                onValueChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }
                        }

                        // 备份设置
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            CheckBox {
                                id: backupEnabledCheck
                                text: "启用自动备份"
                                font.pixelSize: 14
                                font.family: "Microsoft YaHei"
                                enabled: isEditing

                                onCheckedChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "最大备份数:"
                                font.pixelSize: 12
                                color: "#6c757d"
                                font.family: "Microsoft YaHei"
                                visible: backupEnabledCheck.checked
                            }

                            SpinBox {
                                id: maxBackupSpin
                                from: 1
                                to: 20
                                value: 5
                                enabled: isEditing && backupEnabledCheck.checked

                                onValueChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }
                        }

                        // 历史记录
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "最大历史记录:"
                                font.pixelSize: 14
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                                Layout.preferredWidth: 120
                            }

                            SpinBox {
                                id: maxHistorySpin
                                from: 10
                                to: 200
                                value: 50
                                enabled: isEditing

                                onValueChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // 模块配置
                GroupBox {
                    Layout.fillWidth: true
                    title: "模块配置"
                    font.family: "Microsoft YaHei"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 15

                        // 默认模块类型
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "默认模块类型:"
                                font.pixelSize: 14
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                                Layout.preferredWidth: 120
                            }

                            ComboBox {
                                id: defaultModuleTypeCombo
                                Layout.preferredWidth: 200
                                model: ["sensor", "controller", "actuator", "display", "communication"]
                                enabled: isEditing

                                onCurrentTextChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        // 模块编号前缀
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "模块编号前缀:"
                                font.pixelSize: 14
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                                Layout.preferredWidth: 120
                            }

                            TextField {
                                id: moduleCodePrefixField
                                Layout.preferredWidth: 150
                                placeholderText: "例如: MOD"
                                font.pixelSize: 14
                                selectByMouse: true
                                enabled: isEditing

                                onTextChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        // 自动生成编号
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            CheckBox {
                                id: autoGenerateCodeCheck
                                text: "自动生成模块编号"
                                font.pixelSize: 14
                                font.family: "Microsoft YaHei"
                                enabled: isEditing

                                onCheckedChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // 通信配置
                GroupBox {
                    Layout.fillWidth: true
                    title: "通信配置"
                    font.family: "Microsoft YaHei"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 15

                        // 默认通信协议
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "默认通信协议:"
                                font.pixelSize: 14
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                                Layout.preferredWidth: 120
                            }

                            ComboBox {
                                id: defaultProtocolCombo
                                Layout.preferredWidth: 200
                                model: ["Modbus RTU", "Modbus TCP", "CAN", "Ethernet/IP", "Profibus"]
                                enabled: isEditing

                                onCurrentTextChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        // 默认波特率
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "默认波特率:"
                                font.pixelSize: 14
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                                Layout.preferredWidth: 120
                            }

                            ComboBox {
                                id: defaultBaudRateCombo
                                Layout.preferredWidth: 150
                                model: ["9600", "19200", "38400", "57600", "115200"]
                                currentIndex: 4
                                enabled: isEditing

                                onCurrentTextChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        // 超时设置
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "通信超时(ms):"
                                font.pixelSize: 14
                                color: "#495057"
                                font.family: "Microsoft YaHei"
                                Layout.preferredWidth: 120
                            }

                            SpinBox {
                                id: timeoutSpin
                                from: 100
                                to: 10000
                                value: 1000
                                stepSize: 100
                                enabled: isEditing

                                onValueChanged: {
                                    if (isEditing) {
                                        configChanged();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }

        // 操作按钮
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
                spacing: 10

                Text {
                    text: isEditing ? "编辑模式" : "查看模式"
                    font.pixelSize: 12
                    color: isEditing ? "#dc3545" : "#28a745"
                    font.family: "Microsoft YaHei"
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: isEditing ? "取消" : "编辑"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36
                    enabled: programModel && programModel.isProjectLoaded

                    onClicked: {
                        if (isEditing) {
                            cancelEdit();
                        } else {
                            startEdit();
                        }
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
                    text: "保存"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36
                    enabled: isEditing && programModel && programModel.isProjectLoaded

                    onClicked: {
                        saveConfig();
                    }

                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#218838" : "#28a745") : "#6c757d"
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
                    text: "重置"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36
                    enabled: isEditing

                    onClicked: {
                        resetConfig();
                    }

                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#e0a800" : "#ffc107") : "#6c757d"
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "#212529" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.family: "Microsoft YaHei"
                    }
                }
            }
        }
    }

    // ==================== 功能函数 ====================

    // 加载配置
    function loadConfig() {
        if (!programModel || !programModel.isProjectLoaded) {
            return;
        }

        var projectData = programModel.currentProjectData;
        var config = projectData.config || {};

        // 基本信息
        projectNameField.text = projectData.projectName || "";
        projectDescField.text = projectData.description || "";
        projectVersionField.text = projectData.version || "1.0.0";

        // 系统配置
        autoSaveCheck.checked = config.autoSave !== undefined ? config.autoSave : true;
        autoSaveIntervalSpin.value = config.autoSaveInterval || 5;
        backupEnabledCheck.checked = config.backupEnabled !== undefined ? config.backupEnabled : true;
        maxBackupSpin.value = config.maxBackup || 5;
        maxHistorySpin.value = config.maxHistory || 50;

        // 模块配置
        var moduleConfig = config.module || {};
        setComboBoxValue(defaultModuleTypeCombo, moduleConfig.defaultType || "sensor");
        moduleCodePrefixField.text = moduleConfig.codePrefix || "MOD";
        autoGenerateCodeCheck.checked = moduleConfig.autoGenerateCode !== undefined ? moduleConfig.autoGenerateCode : true;

        // 通信配置
        var commConfig = config.communication || {};
        setComboBoxValue(defaultProtocolCombo, commConfig.defaultProtocol || "Modbus RTU");
        setComboBoxValue(defaultBaudRateCombo, commConfig.defaultBaudRate || "115200");
        timeoutSpin.value = commConfig.timeout || 1000;

        console.log("配置加载完成");
    }

    // 保存配置
    function saveConfig() {
        if (!programModel || !programModel.isProjectLoaded) {
            return false;
        }

        try {
            // 构建配置对象
            var config = {
                // 系统配置
                autoSave: autoSaveCheck.checked,
                autoSaveInterval: autoSaveIntervalSpin.value,
                backupEnabled: backupEnabledCheck.checked,
                maxBackup: maxBackupSpin.value,
                maxHistory: maxHistorySpin.value,

                // 模块配置
                module: {
                    defaultType: defaultModuleTypeCombo.currentText,
                    codePrefix: moduleCodePrefixField.text,
                    autoGenerateCode: autoGenerateCodeCheck.checked
                },

                // 通信配置
                communication: {
                    defaultProtocol: defaultProtocolCombo.currentText,
                    defaultBaudRate: defaultBaudRateCombo.currentText,
                    timeout: timeoutSpin.value
                }
            };

            // 更新项目数据
            programModel.currentProjectData.projectName = projectNameField.text;
            programModel.currentProjectData.description = projectDescField.text;
            programModel.currentProjectData.version = projectVersionField.text;
            programModel.currentProjectData.config = config;

            // 保存项目
            if (programModel.saveProject()) {
                isEditing = false;
                console.log("配置保存成功");
                configSaved();
                return true;
            } else {
                console.error("配置保存失败");
                return false;
            }
        } catch (error) {
            console.error("保存配置时出错:", error);
            return false;
        }
    }

    // 开始编辑
    function startEdit() {
        isEditing = true;
        loadConfig();
    }

    // 取消编辑
    function cancelEdit() {
        isEditing = false;
        loadConfig(); // 重新加载原始配置
        configCancelled();
    }

    // 重置配置
    function resetConfig() {
        loadConfig();
    }

    // 设置ComboBox值
    function setComboBoxValue(comboBox, value) {
        for (var i = 0; i < comboBox.model.length; i++) {
            if (comboBox.model[i] === value) {
                comboBox.currentIndex = i;
                return;
            }
        }
    }

    // 获取默认配置
    function getDefaultConfig() {
        return {
            autoSave: true,
            autoSaveInterval: 5,
            backupEnabled: true,
            maxBackup: 5,
            maxHistory: 50,
            module: {
                defaultType: "sensor",
                codePrefix: "MOD",
                autoGenerateCode: true
            },
            communication: {
                defaultProtocol: "Modbus RTU",
                defaultBaudRate: "115200",
                timeout: 1000
            }
        };
    }

    // ==================== 监听器 ====================

    // 监听项目变化
    Connections {
        target: programModel

        function onProjectLoaded() {
            loadConfig();
        }

        function onDataLoaded() {
            loadConfig();
        }
    }

    // ==================== 初始化 ====================

    Component.onCompleted: {
        if (programModel && programModel.isProjectLoaded) {
            loadConfig();
        }
    }
}
