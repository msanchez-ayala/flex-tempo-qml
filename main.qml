import QtQuick
import QtQuick.Controls
import QtMultimedia
import "components"

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
    }

    QtObject {
        id: modelContainer

        property ListModel fileHistoryModel: FileHistoryModel {}
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
                    console.log(modelContainer.fileHistoryModel.rowCount())
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        focus: true
        initialItem: homePage
        anchors.fill: parent
        Keys.onPressed: (event)=> {
                if (event.key === Qt.Key_Space) {
                    mediaPlayer.togglePlaybackState()
                } else if (event.key === Qt.Key_R) {
                    mediaPlayer.reset()
                }
            }
    }

    // Put these inside components so that they don't show by defualt

    HomePage {
        id: homePage

        focus: true
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
            fileHistoryModel: modelContainer.fileHistoryModel
            onSelectedSongChanged: (newUrl) => {
                if (newUrl === mediaPlayer.source) {
                   return
               }
                mediaPlayer.source = newUrl
            }
        }
    }

    MediaPlayer {
        id: mediaPlayer
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
            homePage.resetButtonClicked.connect(reset)
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

        function reset() {
            pause()
            setPosition(0)
            loopStartPos = 0
            setPlaybackRate(1)
            updateloopEndPos()
        }

        function updateloopEndPos() {
            loopEndPos = mediaPlayer.duration
        }
    }



}
