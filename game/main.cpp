#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QDir>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qDebug() << QDir::currentPath();

    QQmlApplicationEngine engine;
    engine.addImportPath("../box2d");
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
