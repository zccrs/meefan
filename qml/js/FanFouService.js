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
    this.xhr = null;
}

HttpRequest.prototype.send = function(method, url, data, content_type) {
            var xhr = ffkit.httpRequest();
            var object = {};
            var callback = this.callback;

            function onreadystatechange() {
                if (xhr.readyState === xhr.DONE) {
                    try {
                        object = JSON.parse(xhr.responseText);
                    } catch(e) {
                        object = xhr.responseText;
                    }

                    if (xhr.status !== 200) {
                        if (xhr.status !== 302) {
                            printError(url, xhr, object.error);

                            if (httpRequestErrorHandle)
                                httpRequestErrorHandle(xhr, object.error);
                        }
                    } else if (callback) {
                        callback(object);
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
                    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
            } else {
                xhr.open("GET", url, this.async);
            }

            xhr.setRequestHeader("Authorization", ffkit.generateAuthorizationHeader(url, method))
            xhr.send(data);

            if (!this.async)
                onreadystatechange();

            this.xhr = xhr;

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

function getStatusArray(path, page, max_id, extra_args, callback) {
    var hr = new HttpRequest(Boolean(callback), callback);

    return hr.send(OAuth.GET, statuses.packageUrl(path, page) + (max_id ? "&max_id=" + escape(max_id) : "")
                   + (extra_args ? ("&" + extra_args) : ""));
}

function getUsersArray(path, page, user_id, extra_args, callback) {
    var hr = new HttpRequest(Boolean(callback), callback);

    return hr.send(OAuth.GET, users.packageUrl(path, page) + (user_id ? "&id=" + user_id : "")
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

                data += this.objectToString(o, uuid);
            }

            data += "--" + uuid + "--";

            return data;
        }

MultipartBodyHandler.prototype.add = function(parameterName, data, contentType, contentCharset, contentLength, disposition) {
            var o = {
                "parameterName": parameterName,
                "data": data,
                "contentType": (contentType ? contentType : "text/plain"),
                "contentCharset": (contentCharset ? contentCharset : "utf-8"),
                "disposition": (disposition ? disposition : "form-data"),
                "contentLength": (contentLength ? contentLength : String(data.toString().length))
            }

            this.list.push(o);

            return o;
        }

MultipartBodyHandler.prototype.objectToString = function(o, uuid) {
    var data = "--" + uuid
             + "\nContent-Disposition: "+ o.disposition +"; name=\"" + o.parameterName + "\""
             + "\nContent-Transfer-Encoding: binary"
             + "\nContent-Type: " + o.contentType + "; charset=" + o.contentCharset
             + "\nContent-Length: " + o.contentLength
             + "\n\n" + o.data + "\n";

    return data;
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
function commitMessage(text, in_reply_to_status_id, in_reply_to_user_id, repost_status_id, source) {
    var hr = new HttpRequest();
    var uuid = ffkit.createUuid();
    var bh = new MultipartBodyHandler();

    bh.add("status", ffkit.toUtf8(text));

    if (in_reply_to_status_id)
        bh.add("in_reply_to_status_id", in_reply_to_status_id, "application/json");

    if (in_reply_to_user_id)
        bh.add("in_reply_to_user_id", in_reply_to_user_id, "application/json");

    if (repost_status_id)
        bh.add("repost_status_id", repost_status_id, "application/json");

    if (source)
        bh.add("source", source);

    bh.add("location", "Finland");

    return hr.send(OAuth.POST, statuses.update, bh.getAll(uuid), "multipart/form-data; boundary=" + uuid);
}

function uploadPhoto(photoFileUrl, text, source) {
    var hr = new HttpRequest();
    var uuid = ffkit.createUuid();
    var bh = new MultipartBodyHandler();
    var textObject;

    if (text)
        textObject = bh.add("status", ffkit.toUtf8(text));

    if (photoFileUrl.toString().indexOf("file://") === 0)
        photoFileUrl = photoFileUrl.toString().slice(7);

    var fileData = ffkit.readFile(photoFileUrl);
    var disposition = "form-data;filename=\""+ ffkit.fileName(photoFileUrl) +"\"";
    var photoData =  bh.objectToString(bh.add("photo", "", "", "", ffkit.byteArraySize(fileData), disposition), uuid);
    var data = photoData.slice(0, photoData.length - 1);

    if (textObject)
        data = ffkit.byteArrayJoin(bh.objectToString(textObject, uuid), data, fileData, "\n--" + uuid + "--");
    else
        data = ffkit.byteArrayJoin(data, fileData, "\n--" + uuid + "--");

    return hr.send(OAuth.POST, photos.upload, data, "multipart/form-data; boundary=" + uuid);
}

function getPrivateMessageList(page) {
    var hr = new HttpRequest();

    return hr.send(OAuth.GET, direct_messages.conversation_list + (page ? "&page=" + page : ""));
}

//in_reply_to_id
//    作用: 回复的私信id
//    格式: in_reply_to_id=msg_id
//    字段说明: 可选
function sendPrivateMessage(targetUserId, text, in_reply_to_id) {
    var hr = new HttpRequest();
    var uuid = ffkit.createUuid();
    var bh = new MultipartBodyHandler();

    bh.add("user", targetUserId, "application/json")
    bh.add("text", ffkit.toUtf8(text));

    if (in_reply_to_id)
        bh.add("in_reply_to_id", in_reply_to_id, "application/json");

    return hr.send(OAuth.POST, direct_messages.newMessage, bh.getAll(uuid), "multipart/form-data; boundary=" + uuid);
}

function getPrivateMessagesOfUser(targetUserId, max_id, since_id) {
    var hr = new HttpRequest();
    var url = direct_messages.conversation + "?id=" + targetUserId;

    if (max_id)
        url += ("&max_id=" + max_id);

    if (since_id)
        url += ("&since_id=" + since_id);

    return hr.send(OAuth.GET, url);
}

function searchMessage(keyword, max_id, targetUserId, callback) {
    var hr = new HttpRequest(Boolean(callback), callback);
    var url = targetUserId ? search.user_timeline : search.public_timeline;

    url += "&q=" + escape(ffkit.toUtf8(keyword));

    if (max_id)
        url += "&max_id=" + max_id;

    if (targetUserId)
        url += "&id=" + targetUserId;

//    if (since_id)
//        url += "&since_id" + since_id;

    return hr.send(OAuth.GET, url);
}

function registerCheck(email, nickname, callback) {
    var hr;
    var url = register.check;
    var data = "action=register.check";

    var cb = function(obj) {
        if (obj.status === 0) {
            obj.error = obj.msg;
            printError(url, hr.xhr, obj.error);

            if (httpRequestErrorHandle)
                httpRequestErrorHandle(hr.xhr, obj.error)
        }

        if (callback)
            callback(obj);

        return obj;
    };

    if (callback) {
        hr = new HttpRequest(true, cb);
    } else {
        hr = new HttpRequest();
    }

    if (email)
        data += "&email=" + encodeURIComponent(email);

    if (nickname)
        data += "&realname=" + encodeURIComponent(nickname);

    var obj = hr.send(OAuth.POST, url, data);

    if (obj)
        return cb(obj);
}

function registerFanfou(email, nickname, password) {
    var hr = new HttpRequest();
    var url = register.register;
    var data = "action=register";

    data += "&email=" + encodeURIComponent(email);
    data += "&realname=" + encodeURIComponent(nickname);
    data += "&loginpass=" + encodeURIComponent(password);
    data += "&verifypass=" + encodeURIComponent(password);

    var regexp = /<input\s+type="hidden"\s+name="token"\s+value="(\S+)"\s*\/>/g;
    var list = regexp.exec(hr.send(OAuth.GET, url));

    var obj = {};

    if (list[1]) {
        data += "&token=" + list[1];
        var request = hr.send(OAuth.POST, url, data);

        if (/\S+/.exec(request)) {
            obj.error = qsTr("Registration failed");
        }
    } else {
        obj.error = qsTr("Get register token failed");
    }

    if (obj.error && httpRequestErrorHandle)
        httpRequestErrorHandle(hr.xhr, obj.error)

    return obj;
}

function destroyMessage(messageId) {
    var hr = new HttpRequest();
    var uuid = ffkit.createUuid();
    var bh = new MultipartBodyHandler();

    bh.add("id", messageId);

    return hr.send(OAuth.POST, statuses.destroy, bh.getAll(uuid), "multipart/form-data; boundary=" + uuid);
}

function favoriteMessage(messageId) {
    var hr = new HttpRequest();

    return hr.send(OAuth.POST, favorites.getFavoriteUrl(messageId, true));
}

function cancelFavoriteMessage(messageId) {
    var hr = new HttpRequest();

    return hr.send(OAuth.POST, favorites.getFavoriteUrl(messageId, false));
}

function likeFriend(userId) {
    var hr = new HttpRequest();

    var uuid = ffkit.createUuid();
    var bh = new MultipartBodyHandler();

    bh.add("id", userId);
    bh.add("format", "html");

    return hr.send(OAuth.POST, friendships.create, bh.getAll(uuid), "multipart/form-data; boundary=" + uuid);
}

function cancelLikeFriend(userId) {
    var hr = new HttpRequest();

    var uuid = ffkit.createUuid();
    var bh = new MultipartBodyHandler();

    bh.add("id", userId);
    bh.add("format", "html");

    return hr.send(OAuth.POST, friendships.destroy, bh.getAll(uuid), "multipart/form-data; boundary=" + uuid);
}

function getNotification() {
    var hr = new HttpRequest();

    return hr.send(OAuth.GET, account.notification);
}
