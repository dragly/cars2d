import QtQuick 2.0
import Box2D 2.0

PhysicsItem  {
    id: box
    width: 32
    height: 32
    bodyType: Body.Dynamic
    linearDamping: 1
    angularDamping: 1
    fixtures: Box {
        width: box.width
        height: box.height
        density: 10
        friction: 10
        restitution: 0.01
    }
    Rectangle {
        anchors.fill: parent
        color: "yellow"
    }
}

