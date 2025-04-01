import Qt.labs.settings 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: librariesRoot

    property alias moduleModel: moduleModel
    property var moduleSettings: ({
    })
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
        console.log(moduleListSettings.uuidList, uuidList);
        moduleListSettings.uuidList = uuidList.join(',');
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
        console.log(moduleListSettings.uuidList);
        moduleModel.append(newModule);
    }

    function updateModule(uuid, module) {
        moduleModel.set(moduleModel.indexOf(module), module);
        moduleListSettings.setValue(uuid, JSON.stringify(module));
    }

    function generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 3 | 8);
            return v.toString(16);
        });
    }

    Component.onCompleted: {
        loadModuleSettings();
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
