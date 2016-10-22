#include "oauthfanfou.h"

#include <QPair>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QRegExp>
#include <QStringList>
#include <QDebug>

#define ACCESS_TOKEN_URL "http://fanfou.com/oauth/access_token"

OAuthFanfou::OAuthFanfou(QObject *parent)
    : OAuth(parent)
    , m_accessManager(new QNetworkAccessManager(this))
{
}

OAuthFanfou::OAuthFanfou(const QByteArray &consumerKey, const QByteArray &consumerSecret, QObject *parent)
    : OAuth(consumerKey, consumerSecret, parent)
    , m_accessManager(new QNetworkAccessManager(this))
{
}

QString OAuthFanfou::userName() const
{
    return m_userName;
}

QByteArray OAuthFanfou::generateAuthorizationHeader(const QString &username, const QString &password)
{
    QUrl url(ACCESS_TOKEN_URL);

    url.addEncodedQueryItem("x_auth_username", username.toUtf8().toPercentEncoding());
    url.addEncodedQueryItem("x_auth_password", password.toUtf8().toPercentEncoding());
    url.addQueryItem("x_auth_mode", "client_auth");

    QByteArray oauthHeader = OAuth::generateAuthorizationHeader(url, OAuth::POST);

    for (const QPair<QByteArray, QByteArray> &item : url.encodedQueryItems()) {
        oauthHeader.append("," + item.first + "=\"" + item.second + "\"");
    }

    return oauthHeader;
}

void OAuthFanfou::requestAccessToken(const QString &password)
{
    QNetworkRequest request;
    request.setUrl(QUrl(ACCESS_TOKEN_URL));
    request.setRawHeader("Authorization", generateAuthorizationHeader(m_userName, password));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    QNetworkReply *reply = m_accessManager->post(request, QByteArray());
    connect(reply, SIGNAL(finished()), this, SLOT(onRequestAccessToken()));
}

void OAuthFanfou::requestAccessToken(const QString &username, const QString &password)
{
    setUserName(username);
    requestAccessToken(password);
}

void OAuthFanfou::setUserName(QString arg)
{
    if (m_userName != arg) {
        m_userName = arg;
        emit userNameChanged(arg);
    }
}

void OAuthFanfou::onRequestAccessToken()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());

    if (!reply)
        return;

    const QByteArray &data = reply->readAll();

    /// network error
    if (reply->error() != QNetworkReply::NoError) {
        /// login failed
        if (data.contains("<error>")) {
            QString error = QString::fromUtf8(data);
            QRegExp regExp("<error>(.+)</error>", Qt::CaseInsensitive, QRegExp::RegExp2);

            if (regExp.indexIn(error) >= 0) {
                emit requestAccessTokenError(regExp.cap(1));
            } else {
                emit requestAccessTokenError(regExp.errorString() + "\n" + error);
            }
        } else {
            emit requestAccessTokenError(reply->errorString());
        }
        return;
    }

    const QList<QByteArray> &data_list = data.split('&');

    if (data_list.count() < 2) {
        emit requestAccessTokenError("Parse reply data error, data: " + QString::fromUtf8(data));
        return;
    }

    const QList<QByteArray> &token_list = data_list.first().split('=');
    const QList<QByteArray> &secret_list = data_list.last().split('=');

    if (token_list.count() < 2 || secret_list.count() < 2) {
        emit requestAccessTokenError("Parse reply data error, data: " + QString::fromUtf8(data));
        return;
    }

    if (token_list.first().contains("secret"))
        emit requestAccessTokenFinished(secret_list.last(), token_list.last());
    else
        emit requestAccessTokenFinished(token_list.last(), secret_list.last());
}
