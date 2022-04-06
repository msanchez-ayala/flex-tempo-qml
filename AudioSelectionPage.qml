import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import "Constants.js" as Constants
import 'components'


Page {
    id: audioSelectionPage

    title: qsTr("Audio Selection")

    ColumnLayout {
        id: contentColumn
        anchors {
            fill: parent
            margins: Constants.Dimensions.margins
        }
        spacing: 24

        Row {
            id: importRow
            height: importButton.height
            Layout.alignment: Qt.AlignLeft || Qt.AlignVCenter
            spacing: Constants.Dimensions.margins

            Button {
                id: importButton
                text: qsTr("Import audio")
                onClicked: fileDialog.open()
            }

            Text {
                id: currentFileLabel
                text: 'Select a file'
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Component {
            id: fileHistoryDelegate
            Item {
                width: parent.width; height: 40
                Text {
                    text: fileName
                    anchors.centerIn: parent
                }
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
                model: FileHistoryModel{}
                anchors.fill: parent

                delegate: fileHistoryDelegate
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

                function setCurrentFileUrl(fileUrl) {
                    model.setCurrentFileUrl(fileUrl)
                }
            }

        }
    }

    FileDialog {
        id: fileDialog
        fileMode: FileDialog.OpenFile
        options: FileDialog.ReadOnly
        nameFilters: ['Audio files (*.mp3 *.wav)']
        selectedNameFilter.index: 0
        onAccepted: fileHistoryListView.setCurrentFileUrl(currentFile)

    }

    function urlToFileName(fileUrl) {
        const absPath = fileUrl.toString()
        const relPath = absPath.replace(/^.*[\\\/]/, '')
        const fileName = relPath.replace(/\.[^/.]+$/, "")
        return fileName
    }
}
