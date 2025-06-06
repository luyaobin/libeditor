import Qt.labs.settings 1.0
import QtQuick 2.14
import QtQuick.Controls 2.14

Rectangle {
    id: projectsRoot

    property alias projectModel: projectModel
    property var projectUuids: []
    property string currentProjectId: ""

    // 生成UUID函数
    function generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0;
            var v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    // 清空所有项目数据
    function clear() {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');
        const dateString = `${year}${month}${day}${hours}${minutes}${seconds}`;

        // 备份当前数据
        projectSettings.fileName = `./backup/projectsBak_${dateString}.ini`;
        projectSettings.sync();
        console.log("已备份项目数据");

        // 清空数据
        projectSettings.fileName = "./projects.ini";
        projectUuids.forEach(function (uuid) {
            projectSettings.setValue(uuid, "");
        });
        projectSettings.uuidList = "";
        projectUuids = [];
        projectModel.clear();
        currentProjectId = "";
        console.log("清空项目数据完成，项目数量:", projectModel.count);
    }

    function rebuild() {
    // 重建功能预留
    }

    // 从设置文件加载项目数据
    function loadProjectSettings() {
        // 从Settings加载项目UUID列表
        var savedUuids = projectSettings.uuidList.split(',').filter(function (item) {
            return item.trim() !== "";
        });

        // 加载每个项目的设置
        const uuidList = [];
        for (var i = 0; i < savedUuids.length; i++) {
            const project = projectSettings.value(savedUuids[i]);
            if (project) {
                projectModel.append(JSON.parse(project));
                uuidList.push(savedUuids[i]);
            }
        }
        projectUuids = uuidList;

        // 设置当前项目
        if (projectUuids.length > 0 && !currentProjectId) {
            currentProjectId = projectUuids[0];
        }

        console.log("加载项目数据完成，项目数量:", projectModel.count);
    }

    // 添加新项目
    function addProject(projectName, description) {
        const uuid = generateUUID();
        projectUuids.push(uuid);

        const newProject = {
            "uuid": uuid,
            "name": projectName || "新项目",
            "description": description || "",
            "createTime": new Date().toISOString(),
            "updateTime": new Date().toISOString(),
            "modules": [],
            "layoutConfig": {
                "width": 1200,
                "height": 600,
                "scale": 1.0,
                "offsetX": 0,
                "offsetY": 0
            },
            "settings": {
                "gridSize": 20,
                "snapToGrid": true,
                "showGrid": true
            }
        };

        projectSettings.setValue(uuid, JSON.stringify(newProject));
        projectSettings.uuidList = projectUuids.join(',');
        projectModel.append(newProject);

        // 设置为当前项目
        currentProjectId = uuid;

        console.log("添加项目成功:", projectName);
        return uuid;
    }

    // 删除项目
    function deleteProject(index) {
        if (index >= 0 && index < projectModel.count) {
            const project = projectModel.get(index);
            const uuid = project.uuid;

            // 从设置中删除
            projectSettings.setValue(uuid, "");

            // 从UUID列表中移除
            const uuidIndex = projectUuids.indexOf(uuid);
            if (uuidIndex > -1) {
                projectUuids.splice(uuidIndex, 1);
            }

            // 更新设置
            projectSettings.uuidList = projectUuids.join(',');

            // 从模型中移除
            projectModel.remove(index);

            // 如果删除的是当前项目，切换到第一个项目
            if (currentProjectId === uuid) {
                currentProjectId = projectUuids.length > 0 ? projectUuids[0] : "";
            }

            console.log("删除项目成功:", project.name);
        }
    }

    // 更新项目信息
    function updateProject(index, projectData) {
        if (index >= 0 && index < projectModel.count) {
            const project = projectModel.get(index);
            const uuid = project.uuid;

            // 更新时间戳
            projectData.updateTime = new Date().toISOString();
            projectData.uuid = uuid;

            // 构建完整的项目数据
            const result = {
                "uuid": uuid,
                "name": projectData.name,
                "description": projectData.description,
                "createTime": project.createTime,
                "updateTime": projectData.updateTime,
                "modules": projectData.modules || [],
                "layoutConfig": projectData.layoutConfig || {
                    "width": 1200,
                    "height": 600,
                    "scale": 1.0,
                    "offsetX": 0,
                    "offsetY": 0
                },
                "settings": projectData.settings || {
                    "gridSize": 20,
                    "snapToGrid": true,
                    "showGrid": true
                }
            };

            // 保存到设置
            projectSettings.setValue(uuid, JSON.stringify(result));

            // 更新模型
            projectModel.setProperty(index, "uuid", result.uuid);
            projectModel.setProperty(index, "name", result.name);
            projectModel.setProperty(index, "description", result.description);
            projectModel.setProperty(index, "createTime", result.createTime);
            projectModel.setProperty(index, "updateTime", result.updateTime);
            projectModel.setProperty(index, "modules", result.modules);
            projectModel.setProperty(index, "layoutConfig", result.layoutConfig);
            projectModel.setProperty(index, "settings", result.settings);

            console.log("更新项目成功:", result.name);
        }
    }

    // 获取当前项目
    function getCurrentProject() {
        for (let i = 0; i < projectModel.count; i++) {
            const project = projectModel.get(i);
            if (project.uuid === currentProjectId) {
                return project;
            }
        }
        return null;
    }

    // 设置当前项目
    function setCurrentProject(uuid) {
        currentProjectId = uuid;
        console.log("切换到项目:", uuid);
    }

    // 复制项目
    function duplicateProject(index) {
        if (index >= 0 && index < projectModel.count) {
            const originalProject = projectModel.get(index);
            const newUuid = generateUUID();

            const duplicatedProject = {
                "uuid": newUuid,
                "name": originalProject.name + " - 副本",
                "description": originalProject.description,
                "createTime": new Date().toISOString(),
                "updateTime": new Date().toISOString(),
                "modules": JSON.parse(JSON.stringify(originalProject.modules)),
                "layoutConfig": JSON.parse(JSON.stringify(originalProject.layoutConfig)),
                "settings": JSON.parse(JSON.stringify(originalProject.settings))
            };

            projectUuids.push(newUuid);
            projectSettings.setValue(newUuid, JSON.stringify(duplicatedProject));
            projectSettings.uuidList = projectUuids.join(',');
            projectModel.append(duplicatedProject);

            console.log("复制项目成功:", duplicatedProject.name);
            return newUuid;
        }
        return "";
    }

    // 移动项目位置
    function moveProject(fromIndex, toIndex) {
        if (fromIndex === toIndex || fromIndex < 0 || toIndex < 0 || fromIndex >= projectModel.count || toIndex >= projectModel.count)
            return false;

        // 保存源和目标项目
        var sourceProject = projectModel.get(fromIndex);
        var targetProject = projectModel.get(toIndex);
        if (sourceProject && targetProject) {
            // 交换UUID在数组中的位置
            var tempUuid = projectUuids[fromIndex];
            projectUuids[fromIndex] = projectUuids[toIndex];
            projectUuids[toIndex] = tempUuid;

            // 更新UUID列表
            projectSettings.uuidList = projectUuids.join(',');

            // 移动模型中的项目
            projectModel.move(fromIndex, toIndex, 1);

            console.log("移动项目成功: 从", fromIndex, "到", toIndex);
            return true;
        }
        return false;
    }

    // 导出项目数据
    function exportProject(index) {
        if (index >= 0 && index < projectModel.count) {
            const project = projectModel.get(index);
            return JSON.stringify(project, null, 2);
        }
        return "";
    }

    // 导入项目数据
    function importProject(jsonData) {
        try {
            const projectData = JSON.parse(jsonData);
            const newUuid = generateUUID();

            projectData.uuid = newUuid;
            projectData.createTime = new Date().toISOString();
            projectData.updateTime = new Date().toISOString();

            projectUuids.push(newUuid);
            projectSettings.setValue(newUuid, JSON.stringify(projectData));
            projectSettings.uuidList = projectUuids.join(',');
            projectModel.append(projectData);

            console.log("导入项目成功:", projectData.name);
            return newUuid;
        } catch (error) {
            console.error("导入项目失败:", error);
            return "";
        }
    }

    // 组件完成时加载数据
    Component.onCompleted: {
        loadProjectSettings();
        console.log("projects onCompleted", projectModel.count);
    }

    color: "#ffffff"
    border.color: "#cccccc"
    border.width: 1
    radius: 5

    // 项目数据模型
    ListModel {
        id: projectModel
    }

    // 项目设置存储
    Settings {
        id: projectSettings
        property string uuidList: ""
        fileName: "./projects.ini"
    }
}
