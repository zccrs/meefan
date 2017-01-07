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

    QString splashFilePath = SPLASH_PATH + QDate::currentDate().toString("yyyyMMdd.jpg");

    qDebug() << "splashFilePath:" << splashFilePath;
    qDebug() << "argc:" << app->arguments();

    QStringList args = app->arguments();

    if (!args.isEmpty())
        args.removeFirst();

    QString command = "/usr/bin/invoker --splash %1 --type=d -s /opt/meefan/bin/meefan %2";

    if (!QFile::exists(splashFilePath)) {
        splashFilePath = "/opt/meefan/data/splash.png";
    }

    command = command.arg(splashFilePath).arg(args.join(" "));
    process.start(command);

    qDebug() << "command:" << command;

    if (process.error() == QProcess::UnknownError)
        return app->exec();
    else
        qDebug() << process.errorString();

    qDebug() << process.readAllStandardError();
}
