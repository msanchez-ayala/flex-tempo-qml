import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Constants.js" as Constants
import 'components'


Page {
    id: root

    required property ListModel fileHistoryModel

    signal selectedSongChanged(string newUrl)

    title: qsTr("Audio Selection")


    ColumnLayout {
        id: contentColumn
        anchors {
            fill: parent
            margins: Constants.Dimensions.margins
        }
        spacing: 24

        Component {
            id: highlight
            Rectangle {
                width: listViewContainer.width; height: 40
                color: "lightsteelblue"
                y: fileHistoryListView.currentItem.y
                Behavior on y { SmoothedAnimation { duration: 160 } }
            }
        }

        Rectangle {
            id: listViewContainer
            color: '#efefef'
            Layout.fillHeight: true
            Layout.fillWidth: true
            border.width: 1
            border.color: '#999999'
            radius: 12

            ListView {
                id: fileHistoryListView
                anchors.fill: parent

                model: root.fileHistoryModel
                delegate: Component {
                    Item {
                        width: parent.width; height: 40
                        Text { text: fileName ;  anchors.centerIn: parent }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: fileHistoryListView.currentIndex = index
                        }
                    }
                }
                header: Item {
                    id: listViewHeader
                    width: parent.width; height: headerText.height + 2*Constants.Dimensions.margins
                    Text {
                        id: headerText
                        text: 'Imported Songs'
                        font.bold: true;
                        anchors.centerIn: parent
                    }
                }
                headerPositioning: ListView.OverlayHeader
                highlight: highlight

                onCurrentIndexChanged: {
                    const data = model.get(currentIndex)
                    root.selectedSongChanged(data.url)
                }

                function setCurrentFileUrl(fileUrl) {
                    model.setCurrentFileUrl(fileUrl)
                }
            }

        }
    }


}
