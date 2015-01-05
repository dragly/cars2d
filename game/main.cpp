#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QDir>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qDebug() << QDir::currentPath();

    QQmlApplicationEngine engine;
    engine.addImportPath("/home/svenni/apps/qt/qml-box2d/build-box2d-Desktop_Qt_5_4_0_GCC_64bit-Release");
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
