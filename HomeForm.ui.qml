import QtQuick
import QtQuick.Controls

Page {
    width: 600
    height: 400
    anchors.centerIn: parent

    title: qsTr("Home")

    Label {
        text: qsTr("You are on the home page.")
        anchors.centerIn: parent
    }
}
