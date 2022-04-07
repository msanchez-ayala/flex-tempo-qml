import QtQuick
import QtQuick.Controls.Material

Item {
    id: playbackDial

    enum HandleTypes {
        None,
        LoopStart,
        LoopEnd,
        PlaybackStart,
        PlaybackEnd,
        RateStart,
        RateEnd
    }

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

    readonly property real twoPi: 2 * Math.PI
    readonly property int canvasMargin: 40
    readonly property int arcLineWidth: 40
    readonly property var loopHandles: [PlaybackDial.HandleTypes.LoopStart, PlaybackDial.HandleTypes.LoopEnd]
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

    onPlaybackFractionChanged: playbackEnd = playbackFraction * 2 * Math.PI
    onPlaybackEndChanged: canvas.requestPaint()
    onLoopStartChanged: canvas.requestPaint()
    onLoopEndChanged: canvas.requestPaint()
    onRateEndChanged: canvas.requestPaint()

    function incrementValue(value) {
        const rads = Math.PI / 4
        if (value >= 2 * Math.PI) {
            return rads
        } else {
            return value += rads
        }
    }
    Rectangle {
        anchors.fill: playbackDial
        color: 'transparent'
        border.color: 'red'
    }


    Canvas {
        id: canvas
        width: playbackDial.width - (2 * playbackDial.canvasMargin)
        height: Math.min(width, playbackDial.height - (2 * playbackDial.canvasMargin))
        anchors.centerIn: parent

        readonly property real centerX: width/2
        readonly property real centerY: height/2
        readonly property real baseArcRadius: (Math.min(width, height) - arcLineWidth)/2
        readonly property real loopArcRadius: baseArcRadius - arcLineWidth
        readonly property real rateArcRadius: loopArcRadius - arcLineWidth
        readonly property real handleArcRadius: arcLineWidth/2



        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            drawArc(ctx, playbackStart, twoPi, baseArcRadius, colors.baseArc)
            drawArc(ctx, playbackStart, playbackEnd, baseArcRadius, colors.playbackArc)
            drawArc(ctx, loopStart, loopEnd, loopArcRadius, colors.loopArc)
            drawArc(ctx, rateStart, rateEnd, rateArcRadius, colors.rateArc)
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
            ctx.arc(centerX,
                    centerY,
                    radius,
                    startAngle,
                    endAngle)
            ctx.lineWidth = arcLineWidth
            ctx.strokeStyle = color
            ctx.stroke()
        }

        function drawHandle(ctx, color, handleType) {

            const pos = getHandlePosition(handleType)
            const text = getHandleText(handleType)
            const startAngle = toCanvasAngle(0)
            const endAngle = toCanvasAngle(2*Math.PI)
            ctx.beginPath();
            ctx.arc(pos.x,
                    pos.y,
                    handleArcRadius,
                    startAngle,
                    endAngle)
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
                 const xIsAcceptable = (point.x < handlePos.x + handleArcRadius && point.x > handlePos.x - handleArcRadius)
                 const yIsAcceptable = (point.y < handlePos.y + handleArcRadius && point.y > handlePos.y - handleArcRadius)
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
                radius = baseArcRadius
                angle = playbackStart
            } else if (handleType === PlaybackDial.HandleTypes.PlaybackEnd) {
                radius = baseArcRadius
                angle = playbackEnd
            } else if (handleType === PlaybackDial.HandleTypes.LoopStart) {
                radius = loopArcRadius
                angle = loopStart
            } else if (handleType === PlaybackDial.HandleTypes.LoopEnd) {
                radius = loopArcRadius
                angle = loopEnd
            } else if (handleType === PlaybackDial.HandleTypes.RateStart) {
                radius = rateArcRadius
                angle = rateStart
            } else if (handleType === PlaybackDial.HandleTypes.RateEnd) {
                radius = rateArcRadius
                angle = rateEnd
            }

            const x = centerX + radius * Math.sin(angle)
            const y = centerY - radius * Math.cos(angle)
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
            const x = point.x - centerX
            const y = centerY - point.y
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
