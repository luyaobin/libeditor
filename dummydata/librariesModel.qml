import Qt.labs.settings 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: librariesRoot

    property alias moduleModel: moduleModel
    property var moduleUuids: []

    function loadModuleSettings() {
        // 从Settings加载模块UUID列表
        var savedUuids = moduleListSettings.uuidList.split(',').filter(function(item) {
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

    function addModule(module) {
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
            "strValue": "",
            "points": [],
            "tags": [],
            "base64": ""
        };
        moduleListSettings.setValue(uuid, JSON.stringify(newModule));
        moduleListSettings.uuidList = moduleUuids.join(',');
        moduleModel.append(newModule);
    }

    function updateModule(index, module) {
        const tags = [];
        const points = [];
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
            "strValue": module.strValue,
            "points": points,
            "tags": tags,
            "base64": module.base64
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
        moduleModel.setProperty(index, "strValue", module.strValue);
        moduleModel.setProperty(index, "base64", module.base64);
    }

    function generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
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
