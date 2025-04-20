import Qt.labs.settings 1.0
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Rectangle {
    // 使用XMLHttpRequest清空数据

    id: librariesRoot

    property alias moduleModel: moduleModel
    property var moduleUuids: []

    function clear() {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');
        const dateString = `${year}${month}${day}${hours}${minutes}${seconds}`;
        moduleListSettings.fileName = `./backup/moduleListBak_${dateString}.ini`;
        moduleListSettings.sync();
        console.log("已备份数据");
        moduleListSettings.fileName = "./moduleList.ini";
        moduleUuids.forEach(function (uuid) {
            moduleListSettings.setValue(uuid, "");
        });
        moduleListSettings.uuidList = "";
        moduleUuids = [];
        moduleModel.clear();
        console.log("clear", moduleModel.count);
    }

    function rebuild() {
    }

    function loadModuleSettings() {
        // 从Settings加载模块UUID列表
        var savedUuids = moduleListSettings.uuidList.split(',').filter(function (item) {
            return item.trim() !== "";
        });
        // 加载每个模块的设置
        const uuidList = [];
        for (var i = 0; i < savedUuids.length; i++) {
            const module = moduleListSettings.value(savedUuids[i]);
            if (module) {
                moduleModel.append(JSON.parse(module));
                uuidList.push(savedUuids[i]);
            }
        }
        moduleUuids = uuidList;
    }

    function addModule() {
        const uuid = generateUUID();
        moduleUuids.push(uuid);
        const newModule = {
            "uuid": uuid,
            "rx": 0,
            "ry": 0,
            "rwidth": 0,
            "rheight": 0,
            "ioNum": 0,
            "lockNum": 0,
            "airNum": 0,
            "scale": 0,
            "name": "",
            "code": "",
            "site": "",
            "meta": "",
            "strLight": "",
            "strValue": "",
            "points": [],
            "checks": [],
            "airChecks": [],
            "tags": [],
            "base64": ""
        };
        moduleListSettings.setValue(uuid, JSON.stringify(newModule));
        moduleListSettings.uuidList = moduleUuids.join(',');
        moduleModel.append(newModule);
    }

    function fixModule(index, code, name, meta, ioNum, lockNum, airNum) {
        const moduleRef = moduleModel.get(index);
        if (index !== -1) {
            moduleModel.setProperty(index, "code", code);
            moduleModel.setProperty(index, "name", name);
            moduleModel.setProperty(index, "meta", meta);
            moduleModel.setProperty(index, "ioNum", ioNum);
            moduleModel.setProperty(index, "lockNum", lockNum);
            moduleModel.setProperty(index, "airNum", airNum);
            // 自动创建点位
            const pointsArray = [];
            for (let i = 0; i < ioNum; i++) {
                pointsArray.push({
                    "name": "IO点位" + (i + 1),
                    "rx": 0,
                    "ry": 0
                });
            }
            const checksArray = [];
            for (let i = 0; i < lockNum; i++) {
                checksArray.push({
                    "name": "锁点位" + (i + 1),
                    "rx": 0,
                    "ry": 0
                });
                checksArray.push({
                    "name": "锁点位" + (i + 1),
                    "rx": 0,
                    "ry": 0
                });
            }
            const airChecksArray = [];
            for (let i = 0; i < airNum; i++) {
                airChecksArray.push({
                    "name": "气点位" + (i + 1),
                    "rx": 0,
                    "ry": 0
                });
                airChecksArray.push({
                    "name": "气点位" + (i + 1),
                    "rx": 0,
                    "ry": 0
                });
            }
            moduleRef.points.append(pointsArray);
            moduleRef.checks.append(checksArray);
            moduleRef.airChecks.append(airChecksArray);
            const newModule = {
                "uuid": moduleRef.uuid,
                "rx": 0,
                "ry": 0,
                "rwidth": 0,
                "rheight": 0,
                "ioNum": moduleRef.ioNum,
                "lockNum": moduleRef.lockNum,
                "airNum": moduleRef.airNum,
                "scale": moduleRef.scale,
                "name": moduleRef.name,
                "code": moduleRef.code,
                "site": moduleRef.site,
                "meta": moduleRef.meta,
                "strLight": moduleRef.strLight,
                "strValue": moduleRef.strValue,
                "points": pointsArray,
                "checks": checksArray,
                "airChecks": airChecksArray,
                "tags": [],
                "base64": moduleRef.base64
            };
            moduleListSettings.setValue(moduleRef.uuid, JSON.stringify(newModule));
        }
    }

    function updateModule(index, module) {
        const tags = [];
        const points = [];
        const checks = [];
        const airChecks = [];
        for (let i = 0; i < module.tags.count; i++) {
            tags.push({
                "tag": module.tags.get(i).tag
            });
        }
        for (let i = 0; i < module.points.count; i++) {
            const point = module.points.get(i);
            points.push({
                "name": point.name,
                "rx": point.rx,
                "ry": point.ry
            });
        }
        for (let i = 0; i < module.checks.count; i++) {
            const check = module.checks.get(i);
            checks.push({
                "name": check.name,
                "rx": check.rx,
                "ry": check.ry
            });
        }
        for (let i = 0; i < module.airChecks.count; i++) {
            const airCheck = module.airChecks.get(i);
            airChecks.push({
                "name": airCheck.name,
                "rx": airCheck.rx,
                "ry": airCheck.ry
            });
        }
        const result = {
            "uuid": module.uuid,
            "rx": module.rx,
            "ry": module.ry,
            "rwidth": module.rwidth,
            "rheight": module.rheight,
            "ioNum": module.ioNum,
            "lockNum": module.lockNum,
            "airNum": module.airNum,
            "scale": module.scale,
            "name": module.name,
            "code": module.code,
            "site": module.site,
            "meta": module.meta,
            "strLight": module.strLight,
            "strValue": module.strValue,
            "points": points,
            "tags": tags,
            "base64": module.base64,
            "checks": checks,
            "airChecks": airChecks
        };
        moduleListSettings.setValue(module.uuid, JSON.stringify(result));
        moduleModel.setProperty(index, "uuid", module.uuid);
        moduleModel.setProperty(index, "rx", module.rx);
        moduleModel.setProperty(index, "ry", module.ry);
        moduleModel.setProperty(index, "rwidth", module.rwidth);
        moduleModel.setProperty(index, "rheight", module.rheight);
        moduleModel.setProperty(index, "ioNum", module.ioNum);
        moduleModel.setProperty(index, "lockNum", module.lockNum);
        moduleModel.setProperty(index, "airNum", module.airNum);
        moduleModel.setProperty(index, "scale", module.scale);
        moduleModel.setProperty(index, "name", module.name);
        moduleModel.setProperty(index, "code", module.code);
        moduleModel.setProperty(index, "site", module.site);
        moduleModel.setProperty(index, "meta", module.meta);
        moduleModel.setProperty(index, "strLight", module.strLight);
        moduleModel.setProperty(index, "strValue", module.strValue);
        moduleModel.setProperty(index, "base64", module.base64);
    }

    function moveModule(fromIndex, toIndex) {
        if (fromIndex === toIndex || fromIndex < 0 || toIndex < 0 || fromIndex >= moduleModel.count || toIndex >= moduleModel.count)
            return false;

        // 保存源和目标模块
        var sourceModule = moduleModel.get(fromIndex);
        var targetModule = moduleModel.get(toIndex);
        if (sourceModule && targetModule) {
            // 交换模块位置
            var tempX = targetModule.rx;
            var tempY = targetModule.ry;
            // 更新位置
            moduleModel.setProperty(toIndex, "rx", sourceModule.rx);
            moduleModel.setProperty(toIndex, "ry", sourceModule.ry);
            moduleModel.setProperty(fromIndex, "rx", tempX);
            moduleModel.setProperty(fromIndex, "ry", tempY);
            // 保存到设置
            updateModule(fromIndex, moduleModel.get(fromIndex));
            updateModule(toIndex, moduleModel.get(toIndex));
            return true;
        }
        return false;
    }

    function generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 3 | 8);
            return v.toString(16);
        });
    }

    Component.onCompleted: {
        loadModuleSettings();
        console.log("librariesModel onCompleted", moduleModel.count);
    }
    color: "#ffffff"
    border.color: "#cccccc"
    border.width: 1
    radius: 5

    // 添加ListModel用于模块列表
    ListModel {
        id: moduleModel
    }

    // 使用Settings组件而不是LocalStorage
    Settings {
        id: moduleListSettings

        property string uuidList: ""

        fileName: "./moduleList.ini"
    }
}
