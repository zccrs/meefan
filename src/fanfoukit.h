#ifndef OAUTHFANFOU_H
#define OAUTHFANFOU_H

#include "oauth.h"

#include <QScriptValue>
#include <QVariant>
#include <QPointer>
#include <qmobilityglobal.h>

QT_BEGIN_NAMESPACE
class QNetworkAccessManager;
class QSettings;
QTM_BEGIN_NAMESPACE
class QFeedbackHapticsEffect;
QTM_END_NAMESPACE
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
    Q_INVOKABLE QByteArray readFile(const QString &filePath) const;
    Q_INVOKABLE QString fromUtf8(const QByteArray &data) const;
    Q_INVOKABLE QByteArray toUtf8(const QString &string) const;
    Q_INVOKABLE QString datetimeFormatFromISO(const QString &dt) const;
    Q_INVOKABLE void setSettingValue(const QString &name, const QVariant &value);
    Q_INVOKABLE QVariant settingValue(const QString &name, const QVariant &defaultValue = QVariant()) const;
    Q_INVOKABLE void clearSettings();
    Q_INVOKABLE QByteArray objectClassName(QObject *object) const;
    Q_INVOKABLE QString createUuid() const;
    /// duration unit is msec
    Q_INVOKABLE void vibrationDevice(qreal intensity = 0.1, int duration = 100);

    Q_INVOKABLE QString stringSimplified(const QString &string) const;

public slots:
    QByteArray generateXAuthorizationHeader(const QString &username, const QString &password);

    void requestAccessToken(const QString &username, const QString &password);

    QString stringEncrypt(const QString &content, QString key);//加密任意字符串，中文请使用utf-8编码
    QString stringUncrypt(const QString &content_hex, QString key);//解密加密后的字符串

signals:
    void requestAccessTokenFinished();
    void requestAccessTokenError(QString error);

private slots:
    void onRequestAccessToken();

private:
    void ensureVibraRumble();

    QNetworkAccessManager *m_accessManager;
    HttpRequest *m_httpRequest;
    QSettings *m_settings;
    QPointer<QTM_NAMESPACE::QFeedbackHapticsEffect> m_rumble;
};

#endif // OAUTHFANFOU_H
