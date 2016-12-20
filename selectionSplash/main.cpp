#include <QCoreApplication>
#include <QProcess>
#include <QDate>
#include <QDesktopServices>
#include <QDir>
#include <QDebug>

#define SPLASH_PATH QDesktopServices::storageLocation(QDesktopServices::CacheLocation) + QDir::separator() +  "splash" + QDir::separator()

int main(int argv, char *argc[])
{
    QCoreApplication *app = new QCoreApplication(argv, argc);

    app->setApplicationName("meefan");
    app->setApplicationVersion("0.0.1");
    app->setOrganizationName("zccrs");

    QProcess process;
    QObject::connect(&process, SIGNAL(finished(int)), app, SLOT(quit()));

    const QString splashFilePath = SPLASH_PATH + QDate::currentDate().toString("yyyyMMdd.jpg");

    qDebug() << "splashFilePath:" << splashFilePath;

    if (QFile::exists(splashFilePath)) {
        process.start(QString("/usr/bin/invoker --splash %1 --type=d -s /opt/meefan/bin/meefan").arg(splashFilePath));
    } else {
        process.start("/usr/bin/invoker --splash /opt/meefan/data/splash.png --type=d -s /opt/meefan/bin/meefan");
    }

    return app->exec();
}
