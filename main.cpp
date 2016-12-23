#include <QtGui/QApplication>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <qdeclarative.h>
#include <QNetworkProxy>
#include <QGraphicsBlurEffect>
#include <QTranslator>
#include <QtWebKit/QWebSettings>

#include "qmlapplicationviewer.h"
#include "fanfoukit.h"
#include "httprequest.h"
#include "myimage.h"
#include "monitormouseevent.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    app->setApplicationName("meefan");
    app->setApplicationVersion("0.0.2");
    app->setOrganizationName("zccrs");

    QTranslator translator;

    if (translator.load(QString(":/%1_%2").arg(app->applicationName()).arg(QLocale::system().name()))) {
        app->installTranslator(&translator);
    }

#ifdef ENABLE_PROXY
    QNetworkProxy proxy;
    proxy.setType(QNetworkProxy::HttpProxy);
    proxy.setHostName("localhost");
    proxy.setPort(8888);
    QNetworkProxy::setApplicationProxy(proxy);
#endif

    QWebSettings::globalSettings()->setUserStyleSheetUrl(QUrl::fromLocalFile(QML_ROOT_PATH"zhihu/css/default.css"));

    qmlRegisterUncreatableType<OAuth>("com.zccrs.meefan", 1, 0, "OAuth", "Can't touch this");
    qmlRegisterType<HttpRequest>("com.zccrs.meefan", 1, 0, "HttpRequest");
    qmlRegisterType<MyImage>("com.zccrs.meefan", 1, 0, "MaskImage");
    qmlRegisterType<QGraphicsBlurEffect>("com.zccrs.meefan", 1, 0, "BlurEffect");
    qmlRegisterType<MonitorMouseEvent>("com.zccrs.meefan", 1, 0, "MonitorMouseEvent");

    QmlApplicationViewer viewer;

    viewer.rootContext()->setContextProperty("ffkit", new FanfouKit(viewer.engine()->networkAccessManager(), &viewer));
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);
    viewer.setMainQmlFile(QLatin1String("qml/meefan/main.qml"));
    viewer.showExpanded();

    return app->exec();
}
