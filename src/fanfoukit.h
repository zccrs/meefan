#ifndef OAUTHFANFOU_H
#define OAUTHFANFOU_H

#include "oauth.h"

QT_BEGIN_NAMESPACE
class QNetworkAccessManager;
QT_END_NAMESPACE

class HttpRequest;
class FanfouKit : public OAuth
{
    Q_OBJECT

public:
    explicit FanfouKit(QObject *parent = 0);
    explicit FanfouKit(const QByteArray& consumerKey, const QByteArray& consumerSecret, QObject *parent = 0);

    Q_INVOKABLE HttpRequest *createHttpRequest();

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
};

#endif // OAUTHFANFOU_H
