TEMPLATE = subdirs
CONFIG += ordered
SUBDIRS += qml-box2d game

game.depends = box2d
