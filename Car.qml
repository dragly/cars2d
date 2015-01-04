import QtQuick 2.0
import Box2D 2.0

Item {

    property bool autopilot: true

    property var tires: [frontLeftTire, frontRightTire, backLeftTire, backRightTire]
    property var controllableTires: [frontLeftTire, frontRightTire]
    //        property var forceTires: [backLeftTire, backRightTire]
            property var forceTires: [frontLeftTire, frontRightTire]
//    property var forceTires: [frontLeftTire, frontRightTire, backLeftTire, backRightTire]

    property bool forward: false
    property bool backward: false
    property bool steeringLeft: false
    property bool steeringRight: false

    property real targetTireAngle: 0

    property var path: [
        Qt.vector2d(100,100),
        Qt.vector2d(100,1000),
        Qt.vector2d(1000,1000),
        Qt.vector2d(1000,100)
    ]
    property int currentPathIndex: 0

    signal stepped

    property alias hull: hull

//    property point lineStart
//    property point lineEnd

    function wrappedPathIndex(index) {
        var result = index
        while(result < 0) {
            result += path.length
        }
        result = result % path.length
        return result
    }

    onStepped: {
        var lineStart = path[wrappedPathIndex(currentPathIndex)]
        var lineEnd = path[wrappedPathIndex(currentPathIndex + 1)]

        lineStartRect.x = lineStart.x
        lineStartRect.y = lineStart.y

        lineEndRect.x = lineEnd.x
        lineEndRect.y = lineEnd.y

        if(!autopilot) {
            targetTireAngle = 0
            if(steeringLeft) {
                targetTireAngle = -90
            }
            if(steeringRight) {
                targetTireAngle = 90
            }
        }

        for(var i in tires) {
            var tire = tires[i]

            var x = Math.cos(tire.rotation*Math.PI/180 + Math.PI / 2)
            var y = Math.sin(tire.rotation*Math.PI/180 + Math.PI / 2)
            var currentRightNormal = Qt.vector2d(x, y)
            var linearVelocity = Qt.vector2d(tire.linearVelocity.x, tire.linearVelocity.y)
            var linearVelocityMagnitude = linearVelocity.length()
            var dot = currentRightNormal.dotProduct(linearVelocity)
            var lateralVelocity = currentRightNormal.times(dot)

            var impulseFactor = 1.0 * (tire.body.getMass() + hull.body.getMass() / 64)
            if(linearVelocityMagnitude > 20) {
                impulseFactor /= 0.05 * linearVelocityMagnitude
            }
            var impulse = lateralVelocity.times(-impulseFactor)
            impulse = Qt.point(impulse.x, impulse.y)
            var tireCenter = Qt.point(tire.width / 2, tire.height / 2)
            tire.body.applyLinearImpulse(impulse, tire.body.toWorldPoint(tireCenter))
            //            tire.body.applyForceToCenter(impulse)
        }
        for(var i in forceTires) {
            var tire = forceTires[i]
            var linearVelocity = Qt.vector2d(tire.linearVelocity.x, tire.linearVelocity.y)
            var linearVelocityMagnitude = linearVelocity.length()
//            if(linearVelocityMagnitude > 10 && autopilot) {
//                continue
//            }
            if(forward || backward) {
                var x = Math.cos(tire.rotation*Math.PI/180) * 5 * tire.body.getMass()
                var y = Math.sin(tire.rotation*Math.PI/180) * 5 * tire.body.getMass()
                if(backward) {
                    x *= -1
                    y *= -1
                }

                tire.body.applyLinearImpulse(Qt.point(x, y), tire.body.toWorldPoint(tireCenter))
            }
        }

        for(var i in controllableTires) {
            var tire = controllableTires[i]
            var DEGTORAD = 1.0
            var lockAngle = 25 * DEGTORAD
            var lowerLockAngle = -lockAngle
            var upperLockAngle = lockAngle
            var turnSpeedPerSec = 120 * DEGTORAD;
            var turnPerTimeStep = turnSpeedPerSec / 60.0;
            var desiredAngle = 0;
            desiredAngle = Math.min(Math.max(targetTireAngle, lowerLockAngle), upperLockAngle)
            var angleNow = frontLeftJoint.getJointAngle()
            var angleToTurn = desiredAngle - angleNow;
            angleToTurn = Math.min(Math.max(angleToTurn, -turnPerTimeStep), turnPerTimeStep)
            var newAngle = angleNow + angleToTurn
            frontLeftJoint.setLimits(newAngle, newAngle)
            frontRightJoint.setLimits(newAngle, newAngle)
        }

        var x0 = hull.body.toWorldPoint(Qt.point(hull.width / 2, hull.height / 2)).x
        var y0 = hull.body.toWorldPoint(Qt.point(hull.width / 2, hull.height / 2)).y

        var x1 = lineStart.x - x0
        var y1 = lineStart.y - y0
        var x2 = lineEnd.x - x0
        var y2 = lineEnd.y - y0
        var dx = x2 - x1
        var dy = y2 - y1
        var dr = Math.sqrt(dx*dx + dy*dy)
        var D = x1*y2 - x2*y1
        var sign = dy > 0 ? 1 : -1
        var r = 300

        var discriminant = r*r*dr*dr-D*D
        if(discriminant >= 0) {
            var targetX1 = (D*dy + sign * dx * Math.sqrt(discriminant)) / (dr*dr)
            var targetY1 = (-D*dx + Math.abs(dy) * Math.sqrt(discriminant)) / (dr*dr)
            var targetX2 = (D*dy - sign * dx * Math.sqrt(discriminant)) / (dr*dr)
            var targetY2 = (-D*dx - Math.abs(dy) * Math.sqrt(discriminant)) / (dr*dr)
            var measure1 = Qt.vector2d(targetX1 + x0 - lineEnd.x, targetY1 + y0 - lineEnd.y)
            var measure2 = Qt.vector2d(targetX2 + x0 - lineEnd.x, targetY2 + y0 - lineEnd.y)
            if(measure1.length() < measure2.length()) {
                target.x = targetX1 + x0
                target.y = targetY1 + y0
            } else {
                target.x = targetX2 + x0
                target.y = targetY2 + y0
            }
        } else {
            // find nearest point

            var testPoint = Qt.vector2d(x0, y0)
            var pt1 = Qt.vector2d(lineStart.x, lineStart.y)
            var pt2 = Qt.vector2d(lineEnd.x, lineEnd.y)
            var u = pt1.minus(pt2).normalized()
            var A = testPoint.minus(pt1)
            var result = pt1.plus(u.times(A.dotProduct(u)))
            target.x = result.x
            target.y = result.y
        }

        if(autopilot) {
            var diffX = x0 - target.x
            var diffY = y0 - target.y
            var targetAngle = Math.atan2(diffY, diffX) * 180 / Math.PI
            if(!isNaN(targetAngle)) {
                var angle = hull.rotation
                var netAngle = (angle - targetAngle)
                if(netAngle < 0) {
                    var factor = Math.round(-netAngle / 360) + 1
                    netAngle += factor * 360
                }
                netAngle = netAngle % 360
                netAngle -= 180
                targetTireAngle = -netAngle
            }
        }

        // Check distance to endPoint
        var position = Qt.vector2d(x0, y0)
        var measure = position.minus(lineEnd)
        if(measure.length() < r) {
            currentPathIndex = wrappedPathIndex(currentPathIndex + 1)
        }
    }

    PhysicsItem {
        id: hull
        width: 100
        height: 50

        bodyType: Body.Dynamic

        fixtures: Box {
            width: hull.width
            height: hull.height
            density: 50
        }

        Rectangle {
            anchors.fill: parent
            color: "blue"
            smooth: true
            antialiasing: true
        }

//        Rectangle {
//            anchors.centerIn: parent
//            radius: 200
//            width: 400
//            height: width
//            color: "#AA0000AA"
//            z: -999999
//        }
    }

    RevoluteJoint {
        id: frontLeftJoint
        bodyA: hull.body
        bodyB: frontLeftTire.body
        localAnchorA: Qt.point(hull.width - frontLeftTire.width,  frontLeftTire.height / 2)
        localAnchorB: Qt.point(frontLeftTire.width / 2, frontLeftTire.height / 2)
        enableLimit: true
    }

    RevoluteJoint {
        id: frontRightJoint
        bodyA: hull.body
        bodyB: frontRightTire.body
        localAnchorA: Qt.point(hull.width - frontLeftTire.width, hull.height - frontLeftTire.height / 2)
        localAnchorB: Qt.point(frontRightTire.width / 2, frontRightTire.height / 2)
        enableLimit: true
    }

    RevoluteJoint {
        bodyA: hull.body
        bodyB: backLeftTire.body
        localAnchorA: Qt.point(frontLeftTire.width, frontLeftTire.height / 2)
        localAnchorB: Qt.point(backLeftTire.width / 2, backLeftTire.height / 2)
        enableLimit: true
    }

    RevoluteJoint {
        bodyA: hull.body
        bodyB: backRightTire.body
        localAnchorA: Qt.point(frontLeftTire.width, hull.height - frontLeftTire.height / 2)
        localAnchorB: Qt.point(backRightTire.width / 2, backRightTire.height / 2)
        enableLimit: true
    }

    PhysicsItem {
        id: frontLeftTire
        width: 20
        height: 10

        //        transformOrigin: Item.Center
        bodyType: Body.Dynamic
        //        rotation: 90

        fixtures: Box {
            width: frontLeftTire.width
            height: frontLeftTire.height
            density: 10
            //            friction: 10
            //            restitution: 0.1
        }

        Rectangle {
            anchors.fill: parent
            color: "red"
            smooth: true
            antialiasing: true
        }
    }

    PhysicsItem {
        id: frontRightTire
        width: 20
        height: 10

        //        transformOrigin: Item.Center
        bodyType: Body.Dynamic
        //        rotation: 90

        fixtures: Box {
            width: frontRightTire.width
            height: frontRightTire.height
            density: 10
            //            friction: 10
            //            restitution: 0.1
        }

        Rectangle {
            anchors.fill: parent
            color: "red"
            smooth: true
            antialiasing: true
        }
    }

    PhysicsItem {
        id: backRightTire
        width: 20
        height: 10

        //        transformOrigin: Item.Center
        bodyType: Body.Dynamic
        //        rotation: 90

        fixtures: Box {
            width: backRightTire.width
            height: backRightTire.height
            density: 10
            //            friction: 10
            //            restitution: 0.1
        }

        Rectangle {
            anchors.fill: parent
            color: "red"
            smooth: true
            antialiasing: true
        }
    }

    PhysicsItem {
        id: backLeftTire
        width: 20
        height: 10

        //        transformOrigin: Item.Center
        bodyType: Body.Dynamic
        //        rotation: 90

        fixtures: Box {
            width: backLeftTire.width
            height: backLeftTire.height
            density: 10
            //            friction: 10
            //            restitution: 0.1
        }

        Rectangle {
            anchors.fill: parent
            color: "red"
            smooth: true
            antialiasing: true
        }
    }



    Keys.onPressed: {
        if(event.key === Qt.Key_W) {
            forward = true
        }
        if(event.key === Qt.Key_S) {
            backward = true
        }
        if(event.key === Qt.Key_A) {
            steeringLeft = true
        }
        if(event.key === Qt.Key_D) {
            steeringRight = true
        }
    }

    Keys.onReleased: {
        if(event.key === Qt.Key_W) {
            forward = false
        }
        if(event.key === Qt.Key_S) {
            backward = false
        }
        if(event.key === Qt.Key_A) {
            steeringLeft = false
        }
        if(event.key === Qt.Key_D) {
            steeringRight = false
        }
    }

    Rectangle {
        id: target
        color: "red"
        width: 10
        height: width
    }

    Rectangle {
        id: lineStartRect
        color: "green"
        width: 10
        height: width
    }

    Rectangle {
        id: lineEndRect
        color: "blue"
        width: 10
        height: width
    }
}

