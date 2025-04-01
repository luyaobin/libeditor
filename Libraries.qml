import QtGraphicalEffects 1.0
import QtQml.Models 2.15 // 使用此导入来支持 DelegateModelGroup
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: librariesView

    // 添加搜索过滤属性
    property string searchFilter: ""

    // 创建过滤模型函数
    function filterModules() {
        // 更新DelegateModel的过滤功能
        if (searchFilter.trim() === "") {
            // 如果没有搜索内容，直接使用原始模型
            libraryListView.model = librariesModel.moduleModel;
        } else {
            // 配置过滤模型并应用到ListView
            tempModel.model = librariesModel.moduleModel;
            tempModel.filterOnGroup = "filtered";
            libraryListView.model = tempModel;
        }
    }

    // 当搜索过滤器变化时重新应用过滤
    onSearchFilterChanged: {
        if (tempModel.model)
            tempModel.updateFilter();

        filterModules();
    }
    // 组件加载完成后监听搜索过滤器变化
    Component.onCompleted: {
        // 初始时使用原始模型
        libraryListView.model = librariesModel.moduleModel;
    }

    // 临时模型用于存储过滤结果
    DelegateModel {
        id: tempModel

        // 更新过滤函数
        function updateFilter() {
            if (!model)
                return ;

            for (var i = 0; i < items.count; i++) {
                var item = items.get(i);
                // 检查是否匹配搜索条件
                var matches = false;
                if (searchFilter.trim() === "") {
                    matches = true;
                } else {
                    var moduleItem = item.model;
                    if (moduleItem && moduleItem.code && moduleItem.name) {
                        // 检查是否包含搜索关键词（不区分大小写）
                        if (moduleItem.code.toLowerCase().indexOf(searchFilter.toLowerCase()) !== -1 || moduleItem.name.toLowerCase().indexOf(searchFilter.toLowerCase()) !== -1)
                            matches = true;

                    }
                }
                // 根据匹配结果设置组员资格
                if (matches) {
                    if (!filteredGroup.count(item))
                        filteredGroup.insert(item);

                } else {
                    if (filteredGroup.count(item))
                        filteredGroup.remove(item);

                }
            }
        }

        delegate: libraryListView.delegate // 确保使用相同的代理
        // 过滤器函数，用于动态确定项目是否应包含在过滤组中
        filterOnGroup: "filtered"
        // 定义项目过滤逻辑
        items.onChanged: updateFilter()
        // 当搜索关键词变化时更新过滤
        Component.onCompleted: {
            updateFilter();
        }
        // 配置代理组
        groups: [
            DelegateModelGroup {
                id: filteredGroup

                name: "filtered"
                includeByDefault: false
            }
        ]
    }

    // 显示列表
    ListView {
        id: libraryListView

        currentIndex: 0
        anchors.fill: parent
        model: librariesModel.moduleModel
        clip: true
        spacing: 5
        focus: true

        header: Rectangle {
            width: parent.width
            height: 100 // 增加高度以容纳搜索框
            color: "#f8f8f8"
            radius: 5
            border.color: "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Text {
                        text: "模块库"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333333"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        // 显示提示信息

                        text: "列表导入"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        onClicked: {
                            editorLabelModify.open();
                        }

                        background: Rectangle {
                            color: parent.pressed ? "#3a7ab3" : "#4a90e2"
                            radius: 5
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                    }

                    Button {
                        // 显示提示信息

                        text: "添加模块"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        ToolTip.text: "添加模块 (最后一个模块无名称时不允许添加)"
                        ToolTip.visible: hovered
                        ToolTip.delay: 500
                        onClicked: {
                            // 检查最后一个模块的名称是否为空
                            const size = librariesModel.moduleModel.count;
                            var lastModule = librariesModel.moduleModel.get(size - 1);
                            if (lastModule && lastModule.name === "")
                                return ;

                            // 使用来自librariesModel的方法添加新模块
                            librariesModel.addModule();
                        }

                        background: Rectangle {
                            color: parent.pressed ? "#3a7ab3" : "#4a90e2"
                            radius: 5
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                    }

                }

                // 添加搜索框
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    color: "#ffffff"
                    radius: 4
                    border.color: "#e0e0e0"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 5

                        // 搜索图标
                        Text {
                            text: "🔍"
                            font.pixelSize: 14
                            color: "#888888"
                        }

                        // 搜索输入框
                        TextField {
                            id: searchInput

                            Layout.fillWidth: true
                            placeholderText: "搜索模块名称或代码..."
                            font.pixelSize: 13
                            color: "#333333"
                            selectByMouse: true
                            onTextChanged: {
                                searchFilter = text;
                                filterModules();
                            }

                            background: Item {
                            }

                        }

                        // 清除按钮
                        Text {
                            text: "✕"
                            font.pixelSize: 14
                            color: "#888888"
                            visible: searchInput.text.length > 0

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -5
                                onClicked: {
                                    searchInput.text = "";
                                    searchInput.focus = true;
                                }
                            }

                        }

                    }

                }

            }

        }

        delegate: Rectangle {
            id: delegateItem

            width: parent.width
            height: 60
            color: libraryListView.currentIndex === index ? "#f0f7ff" : (index % 2 === 0 ? "#ffffff" : "#f9f9f9")
            radius: 5
            border.color: "#e0e0e0"
            border.width: 1
            // 添加阴影效果
            layer.enabled: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: "#4a90e2"

                    Text {
                        anchors.centerIn: parent
                        text: code.substring(0, 1)
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }

                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        text: code
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                        elide: Text.ElideRight
                    }

                    Text {
                        text: name
                        font.pixelSize: 13
                        color: "#666666"
                        elide: Text.ElideRight
                    }

                }

            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    libraryListView.currentIndex = index;
                    // 根据当前使用的模型确定如何获取数据
                    if (libraryListView.model === tempModel) {
                        // 如果使用DelegateModel，需要通过items获取实际数据
                        var item = tempModel.items.get(index);
                        if (item && item.model)
                            moduleData.selectModule(item.model);

                    } else {
                        // 直接使用原始模型
                        moduleData.selectModule(model);
                    }
                }
            }

            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 1
                radius: 3
                samples: 7
                color: "#20000000"
            }

            // 添加鼠标悬停效果
            states: State {
                name: "hovered"
                when: mouseArea.containsMouse

                PropertyChanges {
                    target: delegateItem
                    color: "#e8f4ff"
                }

            }

        }

        ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
            width: 10

            contentItem: Rectangle {
                implicitWidth: 6
                implicitHeight: 100
                radius: 3
                color: parent.pressed ? "#606060" : "#909090"
            }

        }

    }

}
