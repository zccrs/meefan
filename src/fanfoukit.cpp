#include "fanfoukit.h"
#include "httprequest.h"

#include <QPair>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QRegExp>
#include <QStringList>
#include <QFile>
#include <QDateTime>
#include <QSettings>
#include <QCryptographicHash>
#include <QUuid>
#include <QtFeedback/QFeedbackHapticsEffect>
#include <QtFeedback/QFeedbackActuator>
#include <QFontMetrics>
#include <QFileInfo>
#include <QDebug>

#define ACCESS_TOKEN_URL "http://fanfou.com/oauth/access_token"

FanfouKit::FanfouKit(QObject *parent)
    : OAuth(parent)
    , m_accessManager(new QNetworkAccessManager(this))
    , m_httpRequest(new HttpRequest(m_accessManager, this))
    , m_settings(new QSettings(this))
    , m_rumble(0)
{

}

FanfouKit::FanfouKit(QNetworkAccessManager *manager, QObject *parent)
    : OAuth(parent)
    , m_accessManager(manager)
    , m_httpRequest(new HttpRequest(m_accessManager, this))
    , m_settings(new QSettings(this))
    , m_rumble(0)
{

}

FanfouKit::FanfouKit(const QByteArray &consumerKey, const QByteArray &consumerSecret, QObject *parent)
    : OAuth(consumerKey, consumerSecret, parent)
    , m_accessManager(new QNetworkAccessManager(this))
    , m_httpRequest(new HttpRequest(m_accessManager, this))
    , m_settings(new QSettings(this))
    , m_rumble(0)
{

}

HttpRequest *FanfouKit::httpRequest() const
{
    return m_httpRequest;
}

QByteArray FanfouKit::readFile(const QString &filePath) const
{
    QFile file(filePath);

    if (file.open(QIODevice::ReadOnly)) {
        return file.readAll();
    }

    return QByteArray();
}

QString FanfouKit::fileName(const QString &filePath) const
{
    QFileInfo info(filePath);

    return info.fileName();
}

QString FanfouKit::fromUtf8(const QByteArray &data) const
{
    return QString::fromUtf8(data);
}

QByteArray FanfouKit::toUtf8(const QString &string) const
{
    return string.toUtf8();
}

QString FanfouKit::datetimeFormatFromISO(const QString &dt) const
{
    return QDateTime::fromString(dt, Qt::ISODate).toLocalTime().toString("yyyy-MM-dd hh:mm");
}

void FanfouKit::setSettingValue(const QString &name, const QVariant &value)
{
    m_settings->setValue(name, value);
}

QVariant FanfouKit::settingValue(const QString &name, const QVariant &defaultValue) const
{
    return m_settings->value(name, defaultValue);
}

void FanfouKit::clearSettings()
{
    m_settings->clear();
}

QByteArray FanfouKit::objectClassName(QObject *object) const
{
    return object->metaObject()->className();
}

QString FanfouKit::createUuid() const
{
    return QUuid::createUuid().toString();
}

void FanfouKit::vibrationDevice(qreal intensity, int duration)
{
    ensureVibraRumble();

    m_rumble->setIntensity(intensity);
    m_rumble->setDuration(duration);
    m_rumble->start();
}

QString FanfouKit::stringSimplified(const QString &string) const
{
    return string.simplified();
}

QByteArray FanfouKit::byteArrayJoin(const QByteArray &a1, const QByteArray &a2,
                                    const QByteArray &a3, const QByteArray &a4,
                                    const QByteArray &a5, const QByteArray &a6) const
{
    return a1 + a2 + a3 + a4 + a5 + a6;
}

int FanfouKit::byteArraySize(const QByteArray &data) const
{
    return data.size();
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

QString FanfouKit::stringEncrypt(const QString &content, QString key)
{
    if (content.isEmpty() || key.isEmpty())
        return content;

   key = QString::fromUtf8(QCryptographicHash::hash(key.toUtf8(), QCryptographicHash::Md5));

   QString request;

   for (int i = 0; i < content.count(); ++i) {
       request.append(QChar(content.at(i).unicode() ^ key.at(i % key.size()).unicode()));
   }

   return request;
}

QString FanfouKit::stringUncrypt(const QString &content, QString key)
{
    return stringEncrypt(content, key);
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

void FanfouKit::ensureVibraRumble()
{
    if (m_rumble)
        return;

    m_rumble = new QTM_NAMESPACE::QFeedbackHapticsEffect(this);

    foreach (QTM_NAMESPACE::QFeedbackActuator *actuator, QTM_NAMESPACE::QFeedbackActuator::actuators()) {
        if (actuator->name() == "Vibra") {
            m_rumble->setActuator(actuator);
            break;
        }
    }
}
