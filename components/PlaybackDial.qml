import QtQuick
import QtQuick.Controls.Material
import "../Constants.js" as Constants


Item {
    id: playbackDial

//    // Playback and loop values in ms
//    required property real playbackMax
//    required property real playbackPos
//    required property real loopStartPos
//    required property real loopEndPos
//    // Fractional value
//    required property real rateMax
//    required property real ratePos

    enum HandleTypes {
        None,
        LoopStart,
        LoopEnd,
        PlaybackStart,
        PlaybackEnd,
        RateStart,
        RateEnd
    }

    // Encapsulate private properties in QObjects
    QtObject {
        id: colors
        readonly property color baseArc: Material.color(Material.Grey, Material.Shade300)
        readonly property color playbackArc: Material.color(Material.Indigo, Material.Shade300)
        readonly property color playbackHandle: Material.color(Material.Indigo, Material.Shade700)
        readonly property color loopArc: Material.color(Material.Green, Material.Shade300)
        readonly property color loopHandle: Material.color(Material.Green, Material.Shade700)
        readonly property color rateArc: Material.color(Material.Orange, Material.Shade200)
        readonly property color rateHandle: Material.color(Material.Orange, Material.Shade700)
    }
    property real playbackFraction: 0
    property real loopStartFraction: 0
    property real loopEndFraction: 0
    property real playbackRateFraction: 0

    readonly property int defaultActiveHandle: PlaybackDial.HandleTypes.None
    property int activeHandle: defaultActiveHandle

    readonly property real playbackStart: 0
    readonly property real rateStart: 0
    property real playbackEnd
    property real loopStart
    property real loopEnd
    property real rateEnd

    signal playbackHandleDragged
    signal rateHandleDragged
    signal loopHandleDragged // Either loop handle is dragged by user

    onPlaybackFractionChanged: playbackEnd = playbackFraction * Constants.Numbers.twoPi
    onPlaybackEndChanged: canvas.requestPaint()
    onLoopStartChanged: canvas.requestPaint()
    onLoopEndChanged: canvas.requestPaint()
    onRateEndChanged: canvas.requestPaint()

    function incrementValue(value) {
        const rads = Math.PI / 4
        if (value >= Constants.Numbers.twoPi) {
            return rads
        } else {
            return value += rads
        }
    }
//    Rectangle {
//        id: debugRect
//        anchors.fill: playbackDial
//        color: 'transparent'
//        border.color: 'red'
//    }


    Canvas {
        id: canvas
        width: playbackDial.width
        height: Math.min(width, playbackDial.height)
        anchors.centerIn: parent

        QtObject {
            id: canvasConsts
            readonly property real centerX: width/2
            readonly property real centerY: height/2
            readonly property int arcLineWidth: 40
            readonly property real baseArcRadius: (Math.min(width, height) - arcLineWidth)/2
            readonly property real loopArcRadius: baseArcRadius - arcLineWidth
            readonly property real rateArcRadius: loopArcRadius - arcLineWidth
            readonly property real handleArcRadius: arcLineWidth/2
        }






        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            drawArc(ctx, playbackStart, Constants.Numbers.twoPi, canvasConsts.baseArcRadius, colors.baseArc)
            drawArc(ctx, playbackStart, playbackEnd, canvasConsts.baseArcRadius, colors.playbackArc)
            drawArc(ctx, loopStart, loopEnd, canvasConsts.loopArcRadius, colors.loopArc)
            drawArc(ctx, rateStart, rateEnd, canvasConsts.rateArcRadius, colors.rateArc)
            drawHandle(ctx, colors.playbackArc, PlaybackDial.HandleTypes.PlaybackStart)
            drawHandle(ctx, colors.playbackHandle, PlaybackDial.HandleTypes.PlaybackEnd)
            drawHandle(ctx, colors.loopHandle, PlaybackDial.HandleTypes.LoopStart)
            drawHandle(ctx, colors.loopHandle, PlaybackDial.HandleTypes.LoopEnd)
            drawHandle(ctx, colors.rateArc, PlaybackDial.HandleTypes.RateStart)
            drawHandle(ctx, colors.rateHandle, PlaybackDial.HandleTypes.RateEnd)
        }

        function drawArc(ctx, start, end, radius, color) {
            const startAngle = toCanvasAngle(start)
            const endAngle = toCanvasAngle(end)
            ctx.beginPath();
            ctx.arc(canvasConsts.centerX,
                    canvasConsts.centerY,
                    radius,
                    startAngle,
                    endAngle)
            ctx.lineWidth = canvasConsts.arcLineWidth
            ctx.strokeStyle = color
            ctx.stroke()
        }

        function drawHandle(ctx, color, handleType) {

            const pos = getHandlePosition(handleType)
            const text = getHandleText(handleType)
            const startAngle = toCanvasAngle(0)
            const endAngle = toCanvasAngle(Constants.Numbers.twoPi)
            ctx.beginPath();
            ctx.arc(pos.x, pos.y, canvasConsts.handleArcRadius, startAngle, endAngle)
            ctx.fillStyle = color
            ctx.fill()
            ctx.fillStyle = '#ffffff'
            ctx.font = '18px arial'
            ctx.textAlign = 'center'
            ctx.textBaseline = 'middle'
            ctx.fillText(text, pos.x, pos.y)
        }

        function loopHandlesAreOverlapping() {
            return Math.abs(loopEnd - loopStart) < 0.25
        }

        // Convert the supplied angle to one which the canvas will
        // interpret as starting vertically above the center point
        function toCanvasAngle(radians) {
            return radians - (Math.PI / 2)
        }

        MouseArea {
            id: canvasMouseArea
            anchors.fill: parent
            enabled: true
            onReleased: activeHandle = PlaybackDial.HandleTypes.None
            onMouseXChanged: parent.processMouseDrag()
            onMouseYChanged: parent.processMouseDrag()
        }


        // Update the angle of the active handle. Also update the active
        // handle itself if it has changed.
        function processMouseDrag() {
            const handleTypes = determineHandlesFromPoint({
                x: canvasMouseArea.mouseX,
                y: canvasMouseArea.mouseY})
            if (activeHandle === PlaybackDial.HandleTypes.None) {
                if (handleTypes.length === 0) {
                    return
                }
                activeHandle = handleTypes[0]
            }
            const angle = calculateAngle({
                x: canvasMouseArea.mouseX,
                y: canvasMouseArea.mouseY})
            updateHandleAngle(angle, activeHandle)
        }

        function updateHandleAngle(angle, handleType) {
            if (handleType === PlaybackDial.HandleTypes.PlaybackEnd) {
                playbackEnd = angle
                playbackHandleDragged()
            } else if (handleType === PlaybackDial.HandleTypes.LoopStart) {
                loopStart = angle
                loopHandleDragged()
            } else if (handleType === PlaybackDial.HandleTypes.LoopEnd) {
                loopEnd = angle
                loopHandleDragged()
            } else if (handleType === PlaybackDial.HandleTypes.RateEnd) {
                rateEnd = angle
                rateHandleDragged()
            } else {
                console.error('ERROR: INVALID HANDLE TYPE', handleType, 'passed')
            }
        }

        // Return the clicked handleType if any. null otherwise
        function determineHandlesFromPoint(point) {
            var clickedHandles = []
            const draggableHandles = [
                       PlaybackDial.HandleTypes.PlaybackEnd,
                       PlaybackDial.HandleTypes.LoopEnd,
                       PlaybackDial.HandleTypes.LoopStart,
                       PlaybackDial.HandleTypes.RateEnd]
            for (const handleType of draggableHandles) {

                const handlePos = getHandlePosition(handleType)
                const radius = canvasConsts.handleArcRadius
                const xIsAcceptable = (point.x < handlePos.x + radius && point.x > handlePos.x - radius)
                const yIsAcceptable = (point.y < handlePos.y + radius && point.y > handlePos.y - radius)
                if (xIsAcceptable && yIsAcceptable) {
                    clickedHandles.push(handleType)
                }
            }
            return clickedHandles
        }

        function getHandlePosition(handleType) {
            var angle
            var radius
            if (handleType === PlaybackDial.HandleTypes.PlaybackStart) {
                radius = canvasConsts.baseArcRadius
                angle = playbackStart
            } else if (handleType === PlaybackDial.HandleTypes.PlaybackEnd) {
                radius = canvasConsts.baseArcRadius
                angle = playbackEnd
            } else if (handleType === PlaybackDial.HandleTypes.LoopStart) {
                radius = canvasConsts.loopArcRadius
                angle = loopStart
            } else if (handleType === PlaybackDial.HandleTypes.LoopEnd) {
                radius = canvasConsts.loopArcRadius
                angle = loopEnd
            } else if (handleType === PlaybackDial.HandleTypes.RateStart) {
                radius = canvasConsts.rateArcRadius
                angle = rateStart
            } else if (handleType === PlaybackDial.HandleTypes.RateEnd) {
                radius = canvasConsts.rateArcRadius
                angle = rateEnd
            }

            const x = canvasConsts.centerX + radius * Math.sin(angle)
            const y = canvasConsts.centerY - radius * Math.cos(angle)
            return {x: x, y: y}
        }

        function getHandleText(handleType) {
            var text = ''
            if (handleType === PlaybackDial.HandleTypes.PlaybackEnd) {
                text = 'p'
            } else if (handleType === PlaybackDial.HandleTypes.LoopStart) {
                text = 's'
            } else if (handleType === PlaybackDial.HandleTypes.LoopEnd) {
                text = 'e'
            } else if (handleType === PlaybackDial.HandleTypes.RateEnd) {
                text = 'r'
            }

            return text
        }

        // Return the angle in radians that the click makes relative to
        // the vertical center of the canvas
        function calculateAngle(point) {
            // turn x and y into cartesian coordinates with
            // canvas center as origin
            const x = point.x - canvasConsts.centerX
            const y = canvasConsts.centerY - point.y
            if (x > 0 && y < 0) {
                return (Math.PI / 2) + getAtan(y, x)
            } else if (x < 0 && y < 0) {
                return Math.PI + getAtan(x, y)
            } else if (x < 0 && y > 0) {
                return (3/2 * Math.PI)+ getAtan(y, x)
            }
            return getAtan(x, y)
        }

        function getAtan(opp, adj) {
            // Return the angle in radians of arctan of the supplied triangle lengths
            var angle = Math.atan(Math.abs(opp) / Math.abs(adj))
            return angle
        }



    }


}
