#include "fanfoukit.h"
#include "httprequest.h"

#include <QPair>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QRegExp>
#include <QStringList>
#include <QFile>
#include <QDateTime>
#include <QDebug>

#define ACCESS_TOKEN_URL "http://fanfou.com/oauth/access_token"

FanfouKit::FanfouKit(QObject *parent)
    : OAuth(parent)
    , m_accessManager(new QNetworkAccessManager(this))
    , m_httpRequest(new HttpRequest(m_accessManager, this))
{
}

FanfouKit::FanfouKit(QNetworkAccessManager *manager, QObject *parent)
    : OAuth(parent)
    , m_accessManager(manager)
    , m_httpRequest(new HttpRequest(m_accessManager, this))
{

}

FanfouKit::FanfouKit(const QByteArray &consumerKey, const QByteArray &consumerSecret, QObject *parent)
    : OAuth(consumerKey, consumerSecret, parent)
    , m_accessManager(new QNetworkAccessManager(this))
{
}

HttpRequest *FanfouKit::httpRequest(const QScriptValue &onreadystatechange)
{
    m_httpRequest->setOnreadystatechange(onreadystatechange);

    return m_httpRequest;
}

QByteArray FanfouKit::readFile(const QString &filePath) const
{
    QFile file(filePath);

    if (file.open(QIODevice::ReadOnly))
        return file.readAll();

    return QByteArray();
}

QString FanfouKit::fromUtf8(const QByteArray &data) const
{
    return QString::fromUtf8(data);
}

QString FanfouKit::datetimeFormatFromISO(const QString &dt) const
{
    return QDateTime::fromString(dt, Qt::ISODate).toString("yyyy-MM-dd hh:mm");
}

QByteArray FanfouKit::generateXAuthorizationHeader(const QString &username, const QString &password)
{
    QUrl url(ACCESS_TOKEN_URL);

    url.addEncodedQueryItem("x_auth_username", username.toUtf8().toPercentEncoding());
    url.addEncodedQueryItem("x_auth_password", password.toUtf8().toPercentEncoding());
    url.addQueryItem("x_auth_mode", "client_auth");

    QByteArray oauthHeader = OAuth::generateAuthorizationHeader(url, OAuth::POST);
    const QList<QPair<QByteArray, QByteArray> > urlItems = url.encodedQueryItems();

    for (int i = 0; i < urlItems.count(); ++i) {
        const QPair<QByteArray, QByteArray> &item = urlItems.at(i);
        oauthHeader.append("," + item.first + "=\"" + item.second + "\"");
    }

    return oauthHeader;
}

void FanfouKit::requestAccessToken(const QString &username, const QString &password)
{
    QNetworkRequest request;
    request.setUrl(QUrl(ACCESS_TOKEN_URL));
    request.setRawHeader("Authorization", generateXAuthorizationHeader(username, password));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    QNetworkReply *reply = m_accessManager->post(request, QByteArray());
    connect(reply, SIGNAL(finished()), this, SLOT(onRequestAccessToken()));
}

void FanfouKit::onRequestAccessToken()
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

    if (token_list.first().contains("secret")) {
        setOAuthToken(secret_list.last());
        setOAuthTokenSecret(token_list.last());
    } else {
        setOAuthToken(token_list.last());
        setOAuthTokenSecret(secret_list.last());
    }

    emit requestAccessTokenFinished();
}
