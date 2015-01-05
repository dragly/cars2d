import QtQuick 2.0
import Box2D 2.0

Rectangle {
    id: root
    width: 10000
    height: 10000

    MouseArea {
        anchors.fill: parent
        onClicked: {
            var component = Qt.createComponent("Box.qml")
            var box = component.createObject(root, {x: mouse.x - 16, y: mouse.y - 16})
        }
    }

    World {
        id: physicsWorld
        gravity: Qt.point(0, 0)
        onStepped: {
            car.stepped()
            car2.stepped()
            car3.stepped()
            car4.stepped()
//            car5.stepped()
//            car6.stepped()
//            car7.stepped()
//            car8.stepped()
        }
    }

    Car {
        id: car
        hull.x: 500
        hull.y: 500
        focus: true
        autopilot: false
    }

    Car {
        id: car2

        focus: false
        forward: true
        hull.x: 700
        hull.y: 700
    }

    Car {
        id: car3
        focus: false
        forward: true
        hull.x: 100
        hull.y: 100
    }

    Car {
        id: car4
        focus: false
        forward: true
        hull.x: 300
        hull.y: 100
    }

//    Car {
//        id: car5
//        focus: false
//        forward: true
//        hull.x: 500
//        hull.y: 100
//    }

//    Car {
//        id: car6
//        focus: false
//        forward: true
//        hull.x: 100
//        hull.y: 300
//    }

//    Car {
//        id: car7
//        focus: false
//        forward: true
//        hull.x: 300
//        hull.y: 300
//    }

//    Car {
//        id: car8
//        focus: false
//        forward: true
//        hull.x: 500
//        hull.y: 300
//    }

    Rectangle {
        id: button
        x: 10
        y: 10
        width: 100
        height: 40
        color: "#DEDEDE"
        border.color: "#999"
        radius: 5
        Text {
            id: title
            text: debugDraw.visible ? "Debug view: on" : "Debug view: off"
            anchors.centerIn: parent
            anchors.margins: 5
        }
        MouseArea {
            anchors.fill: parent
            onClicked: debugDraw.visible = !debugDraw.visible;
        }
    }

    DebugDraw {
        id: debugDraw
        world: physicsWorld
        visible: false
    }
}

