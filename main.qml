import QtQuick
import QtQuick.Controls
import QtMultimedia

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Flex Tempo")
    header: ToolBar {
        id: headerToolBar
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

        ToolButton {
            id: startButton
            anchors.left: toolButton.right
            text: 'start'
            onClicked: mediaPlayer.play()
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
                    stackView.push(homePage)
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Audio Selection")
                width: parent.width
                onClicked: {
                    stackView.push(audioSelectionPageComponent)
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: homePage
        anchors.fill: parent
    }

    // Put these inside components so that they don't show by defualt

    HomePage {
        id: homePage

        playbackMax: mediaPlayer.duration
        playbackPos: mediaPlayer.position
        ratePos: mediaPlayer.playbackRate
        rateMax: 2  // Can reevaluate later
        loopStartPos: mediaPlayer.loopStartPos
        loopEndPos: mediaPlayer.loopEndPos
        playing: mediaPlayer.isPlaying
    }


    Component {
        id: audioSelectionPageComponent

        AudioSelectionPage {
            id: audioSelectionPage
        }
    }

    MediaPlayer {
        id: mediaPlayer
        source: 'file:///Users/Marco/Documents/Recordings/Corey F./East of the Sun.mp3'
        audioOutput: AudioOutput {}

        property real loopStartPos: 0
        property real loopEndPos: 0
        property bool isPlaying: (playbackState === MediaPlayer.PlayingState) ? true : false

        onPositionChanged: {
            if (mediaPlayer.position <= loopStartPos || mediaPlayer.position >= loopEndPos) {
                mediaPlayer.position = loopStartPos
            }
        }
        Component.onCompleted: {
            durationChanged.connect(updateloopEndPos)
            updateloopEndPos()

            homePage.playbackButtonClicked.connect(togglePlaybackState)
            homePage.playbackHandleDragged.connect(setPosition)
            homePage.rateHandleDragged.connect(setPlaybackRate)
            homePage.loopStartHandleDragged.connect((newPos) => { mediaPlayer.loopStartPos = newPos })
            homePage.loopEndHandleDragged.connect((newPos) => { mediaPlayer.loopEndPos = newPos })
        }

        function togglePlaybackState() {
            if (mediaPlayer.isPlaying) {
                mediaPlayer.pause()
            } else {
                mediaPlayer.play()
            }
        }

        function updateloopEndPos() {
            loopEndPos = mediaPlayer.duration
        }
    }



}
