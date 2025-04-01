#include <QGuiApplication>
#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QtQuick>
#include <QDebug>
#include <windows.h>
#include <winuser.h>
#include "qmlserial.h"
#include "qmlregister.h"
#include "qmlfileopt.h"
void initItem()
{
    qmlRegisterType<QmlFileOpt>("qmlcpplib.qmlfileopt", 1, 0, "QmlFileOpt");
    qmlRegisterType<QmlSystem>("qmlcpplib.qmlsystem", 1, 0, "QmlSystem");
    qmlRegisterType<QmlSerial>("qmlcpplib.qmlserial", 1, 0, "QmlSerial");
}

static void loadDummyDataFiles(QQmlEngine &engine, const QString &directory)
{
    QDir dir(directory + "/dummydata", "*.qml");
    QStringList list = dir.entryList();
    for (int i = 0; i < list.size(); ++i)
    {
        QString qml = list.at(i);
        QQmlComponent comp(&engine, dir.filePath(qml));
        QObject *dummyData = comp.create();

        if (comp.isError())
        {
            const QList<QQmlError> errors = comp.errors();
            for (const QQmlError &error : errors)
                fprintf(stderr, "%s\n", qPrintable(error.toString()));
        }

        if (dummyData)
        {
            fprintf(stderr, "Loaded dummy data: %s\n", qPrintable(dir.filePath(qml)));
            qml.truncate(qml.length() - 4);
            engine.rootContext()->setContextProperty(qml, dummyData);
            dummyData->setParent(&engine);
        }
    }
}
#include <QLocalSocket>
#include <QLocalServer>
int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    ShowWindow(GetConsoleWindow(), SW_MINIMIZE);
    // QQuickWindow::setSceneGraphBackend(QSGRendererInterface::OpenGLRhi);
    QGuiApplication app(argc, argv);
    {
        QLocalSocket local;
        local.connectToServer(u8"software.exe.yongjie");
        if (local.waitForConnected(10))
        {
            return 0;
        }
    }
    QThreadPool::globalInstance()->setMaxThreadCount(50);
    QLocalServer server;
    server.listen(u8"software.exe.yongjie");
    QCoreApplication::setOrganizationName(u8"DetectionUtils");
    QCoreApplication::setOrganizationDomain(u8"weilixin-motor.com");
    QCoreApplication::setApplicationName(u8"weilixin");
    QQmlApplicationEngine engine;

    // 添加引用qrc:/dummydata
    // 添加全局变量 isNotQmlsence 到 QML 引擎上下文
    engine.rootContext()->setContextProperty("isNotQmlsence", true);
    initItem();
    loadDummyDataFiles(engine, ":");
    engine.load(QUrl(QStringLiteral("qrc:/App.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    qDebug() << __FUNCTION__ << __LINE__;

    return app.exec();
}
