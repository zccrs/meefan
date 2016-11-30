#include "httprequest.h"

#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QScriptEngine>
#include <QEventLoop>
#include <QDebug>

HttpRequest::HttpRequest(QObject *parent)
    : QObject(parent)
    , m_readyState(Unsent)
    , m_manager(NULL)
{

}

HttpRequest::HttpRequest(QNetworkAccessManager *manager, QObject *parent)
    : QObject(parent)
    , m_readyState(Unsent)
    , m_manager(manager)
{

}

HttpRequest::~HttpRequest()
{
    if (m_reply) {
        m_reply->abort();
        m_reply->deleteLater();
    }

    if (eventLoop) {
        eventLoop->exit();
    }
}

QScriptValue HttpRequest::onreadystatechange() const
{
    return m_onreadystatechange;
}

HttpRequest::State HttpRequest::readyState() const
{
    return m_readyState;
}

int HttpRequest::status() const
{
    if (m_readyState != Done || !m_reply) {
        qCritical("Error: Invalid state");
        return -1;
    }

    if (m_reply->error() == QNetworkReply::NoError)
        return 200;

    return m_reply->error();
}

QString HttpRequest::statusText() const
{
    if (m_readyState != Done || !m_reply) {
        qCritical("Error: Invalid state");
    }

    return m_reply->errorString();
}

QByteArray HttpRequest::responseText() const
{
    if (m_readyState != Done) {
        qCritical("Error: Invalid state");
    }

    return m_responseText;
}

HttpRequest::State HttpRequest::enumUnsent() const
{
    return Unsent;
}

HttpRequest::State HttpRequest::enumOpened() const
{
    return Opened;
}

HttpRequest::State HttpRequest::enumHeaders_Received() const
{
    return Headers_Received;
}

HttpRequest::State HttpRequest::enumLoading() const
{
    return Loading;
}

HttpRequest::State HttpRequest::enumDone() const
{
    return Done;
}

void HttpRequest::setOnreadystatechange(const QScriptValue &arg)
{
    m_onreadystatechange = arg;
}

void HttpRequest::setRequestHeader(const QByteArray &name, const QByteArray &value)
{
    if (m_readyState != Opened) {
        qCritical("Error: Invalid state");
        return;
    }

    m_request.setRawHeader(name, value);
}

void HttpRequest::open(const QByteArray &method, const QUrl &url, bool async)
{
    m_method = method;
    m_request = QNetworkRequest(url);
    m_async = async;

    if (m_reply) {
        m_reply->abort();
        m_reply->deleteLater();
    }

    if (eventLoop) {
        eventLoop->exit();
    }

    setReadyState(Opened);
}

void HttpRequest::send(const QByteArray &data)
{
    if (!m_manager)
        m_manager = new QNetworkAccessManager(this);

    if (m_method == "GET")
        m_reply = m_manager->get(m_request);
    else if (m_method == "POST")
        m_reply = m_manager->post(m_request, data);
    else if (m_method == "PUT")
        m_reply = m_manager->put(m_request, data);
    else if (m_method == "HEAD")
        m_reply = m_manager->head(m_request);
    else
        return;

    setReadyState(Headers_Received);
    connect(m_reply.data(), SIGNAL(readyRead()), this, SLOT(setReadyStateToLoading()));
    connect(m_reply.data(), SIGNAL(finished()), this, SLOT(onFinished()));

    if (!m_async) {
        if (eventLoop) {
            eventLoop->exit();
        }

        QEventLoop loop;
        eventLoop = &loop;
        loop.exec();
    }
}

void HttpRequest::abort()
{
    if (m_readyState < Headers_Received || m_readyState > Loading || !m_reply) {
        qCritical("Error: Invalid state");
        return;
    }

    m_reply->abort();
    m_reply->deleteLater();

    if (eventLoop) {
        eventLoop->exit();
    }

    setOnreadystatechange(QScriptValue());
}

void HttpRequest::setReadyStateToLoading()
{
    setReadyState(Loading);
}

void HttpRequest::setReadyState(HttpRequest::State state)
{
    if (state == m_readyState)
        return;

    m_readyState = state;

    emit readyStateChanged();

    if (m_onreadystatechange.isFunction()) {
        m_onreadystatechange.call();
    }
}

void HttpRequest::onFinished()
{
    m_responseText = m_reply->readAll();
    setReadyState(Done);

    if (eventLoop) {
        eventLoop->exit();
    }

    setOnreadystatechange(QScriptValue());
}
