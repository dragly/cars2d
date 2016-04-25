import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

ApplicationWindow {
    title: qsTr("Hello World")
    width: 1600
    height: 1200
    visible: true

//    Flickable {
//        anchors.fill: parent
//        boundsBehavior: Flickable.DragOverBounds
//        contentHeight: 10000
//        contentWidth: 10000
        Game {
        }
//    }
}
