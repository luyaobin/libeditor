import QtQuick 2.0
import QtQml.Models 2.14
Item {
    id: root
    required property var source
    property var refreshIndexs: function(indexs) {
        for (let i in indexs) {
            root.loadItem(i)
        }
    }
    property var reloadData: function(datas) {
        root.clearItems()
        for (let item of datas) {
            root.loadItem(-1, item)
        }
    }
    property ListModel model: ListModel {
        id: classModel
        dynamicRoles: true
    }
    property
    alias count: classModel.count
    onSourceChanged: {
        let keys = [ "count", "indexOf", "sortInit", "sort",
        "sortInit", "swap", "exist", "touch", "load", "append",
        "clear", "get", "insert", "move", "remove", "set", "setProperty", "sources" ]
        let key = ""
        for (let i = 0; i < keys.length; i++) {
            key = keys[i]
            if (source.hasOwn(key))
            {
                funcs[key] = source[key]
            }
        }
    }

    property var funcs: {
        "_count": function(...ref) {return funcs.count(...ref)},
        "_sort": function(...ref) {
        // a nuo b
        // b nuo c
        // 先大致移动
        // 再移动区间
        let sortData = funcs.sort(source, ...ref)
        function moveItem(moves)
        {
            moves.sort()
            let count = 0
            let lastCount = 0
            let lastSeek = 0
            let last = moves[0] - 1
            moves.forEach(value => {
            if (last + 1 == value)
            {
                count++
            }
            else {
                classModel.move(lastSeek - lastCount, value - count, count)
                lastCount = count
                lastSeek = value
                count++
            }
            last = value
            ;})
            if (lastSeek - lastCount !== classModel.count - count)
                classModel.move(lastSeek - lastCount, classModel.count - count, count)
        }
        for (;;) {
            let moves = sortData.getMove()
            if (moves.length === 0)
                break
            moveItem(moves)
        }
        for (;;) {
            let moves = sortData.makeMove()
            if (moves.length === 0)
                break
            moveItem(moves)
        }
        // update section
        let values = sortData.loadSwap()
        let key = sortData.section

        for (;;) {
            let swapIndex = sortData.makeSwap()
            if (swapIndex === null)
                break
            classModel.move(swapIndex, swapIndex + 1, 1)
        }
        if (values)
        {
            values.forEach((value, index) => classModel.setProperty(index, key, value))
        }
        ;},
        "_exist": function(...ref) {return funcs.indexOf(source, ...ref) !== -1},
        "_indexOf": function(...ref) {return funcs.indexOf(source, ...ref)},
        "_touch": function(...ref) {funcs.touch(source, ...ref)},
        "_load": function(...ref) {classModel.append(funcs.load(source, ...ref))},
        "_append": function(...ref) {classModel.append(funcs.append(source, ...ref))},
        "_clear": function() {classModel.clear(); funcs.clear(source)},
        "_get": function(index) {return funcs.get(source, index) },
        "_insert": function(index, ...ref) {classModel.insert(index, funcs.insert(source, index, ...ref)) },
        "_move": function(from, to, n) {classModel.move(from, to, n); funcs.move(source, from, to, n);},
        "_remove": function(index, count = 1) {classModel.remove(index, count); funcs.remove(source, index, count);},
        "_set": function(index, value) {classModel.set(index, funcs.set(source, index, value));},
        "_setProperty": function(index, key, value, ...ref) {classModel.setProperty(index, key, funcs.setProperty(source, index, key, value, ...ref));},
        "_sources": function(...ref) {return funcs.sources(source, ...ref);},

        "count": () => {return 0},
        "sort": () => {return []},
        "indexOf": () => {return -1}, /* 返回index */
        "touch": () => {/* 创建一个空的对象, 并插入某处 */},
        "load": () => {},
        "append": () => {},
        "clear": () => {},
        "get": () => {},
        "insert": () => {},
        "move": () => {},
        "remove": () => {},
        "set": () => {},
        "setProperty": () => {},
        "sources": () => {},
    }
    property
    var countItem: funcs._count
    property
    var sortItem: funcs._sort
    property
    var indexOfItem: funcs._indexOf
    property
    var containsItem: funcs._exist
    property
    var touchItem: funcs._touch
    property
    var loadItem: funcs._load
    property
    var appendItem: funcs._append
    property
    var clearItems: funcs._clear
    property
    var getItem: funcs._get
    property
    var insertItem: funcs._insert
    property
    var moveItem: funcs._move
    property
    var removeItem: funcs._remove
    property
    var setItem: funcs._set
    property
    var setValue: funcs._setProperty
    property
    var setPropertyItem: funcs._setProperty
    property
    var sourceItems: funcs._sources
}
