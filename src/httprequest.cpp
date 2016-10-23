#include "httprequest.h"

#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QScriptEngine>

HttpRequest::HttpRequest(QObject *parent)
    : QObject(parent)
{
}

HttpRequest::~HttpRequest()
{
    if (m_reply) {
        m_reply->abort();
        m_reply->deleteLater();
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
    if (m_readyState != DONE || !m_reply) {
        qCritical("Error: Invalid state");
        return -1;
    }

    if (m_reply->error() == QNetworkReply::NoError)
        return 200;

    return m_reply->error();
}

QString HttpRequest::statusText() const
{
    if (m_readyState != DONE || !m_reply) {
        qCritical("Error: Invalid state");
    }

    return m_reply->errorString();
}

QByteArray HttpRequest::responseText() const
{
    if (m_readyState != DONE) {
        qCritical("Error: Invalid state");
    }

    return m_responseText;
}

void HttpRequest::setOnreadystatechange(QScriptValue arg)
{
    m_onreadystatechange = arg;
}

void HttpRequest::setRequestHeader(const QByteArray &name, const QByteArray &value)
{
    if (m_readyState != OPENED) {
        qCritical("Error: Invalid state");
        return;
    }

    m_request.setRawHeader(name, value);
}

void HttpRequest::open(const QByteArray &method, const QUrl &url)
{
    m_method = method;
    m_request = QNetworkRequest(url);

    if (m_reply) {
        m_reply->abort();
        m_reply->deleteLater();
    }

    setReadyState(OPENED);
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

    setReadyState(HEADERS_RECEIVED);
    connect(m_reply.data(), SIGNAL(readyRead()), this, SLOT(setReadyStateToLoading()));
    connect(m_reply.data(), SIGNAL(finished()), this, SLOT(onFinished()));
}

void HttpRequest::send()
{
    send(QByteArray());
}

void HttpRequest::abort()
{
    if (m_readyState < HEADERS_RECEIVED || m_readyState > LOADING || !m_reply) {
        qCritical("Error: Invalid state");
        return;
    }

    m_reply->abort();
    m_reply->deleteLater();
}

void HttpRequest::setReadyStateToLoading()
{
    setReadyState(LOADING);
}

void HttpRequest::setReadyState(HttpRequest::State state)
{
    if (state == m_readyState)
        return;

    m_readyState = state;

    if (m_onreadystatechange.isFunction()) {
        m_onreadystatechange.call();
    }
}

void HttpRequest::onFinished()
{
    m_responseText = m_reply->readAll();
    setReadyState(DONE);
}
