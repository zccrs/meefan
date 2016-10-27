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
#include <QDebug>

#define ACCESS_TOKEN_URL "http://fanfou.com/oauth/access_token"

char numToStr(int num)
{
    QByteArray str="QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm";
    return str[num%str.size ()];
}

QByteArray strZoarium(const QByteArray &str)
{
    QByteArray result;
    for(int i=0;i<str.size ();++i){
        char ch = (char)str[i];
        int ch_ascii = (int)ch;
        if(ch<='9'&&ch>='0'){//如果是数字
            result.append (ch);
        }else{//如果不是数字
            if(ch_ascii>=0)
                result.append (numToStr (ch_ascii)).append (QByteArray::number (ch_ascii)).append (numToStr (ch_ascii*2));
        }
    }
    return result;
}

QByteArray unStrZoarium(const QByteArray &str)
{
    QByteArray result="";
    for(int i=0;i<str.size ();){
        char ch = (char)str[i];
        if(ch<='9'&&ch>='0'){//如果是数字
            result.append (ch);
            i++;
        }else{//如果是其他
            QRegExp regexp("[^0-9]");
            int pos = QString(str).indexOf (regexp, i+1);
            if(pos>0){
                int num = str.mid (i+1, pos-i-1).toInt ();
                if(num>=0)
                    result.append ((char)num);
                i=pos+1;
            }else{
                //qDebug()<<"数据有错";
                i++;
            }
        }
    }
    return result;
}

QByteArray fillContent(const QByteArray &str, int length)
{
    if(length>0){
        QByteArray fill_size = QByteArray::number (length);
        if(fill_size.size ()==1)
            fill_size="00"+fill_size;
        else if(fill_size.size ()==2)
            fill_size="0"+fill_size;
        for(int i=0;i<length;++i){
            fill_size.append ("0");
        }
        return fill_size+str;
    }else{
        return "000"+str;
    }
}

FanfouKit::FanfouKit(QObject *parent)
    : OAuth(parent)
    , m_accessManager(new QNetworkAccessManager(this))
    , m_httpRequest(new HttpRequest(m_accessManager, this))
    , m_settings(new QSettings(this))
{

}

FanfouKit::FanfouKit(QNetworkAccessManager *manager, QObject *parent)
    : OAuth(parent)
    , m_accessManager(manager)
    , m_httpRequest(new HttpRequest(m_accessManager, this))
    , m_settings(new QSettings(this))
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

void FanfouKit::setSettingValue(const QString &name, const QVariant &value)
{
    m_settings->setValue(name, value);
}

QVariant FanfouKit::settingValue(const QString &name, const QVariant &defaultValue) const
{
    return m_settings->value(name, defaultValue);
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
    if(content==""||key=="")
        return content;
    if(key.size ()>256)
        key = key.mid (0,256);//密匙最长256位
    QByteArray data = strZoarium (content.toUtf8 ().toBase64 ());
    int data_size = data.size ();
    QByteArray mykey = strZoarium (key.toLatin1 ().toHex ());
    int key_size = mykey.size ();
    //qDebug()<<data;
    data=fillContent (data, 2*key_size-data_size);//填充字符串
    //qDebug()<<data;
    QByteArray temp="";
    for(int i=0;i<data.size ();++i){
        int ch = (int)data[i]+(int)mykey[i%key_size];
        //qDebug()<<ch<<(int)mykey[i%key_size]<<(int)data[i];
        if(ch>=0)
            temp.append (QString(ch));
    }
    //qDebug()<<temp;
    return QString::fromUtf8 (temp);
}

QString FanfouKit::stringUncrypt(const QString &content, QString key)
{
    if(content==""||key=="")
        return content;
    if(key.size ()>256)
        key = key.mid (0,256);//密匙最长256位
    QByteArray data = content.toLatin1 ();
    QByteArray mykey = strZoarium (key.toLatin1 ().toHex ());
    int key_size = mykey.size ();
    QByteArray temp;

    for(int i=0;i<data.size ();++i){
        int ch = (int)(uchar)data[i]-(int)mykey[i%key_size];
        if(ch>=0){
            temp.append ((char)ch);
        }
    }
    temp = unStrZoarium (temp);
    int fill_size = temp.mid (0, 3).toInt ();
    temp = temp.mid (fill_size+3, temp.size ()-fill_size-3);//除去填充的字符

    return QString::fromUtf8 (QByteArray::fromBase64 (temp));
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
