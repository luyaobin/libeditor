import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Rectangle {
    id: pointsArea

    property var points: null
    property bool isEditing: true

    signal pointSelected(int index)
    signal pointDeleted(int index)

    color: "#F5F5F5"
    border.color: "#e0e0e0"
    border.width: 1
    radius: 4

    ListView {
        id: pointsListView

        anchors.fill: parent
        anchors.margins: 5
        spacing: 5
        clip: true
        model: points

        delegate: Rectangle {
            width: pointsListView.width - 10
            height: 40
            color: index % 2 === 0 ? "#f8f8f8" : "#ffffff"
            border.color: pointsListView.currentIndex === index ? "#4a90e2" : "transparent"
            border.width: 1
            radius: 3

            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 10

                Text {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    text: "点位" + (index + 1) // (moduleData.tags.count > index ? moduleData.tags.get(index).tag : (index + 1) + "(默认)")
                }

                Text {
                    Layout.preferredWidth: 100
                    text: strValue
                }

                TextField {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    placeholderText: "回路名称"
                    text: loopName
                }
            }
        }

        ScrollBar.vertical: ScrollBar {}
    }

    // 如果没有点位，显示提示信息
    Text {
        anchors.centerIn: parent
        text: "暂无点位数据"
        color: "#999999"
        font.pixelSize: 14
        visible: pointsListView.count === 0
    }
}
