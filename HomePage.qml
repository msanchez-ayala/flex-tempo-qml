import QtQuick
import QtQuick.Controls
import "components"
import "Constants.js" as Constants

Page {
    id: homePage

    // Playback and loop values in ms
    required property real playbackMax
    required property real playbackPos
    required property real loopStartPos
    required property real loopEndPos
    // Fractional values
    required property real rateMax
    required property real ratePos

    signal playbackHandleDragged(real newPos)
    signal rateHandleDragged(real newPos)
    signal loopStartHandleDragged(real newPos)
    signal loopEndHandleDragged(real newPos)

    title: qsTr("Home")

    Component.onCompleted: {
        dial.playbackHandleDragged.connect(homePage.playbackHandleDragged)
        dial.rateHandleDragged.connect(homePage.rateHandleDragged)
        dial.loopStartHandleDragged.connect(homePage.loopStartHandleDragged)
        dial.loopEndHandleDragged.connect(homePage.loopEndHandleDragged)
    }

    // Time conversions

    function convertMsToTime(ms) {
        var seconds = convertMsToSeconds(ms)
        return pad(Math.floor(seconds / 60)) + ":" + pad(Math.floor(seconds % 60))
    }

    function pad(number) {
        if (number <= 9)
            return "0" + number;
        return number;
    }

    function convertMsToSeconds(ms) {
        return Math.floor(ms/1000)
    }

    // Temporary - need better ux
    Column {
        id: textColumn
        anchors {
            top: parent.top
            left: parent.left
            margins: 12
        }

        spacing: 12

        Text {
            id: playbackPosText
            text: 'Playback: ' + convertMsToTime(homePage.playbackPos) + '/' + convertMsToTime(homePage.playbackMax)
        }

        Text {
            id: loopText
            text: 'Looping: ' + convertMsToTime(homePage.loopStartPos) + '-' + convertMsToTime(homePage.loopEndPos)
        }

        Text {
            id: rateText
            text: 'Rate: ' + Math.round(homePage.ratePos * 100).toString() + '%'
        }
    }

    PlaybackDial {
        id: dial

        height: parent.height * 3/4
        width: parent.width * 2/3

        playbackMax: homePage.playbackMax
        playbackPos: homePage.playbackPos
        loopStartPos: homePage.loopStartPos
        loopEndPos: homePage.loopEndPos
        rateMax: homePage.rateMax
        ratePos: homePage.ratePos

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            margins: 2 * Constants.Dimensions.margins
        }

        // Convert a song time into an angle
        function timeToAngle(time) {
            const fraction = time / homePage.playbackMax
            return 2 * Math.PI * fraction
        }

    }

    Row {
        id: buttonRow

        spacing: 12

        anchors {
            top: dial.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 2 * Constants.Dimensions.margins
        }

        Button {
            id: resetBtn
            text: 'Reset'
            onClicked: console.log('EMIT A RESET SIGNAL')
        }

        Button {
            id: startBtn
            text: 'Start'
            onClicked: console.log('EMIT A START SIGNAL')
        }

        Button {
            id: pauseBtn
            text: 'Pause'
            onClicked: console.log('EMIT A PAUSE SIGNAL')
        }
    }
}
