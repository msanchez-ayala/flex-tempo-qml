import QtQuick
import QtQuick.Controls
import "components"

Page {
    id: homePage

    title: qsTr("Home")


    readonly property int playbackTotal: 50000
    readonly property real rateMaximum: 1

    readonly property int defaultTimeInterval: 20
    readonly property int defaultPlaybackRate: 1
    readonly property int defaultCurrentTime: 0
    readonly property int defaultLoopStartTime: 0
    readonly property int defaultLoopEndTime: playbackTotal  // Default to full loop

    property real timeInterval: defaultTimeInterval
    property real playbackRate: defaultPlaybackRate
    property int currentTime: defaultCurrentTime
    property int loopStartTime: defaultLoopStartTime
    property int loopEndTime: defaultLoopEndTime

    onCurrentTimeChanged: {
        if (currentTime <= loopStartTime || currentTime >= loopEndTime) {
            currentTime = loopStartTime
        }
    }

    Timer {
        id: timer
        interval: defaultTimeInterval; running: false; repeat: true
        onTriggered: {
            if (currentTime + timeInterval > playbackTotal) {
                currentTime = playbackTotal - currentTime + timeInterval
            } else {
                currentTime += timeInterval
            }
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
        anchors.fill: parent
        playbackFraction: currentTime / playbackTotal

        onPlaybackHandleDragged: {
            const newFraction = dial.playbackEnd / (2* Math.PI)
            currentTime = playbackTotal * newFraction
        }
        onRateHandleDragged: {
            const newFraction = dial.rateEnd / (2* Math.PI)
            playbackRate = rateMaximum * newFraction
            timeInterval = playbackRate * defaultTimeInterval
        }
        onLoopHandleDragged: {
            const startFraction = dial.loopStart / (2*Math.PI)
            loopStartTime = playbackTotal * startFraction

            const endFraction = dial.loopEnd / (2*Math.PI)
            loopEndTime = playbackTotal * endFraction
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
