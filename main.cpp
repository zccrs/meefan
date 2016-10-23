#include <QtGui/QApplication>
#include <QDeclarativeContext>
#include <qdeclarative.h>
#include <QNetworkProxy>

#include "qmlapplicationviewer.h"
#include "fanfoukit.h"
#include "httprequest.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    app->setApplicationName("meefan");
    app->setApplicationVersion("1.0.0");
    app->setOrganizationName("zccrs");

#ifdef ENABLE_PROXY
    QNetworkProxy proxy;
    proxy.setType(QNetworkProxy::HttpProxy);
    proxy.setHostName("localhost");
    proxy.setPort(8888);
    QNetworkProxy::setApplicationProxy(proxy);
#endif

    qmlRegisterUncreatableType<OAuth>("com.zccrs.meefan", 1, 0, "OAuth", "Can't touch this");
    qmlRegisterType<HttpRequest>("com.zccrs.meefan", 1, 0, "HttpRequest");

    QmlApplicationViewer viewer;

    viewer.rootContext()->setContextProperty("ffkit", new FanfouKit(&viewer));
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);
    viewer.setMainQmlFile(QLatin1String("qml/meefan/main.qml"));
    viewer.showExpanded();

    return app->exec();
}
