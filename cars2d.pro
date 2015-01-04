TEMPLATE = subdirs
CONFIG += ordered
SUBDIRS += box2d game

game.depends = box2d
