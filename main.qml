import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Flex Tempo")

    readonly property int margins: 12

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "\u2630"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Home")
                width: parent.width
                onClicked: {
                    stackView.push("HomeForm.ui.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Audio Selection")
                width: parent.width
                onClicked: {
                    stackView.push("AudioSelectionPage.qml")
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "HomeForm.ui.qml"
        anchors.fill: parent
    }
}
