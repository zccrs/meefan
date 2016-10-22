#ifndef OAUTHFANFOU_H
#define OAUTHFANFOU_H

#include "oauth.h"

QT_BEGIN_NAMESPACE
class QNetworkAccessManager;
QT_END_NAMESPACE

class FanfouKit : public OAuth
{
    Q_OBJECT

    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)

public:
    explicit FanfouKit(QObject *parent = 0);
    explicit FanfouKit(const QByteArray& consumerKey, const QByteArray& consumerSecret, QObject *parent = 0);
    
    QString userName() const;

public slots:
    QByteArray generateAuthorizationHeader(const QString &username, const QString &password);

    void requestAccessToken(const QString &password);
    void requestAccessToken(const QString &username, const QString &password);
    void setUserName(QString arg);

signals:
    void userNameChanged(QString arg);
    void requestAccessTokenFinished(QByteArray token, QByteArray secret);
    void requestAccessTokenError(QString error);

private slots:
    void onRequestAccessToken();

private:
    QString m_userName;
    QNetworkAccessManager *m_accessManager;
};

#endif // OAUTHFANFOU_H
