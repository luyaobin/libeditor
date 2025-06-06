import QtQuick 2.14
import QtQml.Models 2.14

QtObject {
    id: programModel

    // 当前选中的项目名称
    property string currentProject: ""

    // 项目数据
    property var projectData: ({})

    // 模块列表模型
    property ListModel moduleListModel: ListModel {}

    // 点位数据模型
    property ListModel pointsModel: ListModel {}

    // 回路数据模型
    property ListModel loopsModel: ListModel {}

    // 信号
    signal projectChanged(string projectName)
    signal dataLoaded
    signal dataError(string message)

    // 加载项目数据
    function loadProject(projectName) {
        if (!projectName || projectName === "") {
            console.log("项目名称为空");
            return false;
        }

        currentProject = projectName;
        console.log("开始加载项目:", projectName);

        // 使用QmlFileOpt读取项目文件
        if (typeof qmlFileOpt !== "undefined") {
            var projectPath = "projects/" + projectName;
            var content = qmlFileOpt.read(projectPath);

            if (content && content.trim() !== "") {
                try {
                    if (projectName.endsWith(".json")) {
                        // JSON格式项目文件
                        projectData = JSON.parse(content);
                        parseJsonProject();
                    } else if (projectName.endsWith(".ini")) {
                        // INI格式项目文件
                        parseIniProject(content);
                    } else {
                        // 其他格式，尝试作为JSON解析
                        projectData = JSON.parse(content);
                        parseJsonProject();
                    }

                    projectChanged(projectName);
                    dataLoaded();
                    return true;
                } catch (error) {
                    console.error("解析项目文件失败:", error);
                    dataError("解析项目文件失败: " + error.toString());
                    return false;
                }
            } else {
                console.error("读取项目文件失败或文件为空");
                dataError("读取项目文件失败或文件为空");
                return false;
            }
        } else {
            console.error("qmlFileOpt未定义");
            dataError("文件操作组件未初始化");
            return false;
        }
    }

    // 解析JSON格式的项目数据
    function parseJsonProject() {
        // 清空现有数据
        moduleListModel.clear();
        pointsModel.clear();
        loopsModel.clear();

        // 解析模块数据
        if (projectData.modules && Array.isArray(projectData.modules)) {
            for (var i = 0; i < projectData.modules.length; i++) {
                var module = projectData.modules[i];
                moduleListModel.append({
                    "id": module.id || "",
                    "name": module.name || "",
                    "type": module.type || "",
                    "config": module.config || {}
                });
            }
        }

        // 解析点位数据（如果存在）
        if (projectData.points && Array.isArray(projectData.points)) {
            for (var j = 0; j < projectData.points.length; j++) {
                var point = projectData.points[j];
                pointsModel.append({
                    "id": point.id || "",
                    "name": point.name || "",
                    "address": point.address || "",
                    "type": point.type || ""
                });
            }
        }

        // 解析回路数据（如果存在）
        if (projectData.loops && Array.isArray(projectData.loops)) {
            for (var k = 0; k < projectData.loops.length; k++) {
                var loop = projectData.loops[k];
                loopsModel.append({
                    "id": loop.id || "",
                    "name": loop.name || "",
                    "points": loop.points || []
                });
            }
        }

        console.log("JSON项目数据解析完成 - 模块:", moduleListModel.count, "点位:", pointsModel.count, "回路:", loopsModel.count);
    }

    // 解析INI格式的项目数据
    function parseIniProject(content) {
        // 清空现有数据
        moduleListModel.clear();
        pointsModel.clear();
        loopsModel.clear();

        var lines = content.split('\n');
        var currentSection = "";
        var projectInfo = {};

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();

            if (line === "" || line.startsWith(";") || line.startsWith("#")) {
                continue; // 跳过空行和注释
            }

            if (line.startsWith("[") && line.endsWith("]")) {
                // 节标题
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
                        moduleListModel.append({
                            "id": key,
                            "name": value,
                            "type": "unknown",
                            "config": {}
                        });
                    }
                }
            }
        }

        // 保存项目信息
        projectData = {
            "projectName": projectInfo.name || currentProject,
            "description": projectInfo.description || "",
            "version": projectInfo.version || "1.0.0",
            "createTime": projectInfo.createTime || ""
        };

        console.log("INI项目数据解析完成 - 模块:", moduleListModel.count);
    }

    // 保存项目数据
    function saveProject() {
        if (!currentProject || currentProject === "") {
            console.error("没有当前项目");
            return false;
        }

        try {
            // 构建保存数据
            var saveData = {
                "projectName": projectData.projectName || currentProject,
                "description": projectData.description || "",
                "version": projectData.version || "1.0.0",
                "createTime": projectData.createTime || qmlFileOpt.currentDataTime("yyyy-MM-dd"),
                "modules": [],
                "points": [],
                "loops": []
            };

            // 收集模块数据
            for (var i = 0; i < moduleListModel.count; i++) {
                var module = moduleListModel.get(i);
                saveData.modules.push({
                    "id": module.id,
                    "name": module.name,
                    "type": module.type,
                    "config": module.config
                });
            }

            // 收集点位数据
            for (var j = 0; j < pointsModel.count; j++) {
                var point = pointsModel.get(j);
                saveData.points.push({
                    "id": point.id,
                    "name": point.name,
                    "address": point.address,
                    "type": point.type
                });
            }

            // 收集回路数据
            for (var k = 0; k < loopsModel.count; k++) {
                var loop = loopsModel.get(k);
                saveData.loops.push({
                    "id": loop.id,
                    "name": loop.name,
                    "points": loop.points
                });
            }

            // 保存到文件
            var projectPath = "projects/" + currentProject;
            var jsonContent = JSON.stringify(saveData, null, 2);

            if (qmlFileOpt.write(projectPath, jsonContent)) {
                console.log("项目保存成功:", currentProject);
                return true;
            } else {
                console.error("项目保存失败");
                dataError("项目保存失败");
                return false;
            }
        } catch (error) {
            console.error("保存项目时出错:", error);
            dataError("保存项目时出错: " + error.toString());
            return false;
        }
    }

    // 创建新项目
    function createProject(projectName, description) {
        if (!projectName || projectName.trim() === "") {
            dataError("项目名称不能为空");
            return false;
        }

        // 确保文件扩展名
        if (!projectName.endsWith(".json")) {
            projectName += ".json";
        }

        currentProject = projectName;

        // 初始化项目数据
        projectData = {
            "projectName": projectName.replace(".json", ""),
            "description": description || "",
            "version": "1.0.0",
            "createTime": qmlFileOpt.currentDataTime("yyyy-MM-dd")
        };

        // 清空模型
        moduleListModel.clear();
        pointsModel.clear();
        loopsModel.clear();

        // 保存新项目
        if (saveProject()) {
            projectChanged(projectName);
            dataLoaded();
            return true;
        }

        return false;
    }

    // 获取项目信息
    function getProjectInfo() {
        return {
            "name": currentProject,
            "displayName": projectData.projectName || currentProject,
            "description": projectData.description || "",
            "version": projectData.version || "1.0.0",
            "createTime": projectData.createTime || "",
            "moduleCount": moduleListModel.count,
            "pointCount": pointsModel.count,
            "loopCount": loopsModel.count
        };
    }
}
