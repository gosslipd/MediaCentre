// src/main.cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "WebcamHandler.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
	
    qmlRegisterType<WebcamHandler>("MediaCentre", 1, 0, "WebcamHandler");
	
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/MediaCentre/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
	
    return app.exec();
}
