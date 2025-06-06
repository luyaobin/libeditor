import QtQml.Models 2.14
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQuick.Dialogs 1.3

Item {
    id: librariesView

    property string searchFilter: ""

    function filterModules() {
        if (searchFilter.trim() === "") {
            libraryListView.model = librariesModel.moduleModel;
        } else {
            tempModel.model = librariesModel.moduleModel;
            tempModel.filterOnGroup = "filtered";
            libraryListView.model = tempModel;
        }
    }

    onSearchFilterChanged: {
        if (tempModel.model)
            tempModel.updateFilter();
        filterModules();
    }

    Component.onCompleted: {
        libraryListView.model = librariesModel.moduleModel;
    }

    // 过滤模型
    DelegateModel {
        id: tempModel

        function updateFilter() {
            if (!model)
                return;

            for (var i = 0; i < items.count; i++) {
                var item = items.get(i);
                var matches = false;

                if (searchFilter.trim() === "") {
                    matches = true;
                } else {
                    var moduleItem = item.model;
                    if (moduleItem && moduleItem.code && moduleItem.name) {
                        if (moduleItem.code.toLowerCase().indexOf(searchFilter.toLowerCase()) !== -1 || moduleItem.name.toLowerCase().indexOf(searchFilter.toLowerCase()) !== -1)
                            matches = true;
                    }
                }

                if (matches) {
                    if (!filteredGroup.count(item))
                        filteredGroup.insert(item);
                } else {
                    if (filteredGroup.count(item))
                        filteredGroup.remove(item);
                }
            }
        }

        delegate: libraryListView.delegate
        filterOnGroup: "filtered"
        items.onChanged: updateFilter()
        Component.onCompleted: updateFilter()

        groups: [
            DelegateModelGroup {
                id: filteredGroup
                name: "filtered"
                includeByDefault: false
            }
        ]
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // 搜索区域
        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "#ffffff"
            radius: 6
            border.color: "#dee2e6"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: "🔍"
                    font.pixelSize: 14
                    color: "#6c757d"
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: "搜索模块..."
                    font.pixelSize: 12
                    color: "#212529"
                    selectByMouse: true
                    onTextChanged: {
                        searchFilter = text;
                        filterModules();
                    }

                    background: Rectangle {
                        color: "transparent"
                        border.color: parent.focus ? "#007bff" : "transparent"
                        border.width: parent.focus ? 1 : 0
                        radius: 3
                    }
                }

                Button {
                    text: "×"
                    implicitWidth: 24
                    implicitHeight: 24
                    visible: searchInput.text.length > 0
                    onClicked: searchInput.text = ""

                    background: Rectangle {
                        color: parent.hovered ? "#dc3545" : "#6c757d"
                        radius: 12
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
        }

        // 操作按钮区域
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#f8f9fa"
            radius: 6
            border.color: "#dee2e6"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Button {
                    text: "添加模块"
                    Layout.fillWidth: true
                    implicitHeight: 28
                    onClicked: imageFileDialog.open()

                    background: Rectangle {
                        color: parent.hovered ? "#0056b3" : "#007bff"
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Button {
                    text: "刷新"
                    implicitWidth: 50
                    implicitHeight: 28
                    onClicked: {
                        libraryListView.model = librariesModel.moduleModel;
                        searchInput.text = "";
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#5a6268" : "#6c757d"
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 11
                    }
                }
            }
        }

        // 模块列表
        ListView {
            id: libraryListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0
            model: librariesModel.moduleModel
            clip: true
            spacing: 6
            focus: true

            delegate: Rectangle {
                id: delegateItem
                width: libraryListView.width
                height: 80
                color: libraryListView.currentIndex === index ? "#e3f2fd" : "#ffffff"
                radius: 6
                border.color: libraryListView.currentIndex === index ? "#2196f3" : "#e0e0e0"
                border.width: libraryListView.currentIndex === index ? 2 : 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // 模块图标
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: getModuleColor(0)

                        Text {
                            anchors.centerIn: parent
                            text: code.substring(0, 1).toUpperCase()
                            font.pixelSize: 14
                            font.bold: true
                            color: "white"
                        }
                    }

                    // 模块信息
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4

                        Text {
                            text: code
                            font.pixelSize: 13
                            font.bold: true
                            color: "#212529"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: name
                            font.pixelSize: 11
                            color: "#6c757d"
                            elide: Text.ElideRight
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        // 状态和点位信息
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Rectangle {
                                width: statusText.width + 8
                                height: statusText.height + 4
                                color: getStatusColor(model)
                                radius: 8

                                Text {
                                    id: statusText
                                    anchors.centerIn: parent
                                    text: getStatusText(model)
                                    font.pixelSize: 9
                                    color: "white"
                                    font.bold: true
                                }
                            }

                            Text {
                                text: "点位:" + (points ? points.length : 0)
                                font.pixelSize: 9
                                color: "#495057"
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        libraryListView.currentIndex = index;
                        moduleData.selectModule(model);
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
                width: 8

                contentItem: Rectangle {
                    implicitWidth: 6
                    implicitHeight: 100
                    radius: 3
                    color: parent.pressed ? "#495057" : "#6c757d"
                }

                background: Rectangle {
                    color: "#f8f9fa"
                    radius: 3
                }
            }
        }

        // 空状态提示
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            radius: 6
            visible: libraryListView.count === 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "📦"
                    font.pixelSize: 32
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: searchFilter.length > 0 ? "未找到匹配的模块" : "暂无模块数据"
                    font.pixelSize: 12
                    color: "#6c757d"
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    text: searchFilter.length > 0 ? "清除搜索" : "添加模块"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        if (searchFilter.length > 0) {
                            searchInput.text = "";
                        } else {
                            imageFileDialog.open();
                        }
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#0056b3" : "#007bff"
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 11
                    }
                }
            }
        }
    }

    // 图片文件选择对话框
    FileDialog {
        id: imageFileDialog
        title: "选择模块图片"
        folder: shortcuts.pictures
        nameFilters: ["图片文件 (*.png *.jpg *.jpeg *.bmp *.gif)"]
        selectMultiple: false

        onAccepted: {
            var filePath = imageFileDialog.fileUrl.toString();
            // 从文件路径中提取文件名（不包含扩展名）
            var fileName = filePath.split('/').pop().split('\\').pop();
            var moduleName = fileName.replace(/\.[^/.]+$/, ""); // 移除扩展名

            console.log("选择的图片文件:", filePath);
            console.log("提取的模块名称:", moduleName);

            // 创建新模块并设置名称和背景图片
            librariesModel.addModuleWithImage(moduleName, filePath);
        }

        onRejected: {
            console.log("取消选择图片");
        }
    }

    // 辅助函数
    function getModuleColor(index) {
        var colors = ["#007bff", "#28a745", "#dc3545", "#ffc107", "#17a2b8", "#6f42c1"];
        return colors[index % colors.length];
    }

    function getStatusColor(model) {
        if (model.points && model.points.length > 0) {
            return "#28a745"; // 绿色 - 已配置
        }
        return "#6c757d"; // 灰色 - 未配置
    }

    function getStatusText(model) {
        if (model.points && model.points.length > 0) {
            return "已配置";
        }
        return "未配置";
    }
}
