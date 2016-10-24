#ifndef OAUTHFANFOU_H
#define OAUTHFANFOU_H

#include "oauth.h"

#include <QScriptValue>

QT_BEGIN_NAMESPACE
class QNetworkAccessManager;
QT_END_NAMESPACE

class HttpRequest;
class FanfouKit : public OAuth
{
    Q_OBJECT

public:
    explicit FanfouKit(QObject *parent = 0);
    explicit FanfouKit(QNetworkAccessManager *manager, QObject *parent = 0);
    explicit FanfouKit(const QByteArray& consumerKey, const QByteArray& consumerSecret, QObject *parent = 0);

    Q_INVOKABLE HttpRequest *httpRequest(const QScriptValue &onreadystatechange = QScriptValue());

public slots:
    QByteArray generateXAuthorizationHeader(const QString &username, const QString &password);

    void requestAccessToken(const QString &username, const QString &password);

signals:
    void requestAccessTokenFinished();
    void requestAccessTokenError(QString error);

private slots:
    void onRequestAccessToken();

private:
    QNetworkAccessManager *m_accessManager;
    HttpRequest *m_httpRequest;
};

#endif // OAUTHFANFOU_H
