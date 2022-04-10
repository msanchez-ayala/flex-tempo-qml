import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "components"
import "Constants.js" as Constants

Page {
    id: root

    // Playback and loop values in ms
    required property real playbackMax
    required property real playbackPos
    required property real loopStartPos
    required property real loopEndPos
    // Fractional values
    required property real rateMax
    required property real ratePos

    required property string currentSongName
    required property bool playing

    signal playbackHandleDragged(real newPos)
    signal rateHandleDragged(real newPos)
    signal loopStartHandleDragged(real newPos)
    signal loopEndHandleDragged(real newPos)
    signal playbackButtonClicked()
    signal resetButtonClicked()

    title: qsTr("Home")

    Component.onCompleted: {
        dial.playbackHandleDragged.connect(root.playbackHandleDragged)
        dial.rateHandleDragged.connect(root.rateHandleDragged)
        dial.loopStartHandleDragged.connect(root.loopStartHandleDragged)
        dial.loopEndHandleDragged.connect(root.loopEndHandleDragged)
        playbackButton.clicked.connect(playbackButtonClicked)
        resetButton.clicked.connect(resetButtonClicked)
    }

    // Time conversions

    function convertMsToTime(ms) {
        var seconds = convertMsToSeconds(ms)
        return Math.floor(seconds / 60) + ":" + pad(Math.floor(seconds % 60))
    }

    function pad(number) {
        if (number <= 9)
            return "0" + number;
        return number;
    }

    function convertMsToSeconds(ms) {
        return Math.floor(ms/1000)
    }

    ColumnLayout  {

        anchors {
            fill: parent
            margins: Constants.Dimensions.margins
        }

        Item {
            id: infoLabelRow


            implicitHeight: loopTimeText.height
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true


            UnderlinedText {
                id: loopTimeText

                text: {
                    if (currentSongName === '') {
                        return ''
                    }
                    const startTime = convertMsToTime(root.loopStartPos)
                    const endTime = convertMsToTime(root.loopEndPos)
                    return startTime + ' - ' + endTime
                }
                width: parent.width / 3
                anchors.right: playbackTimeText.left
                fontSize: Qt.application.font.pixelSize * 1.2
                underlineColor: Material.color(Material.Green, Material.Shade700)

            }

            UnderlinedText {
                id: playbackTimeText
                text: {
                    if (currentSongName === '') {
                        return ''
                    }
                    const curTime = convertMsToTime(root.playbackPos)
                    const maxTime = convertMsToTime(root.playbackMax)
                    return curTime + ' / ' + maxTime
                }
                width: parent.width / 3
                anchors.horizontalCenter: parent.horizontalCenter
                fontSize: Qt.application.font.pixelSize * 1.2
                underlineColor: Material.color(Material.Indigo, Material.Shade700)

            }

            UnderlinedText {
                id: playbackRateText

                text: {
                    if (currentSongName === '') {
                        return ''
                    }
                    return Math.round(root.ratePos * 100).toString() + '%'
                }
                width: parent.width / 3
                anchors.left: playbackTimeText.right
                fontSize: Qt.application.font.pixelSize * 1.2
                underlineColor: Material.color(Material.Orange, Material.Shade700)
            }
        }

        Text {
            id: songNameText

            text: (currentSongName === '') ? 'Select a song' : currentSongName
            color: (currentSongName === '') ? 'gray' : 'black'
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Qt.application.font.pixelSize * 1.6
        }




        PlaybackDial {
            id: dial

            implicitHeight: Math.min(parent.height * 2/3, parent.width)
            implicitWidth: implicitHeight
            Layout.alignment: Qt.AlignHCenter

            playbackMax: root.playbackMax
            playbackPos: root.playbackPos
            loopStartPos: root.loopStartPos
            loopEndPos: root.loopEndPos
            rateMax: root.rateMax
            ratePos: root.ratePos
        }

        Row {
            id: buttonRow

            spacing: Constants.Dimensions.margins
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: resetButton
                text: 'Reset'
                font.pixelSize: Qt.application.font.pixelSize * 1.2
            }

            Button {
                id: playbackButton
                text: playing ? 'Pause' : 'Play'
                font.pixelSize: Qt.application.font.pixelSize * 1.2
            }
        }

    }

}
