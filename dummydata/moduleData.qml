import QtQuick 2.15

QtObject {
    // 发出信号通知数据已更新
    // points = module.points;
    // tags = module.tags;
    // 检查points是否为数组
    // 检查points是否为数组且索引有效

    property string uuid: ""
    property int index: 0
    property real rx: 0
    property real ry: 0
    property real rwidth: 0
    property real rheight: 0
    property real ioNum: 0
    property real lockNum: 0
    property real airNum: 0
    property real scale: 0
    property string name: ""
    property string code: ""
    property string strValue: ""
    property var points: null
    property var tags: null
    property string base64: ""

    signal dataChanged()
    signal selectFinishedChanged(var module)

    function selectModule(module, zIndex = -1) {
        uuid = module.uuid;
        if (zIndex !== -1)
            index = zIndex;

        rx = module.rx;
        ry = module.ry;
        rwidth = module.rwidth;
        rheight = module.rheight;
        ioNum = module.ioNum;
        lockNum = module.lockNum;
        airNum = module.airNum;
        scale = module.scale;
        name = module.name;
        code = module.code;
        strValue = module.strValue;
        points = module.points;
        tags = module.tags;
        base64 = module.base64 || "";
        // console.log(module);
        selectFinishedChanged(module);
    }

    function addPoint(x, y, name) {
        // 添加新点位
        var newPoint = {
            "name": name || "点位" + (points.length + 1),
            "rx": x,
            "ry": y
        };
        points.append(newPoint);
        console.log("添加点位:", newPoint);
        // 同步到设置
        saveToSettings();
    }

    function updatePoint(index, property, value) {
        // 检查points是否为数组且索引有效
        if (!Array.isArray(points) || index < 0 || index >= points.length) {
            console.log("更新点位失败：无效的点位索引", index);
            return false;
        }
        // 更新点位属性
        if (points[index]) {
            points[index][property] = value;
            console.log("更新点位:", index, property, value);
            // 同步到设置
            saveToSettings();
            return true;
        }
        return false;
    }

    function deletePoint() {
        // 删除点位
        console.log("删除点位:", index, points.count);
        if (points.count > 0) {
            points.remove(points.count - 1);
            console.log("删除点位:", index);
            // 同步到设置
            saveToSettings();
        }
    }

    function saveToSettings() {
        // 这里实现保存到设置的逻辑
        // 例如使用 Qt.labs.settings 或其他方法
        console.log("同步点位数据到设置");
        const moduleRef = {
            "uuid": uuid,
            "rx": rx,
            "ry": ry,
            "rwidth": rwidth,
            "rheight": rheight,
            "ioNum": ioNum,
            "lockNum": lockNum,
            "airNum": airNum,
            "scale": scale,
            "name": name,
            "code": code,
            "strValue": strValue,
            "points": points,
            "tags": tags,
            "base64": base64
        };
        console.log("moduleRef", tags, points);
        librariesModel.updateModule(index, moduleRef);
    }

    onDataChanged: {
        console.log("数据已更新");
        saveToSettings();
    }
}
