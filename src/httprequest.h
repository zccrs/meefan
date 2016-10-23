#ifndef HTTPREQUEST_H
#define HTTPREQUEST_H

#include <QObject>
#include <QScriptValue>
#include <QPointer>
#include <QNetworkRequest>

QT_BEGIN_NAMESPACE
class QUrl;
class QNetworkAccessManager;
class QNetworkReply;
QT_END_NAMESPACE

class HttpRequest : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QScriptValue onreadystatechange READ onreadystatechange WRITE setOnreadystatechange)
    Q_PROPERTY(State readyState READ readyState CONSTANT)
    Q_PROPERTY(int status READ status CONSTANT)
    Q_PROPERTY(QString statusText READ statusText CONSTANT)
    Q_PROPERTY(QByteArray responseText READ responseText CONSTANT)

public:
    enum State {
        UNSENT,
        OPENED,
        HEADERS_RECEIVED,
        LOADING,
        DONE
    };

    Q_ENUMS(State)

    explicit HttpRequest(QObject *parent = 0);
    ~HttpRequest();

    QScriptValue onreadystatechange() const;
    State readyState() const;
    int status() const;
    QString statusText() const;
    QByteArray responseText() const;

public slots:
    void setOnreadystatechange(QScriptValue arg);
    void setRequestHeader(const QByteArray &name, const QByteArray &value);
    void open(const QByteArray &method, const QUrl &url);
    void send(const QByteArray &data);
    void send();
    void abort();

private slots:
    void setReadyStateToLoading();
    void onFinished();

private:
    void setReadyState(State state);

    QScriptValue m_onreadystatechange;
    State m_readyState = UNSENT;
    QNetworkRequest m_request;
    QNetworkAccessManager *m_manager = NULL;
    QPointer<QNetworkReply> m_reply;
    QByteArray m_responseText;
    QByteArray m_method;
};

#endif // HTTPREQUEST_H
