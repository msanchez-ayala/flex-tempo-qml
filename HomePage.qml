import QtQuick
import QtQuick.Controls
import "components"
import "Constants.js" as Constants

Page {
    id: homePage

    title: qsTr("Home")

    signal playbackHandleDragged(int newPosition)
    signal rateHandleDragged(real newRate)
    signal loopHandleDragged(int newLoopStartPos, int newLoopEndPos)


    property int playbackTotal: 50000
    readonly property real rateMaximum: 1

    readonly property int defaultPlaybackRate: 1
    readonly property int defaultCurrentTime: 0
    readonly property int defaultLoopStartTime: 0
    readonly property int defaultLoopEndTime: playbackTotal  // Default to full loop

    property real playbackRate: defaultPlaybackRate
    property int currentTime: defaultCurrentTime
    property int loopStartTime: defaultLoopStartTime
    property int loopEndTime: defaultLoopEndTime

    onCurrentTimeChanged: {
        if (currentTime <= loopStartTime || currentTime >= loopEndTime) {
            currentTime = loopStartTime
        }
    }


    Column {
        id: textColumn
        anchors {
            top: parent.top
            left: parent.left
            margins: 12
        }

        spacing: 12

        Text {
            id: currentTimeText
            text: 'Playback: ' + convertMsToTime(currentTime) + '/' + convertMsToTime(playbackTotal)
        }

        Text {
            id: loopText
            text: 'Looping: ' + convertMsToTime(loopStartTime) + '-' + convertMsToTime(loopEndTime)
        }

        Text {
            id: rateText
            text: 'Rate: ' + Math.round(playbackRate * 100).toString() + '%'
        }
    }

    // These are all required for some reason. Maybe I need to change
    // the fact that these values are explicitly set elsewhere, which nullifies
    // any bindings set directly on the object.
    // Could be that I just need to define fractions on the dial, like for playback
    onPlaybackRateChanged: {
        dial.rateEnd = Qt.binding(function() {
            return (playbackRate / rateMaximum) * (2 * Math.PI)
        })
    }

    onLoopEndTimeChanged: {
        dial.loopEnd = Qt.binding(function() {
            return dial.timeToAngle(loopEndTime)
        })
    }

    onLoopStartTimeChanged: {
        dial.loopStart = Qt.binding(function() {
            return dial.timeToAngle(loopStartTime)
        })
    }

    PlaybackDial {
        id: dial
        height: parent.height * 3/4
        width: parent.width * 2/3

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            margins: 2 * Constants.Dimensions.margins
        }

        playbackFraction: currentTime / playbackTotal

        onPlaybackHandleDragged: {
            const newFraction = dial.playbackEnd / (2* Math.PI)
            const newPosition = playbackTotal * newFraction
            homePage.playbackHandleDragged(newPosition)
        }
        onRateHandleDragged: {
            const newFraction = dial.rateEnd / (2* Math.PI)
            const newRate = rateMaximum * newFraction
            homePage.rateHandleDragged(newRate)
        }
        onLoopHandleDragged: {
            const startFraction = dial.loopStart / (2*Math.PI)
            const newLoopStartTime = playbackTotal * startFraction

            const endFraction = dial.loopEnd / (2*Math.PI)
            const newLoopEndTime = playbackTotal * endFraction

            homePage.loopHandleDragged(newLoopStartTime, newLoopEndTime)
        }

        // Convert a song time into an angle
        function timeToAngle(time) {
            const fraction = time / playbackTotal
            return 2 * Math.PI * fraction
        }

    }

    Row {
        id: buttonRow
        anchors {
            top: dial.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 2 * Constants.Dimensions.margins
        }
        spacing: 12

        Button {
            id: resetBtn
            text: 'Reset'
            onClicked: {
                timeInterval = defaultTimeInterval
                playbackRate = defaultPlaybackRate
                loopStartTime = defaultLoopStartTime
                loopEndTime = defaultLoopEndTime
                currentTime = defaultCurrentTime
            }
        }

        Button {
            id: startBtn
            text: 'Start'
            onClicked: timer.running = true
        }

        Button {
            id: pauseBtn
            text: 'Pause'
            onClicked: timer.running = false
        }
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
}
