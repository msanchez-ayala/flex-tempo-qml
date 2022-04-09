import QtQuick
import QtQuick.Controls
import QtMultimedia

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Flex Tempo")

    MediaPlayer {
        id: mediaPlayer
        source: 'file:///Users/Marco/Documents/Recordings/Corey F./East of the Sun.mp3'
        audioOutput: AudioOutput {}

        readonly property real defaultStartPosition: 0

        property real loopStartPosition: defaultStartPosition
        property real loopEndPosition

        onPositionChanged: {
            if (mediaPlayer.position <= loopStartPosition || mediaPlayer.position >= loopEndPosition) {
                mediaPlayer.position = loopStartPosition
            }
        }
        onSourceChanged: {
            loopEndPosition = duration
        }
    }

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
                    stackView.push(homePageComponent)
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
        initialItem: homePageComponent
        anchors.fill: parent
    }

    // Put these inside components so that they don't show by defualt

    Component {
        id: homePageComponent
        HomePage {
            id: homePage
            // Figure out a two way mapping without creating a binding loop
            playbackTotal: mediaPlayer.duration
            currentTime: mediaPlayer.position
            playbackRate: mediaPlayer.playbackRate
            loopStartTime: mediaPlayer.loopStartPosition
            loopEndTime: mediaPlayer.loopEndPosition
            onPlaybackHandleDragged: (newPosition) => mediaPlayer.setPosition(newPosition)
            onRateHandleDragged: (newRate) => mediaPlayer.setPlaybackRate(newRate)
            onLoopHandleDragged: (newLoopStartPos, newLoopEndPos) => {
                mediaPlayer.loopStartPosition = newLoopStartPos
                mediaPlayer.loopEndPosition = newLoopEndPos
            }
        }
    }


    Component {
        id: audioSelectionPageComponent
        AudioSelectionPage {
            id: audioSelectionPage
        }
    }



}
