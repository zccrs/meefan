.pragma library

Qt.include("FanFouAPI.js")

var OAuth = {
    GET: 0,
    POST: 1,
    PUT: 2,
    DELETE: 3
}

var ffkit, httpRequestErrorHandle

function initialize(fk, handle) {
    ffkit = fk;
    httpRequestErrorHandle = handle;
}

function HttpRequest(async, callback) {
    this.async = async;
    this.callback = callback;
}

HttpRequest.prototype.send = function(method, url, data, content_type) {
            var xhr = ffkit.httpRequest();
            var object = {};
            var callback = this.callback;

            function onreadystatechange() {
                if (xhr.readyState === xhr.DONE) {
                    try {
                        object = JSON.parse(xhr.responseText);

                        if (xhr.status !== 200) {
                            printError(url, xhr, object.error);

                            if (httpRequestErrorHandle)
                                httpRequestErrorHandle(xhr, object.error);
                        } else {
                            if (callback)
                                callback(object);
                        }
                    } catch(e) {
                        object.error = JSON.stringify(e);
                        printError(url, xhr, object.error);
                    }
                }
            }

            if (this.async)
                xhr.setOnreadystatechange(onreadystatechange);

            if (method === OAuth.POST) {
                xhr.open("POST", url, this.async);

                if (content_type)
                    xhr.setRequestHeader("Content-Type", content_type);
                else
                    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            } else {
                xhr.open("GET", url, this.async);
            }

            xhr.setRequestHeader("Authorization", ffkit.generateAuthorizationHeader(url, method))
            xhr.send(data);

            if (!this.async)
                onreadystatechange();

            return object;
        }

function printError(url, xhr, error) {
    console.log("Http Request Error, url:", url)
    console.log("Message:", error)
    console.log("Http Status =", xhr.status, "statusText =", xhr.statusText)
    console.log("Request data =", xhr.responseText)
}

function loginVerify() {
    var hr = new HttpRequest();

    return hr.send(OAuth.GET, account.verify_credentials);
}

function getStatusArray(path, max_id, extra_args, callback) {
    var hr = new HttpRequest(Boolean(callback), callback);

    return hr.send(OAuth.GET, statuses.packageUrl(path) + (max_id ? "&max_id=" + escape(max_id) : "")
                   + (extra_args ? ("&" + extra_args) : ""));
}

function getUsersArray(path, user_id, extra_args, callback) {
    var hr = new HttpRequest(Boolean(callback), callback);

    return hr.send(OAuth.GET, users.packageUrl(path) + (user_id ? "&id=" + user_id : "")
                   + (extra_args ? ("&" + extra_args) : ""));
}

function usersShow(userId) {
    var hr = new HttpRequest();

    if (userId)
        return hr.send(OAuth.GET, users.show + "&id=" + userId);

    return hr.send(OAuth.GET, users.show);
}

function MultipartBodyHandler() {
    this.list = [];
}

MultipartBodyHandler.prototype.getAll = function(uuid) {
            var data = "";

            for (var i in this.list) {
                var o = this.list[i];

                data += "--" + uuid
                        + "\nContent-Disposition: form-data; name=\"" + o.parameterName + "\""
                        + "\nContent-Transfer-Encoding: binary"
                        + "\nContent-Type: " + o.contentType + "; charset=" + o.contentCharset
                        + "\nContent-Length: " + String(o.data.toString().length)
                        + "\n\n" + o.data + "\n";
            }

            data += "--" + uuid + "--";

            return data;
        }

MultipartBodyHandler.prototype.add = function(parameterName, data, contentType, contentCharset) {
            var o = {
                "parameterName": parameterName,
                "data": data,
                "contentType": (contentType ? contentType : "text/plain"),
                "contentCharset": (contentCharset ? contentCharset : "utf-8")
            }

            this.list.push(o);
        }

//in_reply_to_status_id
//    作用: 回复的消息id
//    格式: in_reply_to_status_id=msg_id
//    字段说明: 可选

//in_reply_to_user_id
//    作用: 回复的用户id
//    格式: in_reply_to_user_id=user_id
//    字段说明: 可选

//repost_status_id
//    作用: 转发的消息id
//    格式: repost_status_id=msg_id
//    字段说明: 可选

//source
//    作用: 消息来源
//    格式: source=source_str
//    字段说明: 可选, source应为英文字符串
function sendMessage(text, in_reply_to_status_id, in_reply_to_user_id, repost_status_id, source) {
    var hr = new HttpRequest();
    var uuid = ffkit.createUuid();
    var bh = new MultipartBodyHandler();

    bh.add("status", ffkit.toUtf8(text));

    if (in_reply_to_status_id)
        bh.add("in_reply_to_status_id", in_reply_to_status_id, "application/json");

    if (in_reply_to_user_id)
        bh.add("in_reply_to_user_id", in_reply_to_user_id, "application/json");

    if (source)
        bh.add("source", source);

    bh.add("location", "Finland");

    return hr.send(OAuth.POST, statuses.update, bh.getAll(uuid), "multipart/form-data; boundary=" + uuid);
}
