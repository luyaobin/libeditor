import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

// 模块选择器弹窗组件
Popup {
    id: moduleSelectionPopup
    anchors.centerIn: parent
    width: parent.width * 0.85
    height: parent.height * 0.85
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape

    property var selectedModule: null

    // 信号定义
    signal moduleSelected(var module)
    signal selectionCancelled

    background: Rectangle {
        color: "#ffffff"
        radius: 8
        border.color: "#e0e0e0"
        border.width: 2
    }

    // 键盘事件处理
    Keys.onPressed: {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (selectedModule !== null) {
                addSelectedModuleToProject();
                event.accepted = true;
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // 模块图标
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: "#007bff"

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                    }
                }

                Text {
                    text: "选择模块添加到项目"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#212529"
                    Layout.fillWidth: true
                }

                Text {
                    text: "ESC 取消 | Enter 添加"
                    font.pixelSize: 12
                    color: "#6c757d"
                    Layout.alignment: Qt.AlignVCenter
                }

                Button {
                    text: "关闭"
                    implicitWidth: 80
                    implicitHeight: 36
                    onClicked: {
                        selectionCancelled();
                        moduleSelectionPopup.close();
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#5a6268" : "#6c757d"
                        radius: 6
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                    }
                }
            }
        }

        // 搜索栏
        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "#ffffff"
            border.color: "#dee2e6"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                Text {
                    text: "搜索模块："
                    font.pixelSize: 14
                    color: "#495057"
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    color: "#f8f9fa"
                    border.color: moduleSearchField.focus ? "#007bff" : "#ced4da"
                    border.width: moduleSearchField.focus ? 2 : 1
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            text: "🔍"
                            font.pixelSize: 14
                            color: "#6c757d"
                        }

                        TextField {
                            id: moduleSearchField
                            Layout.fillWidth: true
                            placeholderText: "输入模块名称或代码进行搜索..."
                            font.pixelSize: 12
                            color: "#495057"
                            selectByMouse: true
                            background: Item {}

                            property string searchText: text.toLowerCase()

                            onSearchTextChanged: {
                                console.log("搜索模块:", searchText);
                            }
                        }

                        Button {
                            text: "✕"
                            implicitWidth: 20
                            implicitHeight: 20
                            visible: moduleSearchField.text.length > 0
                            onClicked: {
                                moduleSearchField.text = "";
                                moduleSearchField.focus = true;
                            }

                            background: Rectangle {
                                color: parent.hovered ? "#f5f5f5" : "transparent"
                                radius: 10
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 10
                                color: "#6c757d"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                Text {
                    text: "共 " + (librariesModel ? librariesModel.moduleModel.count : 0) + " 个模块"
                    font.pixelSize: 12
                    color: "#6c757d"
                }
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 主内容区域
            RowLayout {
                anchors.fill: parent
                spacing: 15

                // 左侧模块列表区域
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.6
                    color: "#ffffff"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 6

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Text {
                            text: "可用模块列表"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#495057"
                        }

                        // 模块网格视图
                        GridView {
                            id: moduleGridView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            cellWidth: 160
                            cellHeight: 120
                            model: librariesModel ? librariesModel.moduleModel : null
                            clip: true

                            delegate: Rectangle {
                                width: moduleGridView.cellWidth - 8
                                height: moduleGridView.cellHeight - 8
                                color: moduleSelectionPopup.selectedModule === model ? "#e3f2fd" : "#ffffff"
                                border.color: moduleSelectionPopup.selectedModule === model ? "#2196f3" : "#dee2e6"
                                border.width: moduleSelectionPopup.selectedModule === model ? 2 : 1
                                radius: 6

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 4

                                    // 模块图标
                                    Rectangle {
                                        Layout.alignment: Qt.AlignHCenter
                                        width: 40
                                        height: 40
                                        radius: 20
                                        color: moduleSelectionPopup.getModuleColor(index)

                                        Text {
                                            anchors.centerIn: parent
                                            text: model.code ? model.code.substring(0, 1).toUpperCase() : "M"
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: "white"
                                        }
                                    }

                                    // 模块代码
                                    Text {
                                        Layout.fillWidth: true
                                        text: model.code || "未命名"
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: "#212529"
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                    }

                                    // 模块名称
                                    Text {
                                        Layout.fillWidth: true
                                        text: model.name || "无描述"
                                        font.pixelSize: 9
                                        color: "#6c757d"
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                    }

                                    // 点位信息
                                    Text {
                                        Layout.fillWidth: true
                                        text: "点位: " + (model.points ? model.points.length : 0)
                                        font.pixelSize: 8
                                        color: "#495057"
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        moduleSelectionPopup.selectedModule = model;
                                    }
                                    onDoubleClicked: {
                                        moduleSelectionPopup.selectedModule = model;
                                        addSelectedModuleToProject();
                                    }
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                active: true
                                policy: ScrollBar.AsNeeded
                            }
                        }
                    }
                }

                // 右侧预览区域
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.4
                    color: "#ffffff"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 6

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Text {
                            text: "模块详情"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#495057"
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ColumnLayout {
                                width: parent.width
                                spacing: 10

                                // 基本信息卡片
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 180
                                    color: "#f8f9fa"
                                    border.color: "#e9ecef"
                                    border.width: 1
                                    radius: 6

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 8

                                        Text {
                                            text: "基本信息"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "#495057"
                                        }

                                        // 模块信息网格
                                        GridLayout {
                                            Layout.fillWidth: true
                                            columns: 2
                                            columnSpacing: 10
                                            rowSpacing: 6
                                            visible: moduleSelectionPopup.selectedModule !== null

                                            Text {
                                                text: "代码:"
                                                font.pixelSize: 11
                                                color: "#6c757d"
                                            }
                                            Text {
                                                text: moduleSelectionPopup.selectedModule ? moduleSelectionPopup.selectedModule.code || "未设置" : ""
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: "#212529"
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                text: "名称:"
                                                font.pixelSize: 11
                                                color: "#6c757d"
                                            }
                                            Text {
                                                text: moduleSelectionPopup.selectedModule ? moduleSelectionPopup.selectedModule.name || "未设置" : ""
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: "#212529"
                                                Layout.fillWidth: true
                                                wrapMode: Text.WordWrap
                                            }

                                            Text {
                                                text: "IO数:"
                                                font.pixelSize: 11
                                                color: "#6c757d"
                                            }
                                            Text {
                                                text: moduleSelectionPopup.selectedModule ? moduleSelectionPopup.selectedModule.ioNum || "0" : ""
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: "#007bff"
                                            }

                                            Text {
                                                text: "气缸数:"
                                                font.pixelSize: 11
                                                color: "#6c757d"
                                            }
                                            Text {
                                                text: moduleSelectionPopup.selectedModule ? moduleSelectionPopup.selectedModule.airNum || "0" : ""
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: "#28a745"
                                            }
                                        }

                                        // 未选择提示
                                        Text {
                                            Layout.fillWidth: true
                                            text: "请选择一个模块查看详细信息"
                                            font.pixelSize: 12
                                            color: "#6c757d"
                                            horizontalAlignment: Text.AlignHCenter
                                            visible: moduleSelectionPopup.selectedModule === null
                                        }
                                    }
                                }

                                // 点位信息卡片
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 150
                                    color: "#f8f9fa"
                                    border.color: "#e9ecef"
                                    border.width: 1
                                    radius: 6
                                    visible: moduleSelectionPopup.selectedModule !== null

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 8

                                        Text {
                                            text: "点位信息 (" + (moduleSelectionPopup.selectedModule && moduleSelectionPopup.selectedModule.points ? moduleSelectionPopup.selectedModule.points.length : 0) + "个)"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "#495057"
                                        }

                                        ListView {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            model: moduleSelectionPopup.selectedModule && moduleSelectionPopup.selectedModule.points ? moduleSelectionPopup.selectedModule.points : null
                                            clip: true

                                            delegate: Rectangle {
                                                width: parent.width
                                                height: 22
                                                color: index % 2 === 0 ? "#ffffff" : "#f8f9fa"
                                                radius: 3

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 4
                                                    spacing: 8

                                                    Rectangle {
                                                        width: 14
                                                        height: 14
                                                        radius: 7
                                                        color: "#007bff"

                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: (index + 1)
                                                            font.pixelSize: 7
                                                            font.bold: true
                                                            color: "white"
                                                        }
                                                    }

                                                    Text {
                                                        text: "X:" + (modelData.x || 0) + " Y:" + (modelData.y || 0)
                                                        font.pixelSize: 9
                                                        color: "#495057"
                                                        Layout.fillWidth: true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // 模块图片预览卡片
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 160
                                    color: "#f8f9fa"
                                    border.color: "#e9ecef"
                                    border.width: 1
                                    radius: 6
                                    visible: moduleSelectionPopup.selectedModule !== null

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 8

                                        Text {
                                            text: "模块图片"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "#495057"
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            color: "#ffffff"
                                            border.color: "#dee2e6"
                                            border.width: 1
                                            radius: 4

                                            Image {
                                                id: modulePreviewImage
                                                anchors.centerIn: parent
                                                width: Math.min(parent.width - 16, 120)
                                                height: Math.min(parent.height - 16, 100)
                                                fillMode: Image.PreserveAspectFit
                                                source: moduleSelectionPopup.selectedModule && moduleSelectionPopup.selectedModule.base64 ? moduleSelectionPopup.selectedModule.base64 : ""
                                                visible: source !== ""

                                                onStatusChanged: {
                                                    if (status === Image.Error) {
                                                        console.log("模块图片加载失败");
                                                    }
                                                }
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "暂无图片"
                                                font.pixelSize: 11
                                                color: "#6c757d"
                                                visible: modulePreviewImage.source === ""
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // 底部操作栏
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: moduleSelectionPopup.selectedModule ? "已选择: " + (moduleSelectionPopup.selectedModule.code || "未命名") : "请选择一个模块"
                        font.pixelSize: 13
                        color: "#495057"
                        font.bold: true
                    }

                    Text {
                        text: "可用模块: " + (librariesModel ? librariesModel.moduleModel.count : 0) + " 个 | 项目中已有: " + (projects ? projects.currentProjectModules.count : 0) + " 个"
                        font.pixelSize: 10
                        color: "#6c757d"
                    }
                }

                Button {
                    text: "添加到项目"
                    implicitWidth: 120
                    implicitHeight: 40
                    enabled: moduleSelectionPopup.selectedModule !== null
                    onClicked: addSelectedModuleToProject()

                    background: Rectangle {
                        color: parent.enabled ? (parent.hovered ? "#218838" : "#28a745") : "#6c757d"
                        radius: 6
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                        font.bold: true
                    }
                }
            }
        }
    }

    // 添加选中模块到项目的函数
    function addSelectedModuleToProject() {
        if (moduleSelectionPopup.selectedModule) {
            moduleSelected(moduleSelectionPopup.selectedModule);
            moduleSelectionPopup.close();
            moduleSelectionPopup.selectedModule = null;
            moduleSearchField.text = "";
        }
    }

    // 弹窗打开时重置状态
    onOpened: {
        selectedModule = null;
        moduleSearchField.text = "";
        moduleSearchField.focus = true;
    }

    // 辅助函数：获取模块颜色
    function getModuleColor(index) {
        var colors = ["#007bff", "#28a745", "#dc3545", "#ffc107", "#17a2b8", "#6f42c1", "#fd7e14", "#20c997"];
        return colors[index % colors.length];
    }
}
