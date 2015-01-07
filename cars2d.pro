TEMPLATE = subdirs
CONFIG += ordered
SUBDIRS += box2d
SUBDIRS += game

game.depends = box2d
