import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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


//    // Temporary - need better ux
//    Column {
//        id: textColumn
//        anchors {
//            top: parent.top
//            left: parent.left
//            margins: 12
//        }

//        spacing: 12

//        Text {
//            id: playbackPosText
//            text: 'Playback: ' + convertMsToTime(root.playbackPos) + '/' + convertMsToTime(root.playbackMax)
//        }

//        Text {
//            id: loopText
//            text: 'Looping: ' + convertMsToTime(root.loopStartPos) + '-' + convertMsToTime(root.loopEndPos)
//        }

    //        Text {
//            id: rateText
//            text: 'Rate: ' + Math.round(root.ratePos * 100).toString() + '%'
//        }
//    }

    ColumnLayout  {

        anchors {
            fill: parent
            margins: Constants.Dimensions.margins
        }

        Text {
            id: songNameText

            text: (currentSongName === '') ? 'Select a song' : currentSongName
            color: (currentSongName === '') ? 'gray' : 'black'
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Qt.application.font.pixelSize * 1.6

        }

        Text {
            id: playbackTimeText

            text: {
                if (currentSongName === '') {
                    return ''
                }
                const curTime = convertMsToTime(root.playbackPos)
                const maxTime = convertMsToTime(root.playbackMax)
                return curTime + ' / ' + maxTime
            }
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Qt.application.font.pixelSize * 1.2

        }

        PlaybackDial {
            id: dial

            implicitHeight: Math.max(parent.height / 2, parent.width - (2 * Constants.Dimensions.margins))
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
            }

            Button {
                id: playbackButton
                text: playing ? 'Pause' : 'Play'
            }
        }

    }

}
