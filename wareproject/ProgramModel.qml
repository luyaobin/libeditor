import QtQuick 2.14
import QtQml.Models 2.14

QtObject {
    id: programModel

    // ==================== 基础属性 ====================

    // 当前项目信息
    property string currentProjectName: ""
    property string currentProjectPath: ""
    property var currentProjectData: ({})

    // 项目状态
    property bool isProjectLoaded: false
    property bool hasUnsavedChanges: false
    property string lastSaveTime: ""

    // ==================== 数据模型 ====================

    // 项目列表模型
    property ListModel projectListModel: ListModel {}

    // 模块数据模型
    property ListModel moduleModel: ListModel {}

    // 点位数据模型
    property ListModel pointsModel: ListModel {}

    // 回路数据模型
    property ListModel loopsModel: ListModel {}

    // 配置数据模型
    property ListModel configModel: ListModel {}

    // 历史记录模型
    property ListModel historyModel: ListModel {}

    // ==================== 信号定义 ====================

    signal projectLoaded(string projectName)
    signal projectSaved(string projectName)
    signal projectCreated(string projectName)
    signal projectDeleted(string projectName)
    signal projectError(string errorMessage)
    signal dataChanged
    signal modelUpdated(string modelType)

    // ==================== 项目管理功能 ====================

    // 加载项目列表
    function loadProjectList() {
        projectListModel.clear();

        if (typeof qmlFileOpt === "undefined") {
            projectError("文件操作组件未初始化");
            return false;
        }

        try {
            var projectFiles = qmlFileOpt.entryList("projects");
            console.log("扫描项目目录，找到文件:", projectFiles.length, "个");

            for (var i = 0; i < projectFiles.length; i++) {
                var fileName = projectFiles[i];

                // 过滤有效的项目文件
                if (isValidProjectFile(fileName)) {
                    var projectInfo = getProjectFileInfo(fileName);
                    projectListModel.append(projectInfo);
                    console.log("添加项目:", fileName);
                }
            }

            console.log("项目列表加载完成，共", projectListModel.count, "个项目");
            return true;
        } catch (error) {
            console.error("加载项目列表失败:", error);
            projectError("加载项目列表失败: " + error.toString());
            return false;
        }
    }

    // 创建新项目
    function createProject(projectName, description, templateType) {
        if (!projectName || projectName.trim() === "") {
            projectError("项目名称不能为空");
            return false;
        }

        // 确保文件扩展名
        var fileName = projectName.endsWith(".json") ? projectName : projectName + ".json";
        var projectPath = "projects/" + fileName;

        // 检查项目是否已存在
        if (qmlFileOpt.isExist(projectPath)) {
            projectError("项目已存在: " + fileName);
            return false;
        }

        try {
            // 创建项目数据结构
            var projectData = createProjectTemplate(projectName, description, templateType);

            // 保存项目文件
            var jsonContent = JSON.stringify(projectData, null, 2);
            if (qmlFileOpt.write(projectPath, jsonContent)) {
                console.log("项目创建成功:", fileName);

                // 添加到历史记录
                addToHistory("创建项目", fileName);

                // 重新加载项目列表
                loadProjectList();

                projectCreated(fileName);
                return true;
            } else {
                projectError("保存项目文件失败");
                return false;
            }
        } catch (error) {
            console.error("创建项目失败:", error);
            projectError("创建项目失败: " + error.toString());
            return false;
        }
    }

    // 加载项目
    function loadProject(projectName) {
        if (!projectName || projectName === "") {
            projectError("项目名称为空");
            return false;
        }

        var projectPath = "projects/" + projectName;

        try {
            var content = qmlFileOpt.read(projectPath);
            if (!content || content.trim() === "") {
                projectError("项目文件为空或不存在");
                return false;
            }

            // 解析项目数据
            if (projectName.endsWith(".json")) {
                currentProjectData = JSON.parse(content);
                parseJsonProjectData();
            } else if (projectName.endsWith(".ini")) {
                parseIniProjectData(content);
            } else {
                projectError("不支持的项目文件格式");
                return false;
            }

            // 更新当前项目信息
            currentProjectName = projectName;
            currentProjectPath = projectPath;
            isProjectLoaded = true;
            hasUnsavedChanges = false;

            // 添加到历史记录
            addToHistory("打开项目", projectName);

            console.log("项目加载成功:", projectName);
            projectLoaded(projectName);
            return true;
        } catch (error) {
            console.error("加载项目失败:", error);
            projectError("加载项目失败: " + error.toString());
            return false;
        }
    }

    // 保存项目
    function saveProject() {
        if (!isProjectLoaded || !currentProjectName) {
            projectError("没有打开的项目");
            return false;
        }

        try {
            // 构建保存数据
            var saveData = buildSaveData();

            // 保存到文件
            var jsonContent = JSON.stringify(saveData, null, 2);
            if (qmlFileOpt.write(currentProjectPath, jsonContent)) {
                hasUnsavedChanges = false;
                lastSaveTime = qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss");

                // 添加到历史记录
                addToHistory("保存项目", currentProjectName);

                console.log("项目保存成功:", currentProjectName);
                projectSaved(currentProjectName);
                return true;
            } else {
                projectError("保存项目文件失败");
                return false;
            }
        } catch (error) {
            console.error("保存项目失败:", error);
            projectError("保存项目失败: " + error.toString());
            return false;
        }
    }

    // 另存为项目
    function saveProjectAs(newProjectName) {
        if (!isProjectLoaded) {
            projectError("没有打开的项目");
            return false;
        }

        var oldName = currentProjectName;
        var oldPath = currentProjectPath;

        // 更新项目信息
        currentProjectName = newProjectName.endsWith(".json") ? newProjectName : newProjectName + ".json";
        currentProjectPath = "projects/" + currentProjectName;

        // 保存项目
        if (saveProject()) {
            // 重新加载项目列表
            loadProjectList();

            console.log("项目另存为成功:", currentProjectName);
            return true;
        } else {
            // 恢复原始信息
            currentProjectName = oldName;
            currentProjectPath = oldPath;
            return false;
        }
    }

    // 删除项目
    function deleteProject(projectName) {
        if (!projectName) {
            projectError("项目名称为空");
            return false;
        }

        var projectPath = "projects/" + projectName;

        try {
            if (qmlFileOpt.remove(projectPath)) {
                // 如果删除的是当前项目，清空当前项目信息
                if (projectName === currentProjectName) {
                    closeProject();
                }

                // 重新加载项目列表
                loadProjectList();

                // 添加到历史记录
                addToHistory("删除项目", projectName);

                console.log("项目删除成功:", projectName);
                projectDeleted(projectName);
                return true;
            } else {
                projectError("删除项目文件失败");
                return false;
            }
        } catch (error) {
            console.error("删除项目失败:", error);
            projectError("删除项目失败: " + error.toString());
            return false;
        }
    }

    // 关闭项目
    function closeProject() {
        if (hasUnsavedChanges) {
            // 这里可以触发保存确认对话框
            console.log("项目有未保存的更改");
        }

        // 清空所有数据
        clearAllModels();

        currentProjectName = "";
        currentProjectPath = "";
        currentProjectData = {};
        isProjectLoaded = false;
        hasUnsavedChanges = false;

        console.log("项目已关闭");
    }

    // ==================== 数据操作功能 ====================

    // 添加模块
    function addModule(moduleData) {
        if (!isProjectLoaded) {
            projectError("没有打开的项目");
            return false;
        }

        try {
            var newModule = {
                "id": moduleData.id || generateId("module"),
                "name": moduleData.name || "新模块",
                "type": moduleData.type || "unknown",
                "code": moduleData.code || "",
                "description": moduleData.description || "",
                "config": moduleData.config || {},
                "createTime": qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss"),
                "updateTime": qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss")
            };

            moduleModel.append(newModule);
            hasUnsavedChanges = true;

            console.log("模块添加成功:", newModule.name);
            modelUpdated("module");
            dataChanged();
            return true;
        } catch (error) {
            console.error("添加模块失败:", error);
            projectError("添加模块失败: " + error.toString());
            return false;
        }
    }

    // 更新模块
    function updateModule(index, moduleData) {
        if (!isProjectLoaded || index < 0 || index >= moduleModel.count) {
            projectError("无效的模块索引");
            return false;
        }

        try {
            var module = moduleModel.get(index);

            // 更新字段
            for (var key in moduleData) {
                if (moduleData.hasOwnProperty(key) && key !== "id") {
                    module[key] = moduleData[key];
                }
            }

            module.updateTime = qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss");
            hasUnsavedChanges = true;

            console.log("模块更新成功:", module.name);
            modelUpdated("module");
            dataChanged();
            return true;
        } catch (error) {
            console.error("更新模块失败:", error);
            projectError("更新模块失败: " + error.toString());
            return false;
        }
    }

    // 删除模块
    function removeModule(index) {
        if (!isProjectLoaded || index < 0 || index >= moduleModel.count) {
            projectError("无效的模块索引");
            return false;
        }

        try {
            var module = moduleModel.get(index);
            var moduleName = module.name;

            moduleModel.remove(index);
            hasUnsavedChanges = true;

            console.log("模块删除成功:", moduleName);
            modelUpdated("module");
            dataChanged();
            return true;
        } catch (error) {
            console.error("删除模块失败:", error);
            projectError("删除模块失败: " + error.toString());
            return false;
        }
    }

    // 添加点位
    function addPoint(pointData) {
        if (!isProjectLoaded) {
            projectError("没有打开的项目");
            return false;
        }

        try {
            var newPoint = {
                "id": pointData.id || generateId("point"),
                "name": pointData.name || "新点位",
                "address": pointData.address || "",
                "type": pointData.type || "unknown",
                "moduleId": pointData.moduleId || "",
                "config": pointData.config || {},
                "createTime": qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss"),
                "updateTime": qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss")
            };

            pointsModel.append(newPoint);
            hasUnsavedChanges = true;

            console.log("点位添加成功:", newPoint.name);
            modelUpdated("points");
            dataChanged();
            return true;
        } catch (error) {
            console.error("添加点位失败:", error);
            projectError("添加点位失败: " + error.toString());
            return false;
        }
    }

    // 添加回路
    function addLoop(loopData) {
        if (!isProjectLoaded) {
            projectError("没有打开的项目");
            return false;
        }

        try {
            var newLoop = {
                "id": loopData.id || generateId("loop"),
                "name": loopData.name || "新回路",
                "description": loopData.description || "",
                "points": loopData.points || [],
                "config": loopData.config || {},
                "createTime": qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss"),
                "updateTime": qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss")
            };

            loopsModel.append(newLoop);
            hasUnsavedChanges = true;

            console.log("回路添加成功:", newLoop.name);
            modelUpdated("loops");
            dataChanged();
            return true;
        } catch (error) {
            console.error("添加回路失败:", error);
            projectError("添加回路失败: " + error.toString());
            return false;
        }
    }

    // ==================== 辅助功能 ====================

    // 检查是否为有效的项目文件
    function isValidProjectFile(fileName) {
        if (!fileName || fileName === "." || fileName === ".." || fileName.startsWith(".")) {
            return false;
        }

        return fileName.endsWith(".json") || fileName.endsWith(".ini") || fileName.endsWith(".txt");
    }

    // 获取项目文件信息
    function getProjectFileInfo(fileName) {
        var projectPath = "projects/" + fileName;
        var info = {
            "name": fileName,
            "displayName": fileName.replace(/\.(json|ini|txt)$/, ""),
            "path": projectPath,
            "type": fileName.split('.').pop(),
            "size": 0,
            "createTime": "",
            "updateTime": ""
        };

        // 尝试读取项目基本信息
        try {
            var content = qmlFileOpt.read(projectPath);
            if (content && fileName.endsWith(".json")) {
                var data = JSON.parse(content);
                info.displayName = data.projectName || info.displayName;
                info.description = data.description || "";
                info.version = data.version || "1.0.0";
                info.createTime = data.createTime || "";
            }
        } catch (error) {
            console.warn("读取项目信息失败:", fileName, error);
        }

        return info;
    }

    // 创建项目模板
    function createProjectTemplate(projectName, description, templateType) {
        var baseTemplate = {
            "projectName": projectName,
            "description": description || "",
            "version": "1.0.0",
            "createTime": qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss"),
            "updateTime": qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss"),
            "modules": [],
            "points": [],
            "loops": [],
            "config": {
                "autoSave": true,
                "backupEnabled": true,
                "maxHistory": 50
            }
        };

        // 根据模板类型添加默认数据
        switch (templateType) {
        case "sensor":
            baseTemplate.modules.push({
                "id": "sensor_001",
                "name": "传感器模块",
                "type": "sensor",
                "code": "SENSOR_001",
                "description": "默认传感器模块"
            });
            break;
        case "controller":
            baseTemplate.modules.push({
                "id": "ctrl_001",
                "name": "控制器模块",
                "type": "controller",
                "code": "CTRL_001",
                "description": "默认控制器模块"
            });
            break;
        case "mixed":
            baseTemplate.modules.push({
                "id": "sensor_001",
                "name": "传感器模块",
                "type": "sensor",
                "code": "SENSOR_001"
            }, {
                "id": "ctrl_001",
                "name": "控制器模块",
                "type": "controller",
                "code": "CTRL_001"
            });
            break;
        }

        return baseTemplate;
    }

    // 解析JSON项目数据
    function parseJsonProjectData() {
        clearAllModels();

        // 解析模块数据
        if (currentProjectData.modules && Array.isArray(currentProjectData.modules)) {
            for (var i = 0; i < currentProjectData.modules.length; i++) {
                moduleModel.append(currentProjectData.modules[i]);
            }
        }

        // 解析点位数据
        if (currentProjectData.points && Array.isArray(currentProjectData.points)) {
            for (var j = 0; j < currentProjectData.points.length; j++) {
                pointsModel.append(currentProjectData.points[j]);
            }
        }

        // 解析回路数据
        if (currentProjectData.loops && Array.isArray(currentProjectData.loops)) {
            for (var k = 0; k < currentProjectData.loops.length; k++) {
                loopsModel.append(currentProjectData.loops[k]);
            }
        }

        // 解析配置数据
        if (currentProjectData.config) {
            configModel.clear();
            for (var key in currentProjectData.config) {
                configModel.append({
                    "key": key,
                    "value": currentProjectData.config[key]
                });
            }
        }

        console.log("项目数据解析完成 - 模块:", moduleModel.count, "点位:", pointsModel.count, "回路:", loopsModel.count);
    }

    // 解析INI项目数据
    function parseIniProjectData(content) {
        clearAllModels();

        var lines = content.split('\n');
        var currentSection = "";
        var projectInfo = {};

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();

            if (line === "" || line.startsWith(";") || line.startsWith("#")) {
                continue;
            }

            if (line.startsWith("[") && line.endsWith("]")) {
                currentSection = line.substring(1, line.length - 1);
                continue;
            }

            var equalIndex = line.indexOf("=");
            if (equalIndex > 0) {
                var key = line.substring(0, equalIndex).trim();
                var value = line.substring(equalIndex + 1).trim();

                if (currentSection === "Project") {
                    projectInfo[key] = value;
                } else if (currentSection === "Modules") {
                    if (key.startsWith("module")) {
                        moduleModel.append({
                            "id": key,
                            "name": value,
                            "type": "unknown",
                            "code": key.toUpperCase()
                        });
                    }
                }
            }
        }

        // 更新项目数据
        currentProjectData = {
            "projectName": projectInfo.name || currentProjectName,
            "description": projectInfo.description || "",
            "version": projectInfo.version || "1.0.0",
            "createTime": projectInfo.createTime || ""
        };
    }

    // 构建保存数据
    function buildSaveData() {
        var saveData = {
            "projectName": currentProjectData.projectName || currentProjectName,
            "description": currentProjectData.description || "",
            "version": currentProjectData.version || "1.0.0",
            "createTime": currentProjectData.createTime || qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss"),
            "updateTime": qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss"),
            "modules": [],
            "points": [],
            "loops": [],
            "config": {}
        };

        // 收集模块数据
        for (var i = 0; i < moduleModel.count; i++) {
            saveData.modules.push(moduleModel.get(i));
        }

        // 收集点位数据
        for (var j = 0; j < pointsModel.count; j++) {
            saveData.points.push(pointsModel.get(j));
        }

        // 收集回路数据
        for (var k = 0; k < loopsModel.count; k++) {
            saveData.loops.push(loopsModel.get(k));
        }

        // 收集配置数据
        for (var l = 0; l < configModel.count; l++) {
            var configItem = configModel.get(l);
            saveData.config[configItem.key] = configItem.value;
        }

        return saveData;
    }

    // 清空所有模型
    function clearAllModels() {
        moduleModel.clear();
        pointsModel.clear();
        loopsModel.clear();
        configModel.clear();
    }

    // 生成唯一ID
    function generateId(prefix) {
        var timestamp = Date.now();
        var random = Math.floor(Math.random() * 1000);
        return prefix + "_" + timestamp + "_" + random;
    }

    // 添加到历史记录
    function addToHistory(action, target) {
        var historyItem = {
            "action": action,
            "target": target,
            "timestamp": qmlFileOpt.currentDataTime("yyyy-MM-dd hh:mm:ss"),
            "user": "system"
        };

        historyModel.insert(0, historyItem);

        // 限制历史记录数量
        var maxHistory = 50;
        while (historyModel.count > maxHistory) {
            historyModel.remove(historyModel.count - 1);
        }
    }

    // 获取项目统计信息
    function getProjectStats() {
        if (!isProjectLoaded) {
            return {};
        }

        return {
            "projectName": currentProjectName,
            "displayName": currentProjectData.projectName || currentProjectName,
            "moduleCount": moduleModel.count,
            "pointCount": pointsModel.count,
            "loopCount": loopsModel.count,
            "hasUnsavedChanges": hasUnsavedChanges,
            "lastSaveTime": lastSaveTime,
            "createTime": currentProjectData.createTime || "",
            "version": currentProjectData.version || "1.0.0"
        };
    }

    // 导出项目数据
    function exportProject(format) {
        if (!isProjectLoaded) {
            projectError("没有打开的项目");
            return "";
        }

        var exportData = buildSaveData();

        switch (format) {
        case "json":
            return JSON.stringify(exportData, null, 2);
        case "csv":
            return exportToCsv(exportData);
        default:
            return JSON.stringify(exportData, null, 2);
        }
    }

    // 导出为CSV格式
    function exportToCsv(data) {
        var csv = "";

        // 导出模块数据
        csv += "模块数据\n";
        csv += "ID,名称,类型,代码,描述\n";
        for (var i = 0; i < data.modules.length; i++) {
            var module = data.modules[i];
            csv += module.id + "," + module.name + "," + module.type + "," + (module.code || "") + "," + (module.description || "") + "\n";
        }

        csv += "\n点位数据\n";
        csv += "ID,名称,地址,类型,模块ID\n";
        for (var j = 0; j < data.points.length; j++) {
            var point = data.points[j];
            csv += point.id + "," + point.name + "," + (point.address || "") + "," + point.type + "," + (point.moduleId || "") + "\n";
        }

        return csv;
    }

    // ==================== 初始化 ====================

    Component.onCompleted: {
        console.log("ProgramModel 初始化完成");
        loadProjectList();
    }
}
