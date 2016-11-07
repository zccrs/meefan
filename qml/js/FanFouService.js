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

HttpRequest.prototype.send = function(method, url, data) {
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

function homeTimeline(max_id, callback) {
    var hr = new HttpRequest(Boolean(callback), callback);

    return hr.send(OAuth.GET, statuses.home_timeline + (max_id ? "&max_id=" + max_id : ""));
}

function userTimeline(max_id) {
    var hr = new HttpRequest();

    return hr.send(OAuth.GET, statuses.user_timeline + (max_id ? "&max_id=" + max_id : ""));
}

function userReplies(max_id) {
    var hr = new HttpRequest();

    return hr.send(OAuth.GET, statuses.replies + (max_id ? "&max_id=" + max_id : ""));
}

function usersShow(userId) {
    var hr = new HttpRequest();

    if (userId)
        return hr.send(OAuth.GET, users.show + "&id=" + userId);

    return hr.send(OAuth.GET, users.show);
}
