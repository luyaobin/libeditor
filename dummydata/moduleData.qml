import QtQuick 2.15

QtObject {
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
    property var points: []
    property var tags: []
    property string base64: ""

    function selectModule(module) {
        uuid = module.uuid;
        index = module.index;
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
        base64 = module.base64;
        console.log(module);
    }

    function addPoint(x, y, name) {
        // 检查points是否为数组
        if (!Array.isArray(points))
            points = [];

        // 添加新点位
        var newPoint = {
            "name": name || "点位" + (points.length + 1),
            "rx": x,
            "ry": y
        };
        points.push(newPoint);
        console.log("添加点位:", newPoint);
    }

}
