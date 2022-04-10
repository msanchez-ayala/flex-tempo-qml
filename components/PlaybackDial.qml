import QtQuick
import QtQuick.Controls.Material
import "../Constants.js" as Constants

// Glossary
//
// "max" : The maximum allowed value for a given attribute
// "pos" : The current position of an attribute that is less than the maximum allowed value
//


// A component containing a canvas element to draw a playback dial that contains three interactive
// arcs: one for playback, one for looping, and one for playback rate.
Item {
    id: root

    // Playback and loop values in ms
    required property real playbackMax
    required property real playbackPos
    required property real loopStartPos
    required property real loopEndPos
    // Fractional value
    required property real rateMax
    required property real ratePos

    enum HandleTypes {
        None,
        LoopStart,
        LoopEnd,
        PlaybackStart,
        PlaybackEnd,
        RateStart,
        RateEnd
    }

    signal playbackHandleDragged(real newPos)
    signal rateHandleDragged(real newPos)
    signal loopStartHandleDragged(real newPos)
    signal loopEndHandleDragged(real newPos)



    onPlaybackPosChanged: canvas.requestPaint()
    onLoopStartPosChanged: canvas.requestPaint()
    onLoopEndPosChanged: canvas.requestPaint()
    onRatePosChanged: canvas.requestPaint()

//    Rectangle {
//        id: debugRect
//        anchors.fill: root
//        border.color: 'red'
//    }

    Canvas {
        id: canvas

        property int activeHandle: PlaybackDial.HandleTypes.None

        QtObject {
            id: geometry
            readonly property real centerX: root.width/2
            readonly property real centerY: root.height/2
            readonly property int arcLineWidth: 0.15 * Math.min(root.width, root.height)
            readonly property real playbackArcRadius: (Math.min(width, height) - arcLineWidth)/2
            readonly property real loopArcRadius: playbackArcRadius - arcLineWidth
            readonly property real rateArcRadius: loopArcRadius - arcLineWidth
            readonly property real handleArcRadius: arcLineWidth/2
            readonly property real textSize: handleArcRadius * 0.8
        }

        QtObject {
            id: angles
            property real playbackStart: 0
            property real playbackEnd: canvas.angleFromFraction(root.playbackPos / root.playbackMax)
            property real loopStart: canvas.angleFromFraction(root.loopStartPos / root.playbackMax)
            property real loopEnd: canvas.angleFromFraction(root.loopEndPos / root.playbackMax)
            property real rateStart: 0
            property real rateEnd: canvas.angleFromFraction(root.ratePos / root.rateMax)
        }

        QtObject {
            id: colors
            readonly property color playbackArcBg: Material.color(Material.Indigo, Material.Shade50)
            readonly property color playbackArc: Material.color(Material.Indigo, Material.Shade300)
            readonly property color playbackHandle: Material.color(Material.Indigo, Material.Shade700)

            readonly property color loopArcBg: Material.color(Material.Green, Material.Shade100)
            readonly property color loopArc: Material.color(Material.Green, Material.Shade300)
            readonly property color loopHandle: Material.color(Material.Green, Material.Shade700)

            readonly property color rateArcBg: Material.color(Material.Orange, Material.Shade50)
            readonly property color rateArc: Material.color(Material.Orange, Material.Shade200)
            readonly property color rateHandle: Material.color(Material.Orange, Material.Shade700)
        }

        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            // Background arcs
            drawArc(ctx, angles.playbackStart, Constants.Numbers.twoPi, geometry.playbackArcRadius, colors.playbackArcBg)
            drawArc(ctx, angles.playbackStart, Constants.Numbers.twoPi, geometry.loopArcRadius, colors.loopArcBg)
            drawArc(ctx, angles.rateStart, Constants.Numbers.twoPi, geometry.rateArcRadius, colors.rateArcBg)

            if ([angles.playbackEnd, angles.loopStart, angles.loopEnd, angles.rateEnd].some(isNaN)) {
                return
            }

            // Filled arcs
            drawArc(ctx, angles.playbackStart, angles.playbackEnd, geometry.playbackArcRadius, colors.playbackArc)
            drawArc(ctx, angles.loopStart, angles.loopEnd, geometry.loopArcRadius, colors.loopArc)
            drawArc(ctx, angles.rateStart, angles.rateEnd, geometry.rateArcRadius, colors.rateArc)

            // Handles
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
            ctx.arc(geometry.centerX,
                    geometry.centerY,
                    radius,
                    startAngle,
                    endAngle)
            ctx.lineWidth = geometry.arcLineWidth
            ctx.strokeStyle = color
            ctx.stroke()
        }

        function drawHandle(ctx, color, handleType) {

            const pos = getHandlePosition(handleType)
            const text = getHandleText(handleType)
            const startAngle = toCanvasAngle(0)
            const endAngle = toCanvasAngle(Constants.Numbers.twoPi)
            ctx.beginPath();
            ctx.arc(pos.x, pos.y, geometry.handleArcRadius, startAngle, endAngle)
            ctx.fillStyle = color
            ctx.fill()
            ctx.fillStyle = '#ffffff'

            ctx.font = geometry.textSize.toString() + 'px arial'
            ctx.textAlign = 'center'
            ctx.textBaseline = 'middle'
            ctx.fillText(text, pos.x, pos.y)
        }

        function loopHandlesAreOverlapping() {
            return Math.abs(angles.loopEnd - angles.loopStart) < 0.25
        }

        // Convert the supplied angle to one which the canvas will
        // interpret as starting vertically above the center point
        function toCanvasAngle(radians) {
            return radians - (Math.PI / 2)
        }

        function angleFromFraction(fraction) {
            return fraction * Constants.Numbers.twoPi
        }

        function fractionFromAngle(angle) {
            return angle / Constants.Numbers.twoPi
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
            emitHandleDragged(angle, activeHandle)
        }

        function emitHandleDragged(angle, handleType) {
            const fraction = fractionFromAngle(angle)
            var newPos = fraction * root.playbackMax
            if (handleType === PlaybackDial.HandleTypes.PlaybackEnd) {
                playbackHandleDragged(newPos)
            } else if (handleType === PlaybackDial.HandleTypes.LoopStart) {
                loopStartHandleDragged(newPos)
            } else if (handleType === PlaybackDial.HandleTypes.LoopEnd) {
                loopEndHandleDragged(newPos)
            } else if (handleType === PlaybackDial.HandleTypes.RateEnd) {
                newPos = fraction * root.rateMax
                rateHandleDragged(newPos)
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
                const radius = geometry.handleArcRadius
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
                radius = geometry.playbackArcRadius
                angle = angles.playbackStart
            } else if (handleType === PlaybackDial.HandleTypes.PlaybackEnd) {
                radius = geometry.playbackArcRadius
                angle = angles.playbackEnd
            } else if (handleType === PlaybackDial.HandleTypes.LoopStart) {
                radius = geometry.loopArcRadius
                angle = angles.loopStart
            } else if (handleType === PlaybackDial.HandleTypes.LoopEnd) {
                radius = geometry.loopArcRadius
                angle = angles.loopEnd
            } else if (handleType === PlaybackDial.HandleTypes.RateStart) {
                radius = geometry.rateArcRadius
                angle = angles.rateStart
            } else if (handleType === PlaybackDial.HandleTypes.RateEnd) {
                radius = geometry.rateArcRadius
                angle = angles.rateEnd
            }

            const x = geometry.centerX + radius * Math.sin(angle)
            const y = geometry.centerY - radius * Math.cos(angle)
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

        function removeActiveHandle() {
            canvas.activeHandle = PlaybackDial.HandleTypes.None
        }

        // Return the angle in radians that the click makes relative to
        // the vertical center of the canvas
        function calculateAngle(point) {
            // turn x and y into cartesian coordinates with
            // canvas center as origin
            const x = point.x - geometry.centerX
            const y = geometry.centerY - point.y
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

        MouseArea {
            id: canvasMouseArea
            anchors.fill: canvas
            enabled: true
            onReleased: canvas.removeActiveHandle()
            onExited: canvas.removeActiveHandle()
            onMouseXChanged: parent.processMouseDrag()
            onMouseYChanged: parent.processMouseDrag()
        }



    }


}
