#include <QtGui/QApplication>
#include <QDeclarativeContext>
#include <QNetworkProxy>

#include "qmlapplicationviewer.h"
#include "fanfoukit.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

#ifdef ENABLE_PROXY
    QNetworkProxy proxy;
    proxy.setType(QNetworkProxy::HttpProxy);
    proxy.setHostName("localhost");
    proxy.setPort(8888);
    QNetworkProxy::setApplicationProxy(proxy);
#endif

    QmlApplicationViewer viewer;

    viewer.rootContext()->setContextProperty("ffkit", new FanfouKit(&viewer));
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);
    viewer.setMainQmlFile(QLatin1String("qml/meefan/main.qml"));
    viewer.showExpanded();

    return app->exec();
}
