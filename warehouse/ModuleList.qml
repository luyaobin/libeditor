import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQuick.Dialogs 1.3

Item {
    id: librariesView

    property string searchText: ""
    property string filterType: "all"

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // 搜索和筛选栏
        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // 搜索框
                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "搜索模块..."
                    text: librariesView.searchText
                    onTextChanged: librariesView.searchText = text

                    background: Rectangle {
                        color: "#ffffff"
                        border.color: parent.focus ? "#007bff" : "#ced4da"
                        border.width: parent.focus ? 2 : 1
                        radius: 4
                    }
                }

                // 筛选下拉框
                ComboBox {
                    id: filterCombo
                    Layout.preferredWidth: 120
                    model: ["全部", "已配置", "未配置"]
                    currentIndex: 0
                    onCurrentTextChanged: {
                        switch (currentIndex) {
                        case 0:
                            librariesView.filterType = "all";
                            break;
                        case 1:
                            librariesView.filterType = "configured";
                            break;
                        case 2:
                            librariesView.filterType = "unconfigured";
                            break;
                        }
                    }

                    background: Rectangle {
                        color: "#ffffff"
                        border.color: "#ced4da"
                        border.width: 1
                        radius: 4
                    }
                }

                // 添加模块按钮
                Button {
                    text: "添加模块"
                    implicitHeight: 32
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
                        font.pixelSize: 12
                    }
                }
            }
        }

        // 模块统计信息
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: "#e9ecef"
            radius: 4

            Text {
                anchors.centerIn: parent
                text: "共 " + libraryListView.count + " 个模块"
                font.pixelSize: 12
                color: "#495057"
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
            spacing: 8
            focus: true
            orientation: ListView.Horizontal

            delegate: Rectangle {
                id: delegateItem

                width: 180
                height: libraryListView.height - 20
                color: libraryListView.currentIndex === index ? "#e3f2fd" : "#ffffff"
                radius: 8
                border.color: libraryListView.currentIndex === index ? "#2196f3" : "#e0e0e0"
                border.width: libraryListView.currentIndex === index ? 2 : 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12

                    // 模块图标
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 50
                        height: 50
                        radius: 25
                        color: getModuleColor(index)

                        Text {
                            anchors.centerIn: parent
                            text: code.substring(0, 1).toUpperCase()
                            font.pixelSize: 18
                            font.bold: true
                            color: "white"
                        }
                    }

                    // 模块信息
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: code
                            font.pixelSize: 14
                            font.bold: true
                            color: "#212529"
                            elide: Text.ElideRight
                            Layout.maximumWidth: parent.width
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: name
                            font.pixelSize: 12
                            color: "#6c757d"
                            elide: Text.ElideRight
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            Layout.maximumWidth: parent.width
                        }

                        // 模块状态
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: statusText.width + 12
                            height: statusText.height + 6
                            color: getStatusColor(model)
                            radius: 10

                            Text {
                                id: statusText
                                anchors.centerIn: parent
                                text: getStatusText(model)
                                font.pixelSize: 10
                                color: "white"
                                font.bold: true
                            }
                        }

                        // 点位数量
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "点位: " + (points ? points.length : 0)
                            font.pixelSize: 11
                            color: "#495057"
                        }

                        // 操作按钮
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 5

                            Button {
                                text: "编辑"
                                implicitWidth: 50
                                implicitHeight: 24
                                onClicked: {
                                    libraryListView.currentIndex = index;
                                    moduleData.selectModule(model);
                                }

                                background: Rectangle {
                                    color: parent.hovered ? "#0056b3" : "#007bff"
                                    radius: 3
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 10
                                }
                            }

                            Button {
                                text: "删除"
                                implicitWidth: 50
                                implicitHeight: 24
                                onClicked: deleteDialog.open()

                                background: Rectangle {
                                    color: parent.hovered ? "#c82333" : "#dc3545"
                                    radius: 3
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 10
                                }

                                // 删除确认对话框
                                Dialog {
                                    id: deleteDialog
                                    title: "确认删除"
                                    modal: true
                                    anchors.centerIn: parent
                                    width: 300
                                    height: 150

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 15

                                        Text {
                                            text: "确定要删除模块 \"" + code + "\" 吗？"
                                            font.pixelSize: 14
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Button {
                                                text: "取消"
                                                onClicked: deleteDialog.close()

                                                background: Rectangle {
                                                    color: parent.hovered ? "#e9ecef" : "#f8f9fa"
                                                    border.color: "#dee2e6"
                                                    radius: 4
                                                }
                                            }

                                            Button {
                                                text: "删除"
                                                onClicked: {
                                                    librariesModel.removeModule(index);
                                                    deleteDialog.close();
                                                }

                                                background: Rectangle {
                                                    color: parent.hovered ? "#c82333" : "#dc3545"
                                                    radius: 4
                                                }

                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "white"
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        libraryListView.currentIndex = index;
                        moduleData.selectModule(model);
                    }
                }
            }

            ScrollBar.horizontal: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
                height: 8

                contentItem: Rectangle {
                    implicitHeight: 6
                    implicitWidth: 100
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
                spacing: 15

                Text {
                    text: "📦"
                    font.pixelSize: 48
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "暂无模块数据"
                    font.pixelSize: 16
                    color: "#6c757d"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "点击上方\"添加模块\"按钮创建新模块"
                    font.pixelSize: 12
                    color: "#adb5bd"
                    Layout.alignment: Qt.AlignHCenter
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
