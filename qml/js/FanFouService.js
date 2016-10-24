.pragma library

Qt.include("FanFouAPI.js")

var OAuth = {
    GET: 0,
    POST: 1,
    PUT: 2,
    DELETE: 3
}

var ffkit

function initialize(fk) {
    ffkit = fk
}

function httpRequest(method, url, async, data) {
    var xhr = ffkit.httpRequest();

    httpRequest.prototype.url = url

    if (method === OAuth.POST) {
        xhr.open("POST", url, async);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    } else {
        xhr.open("GET", url, async);
    }

    xhr.setRequestHeader("Authorization", ffkit.generateAuthorizationHeader(url, method))
    xhr.send(data);

    var object = {};

    if (xhr.readyState === xhr.DONE) {
        try {
            object = JSON.parse(xhr.responseText);

            if (xhr.status !== 200) {
                printError(xhr, object.error);
            }
        } catch(e) {
            object.error = JSON.stringify(e);
            printError(xhr, error);
        }
    }

    return object
}

function printError(xhr, error) {
    console.log("Http Request Error, url:", httpRequest.prototype.url)
    console.log("Message:", error)
    console.log("Http Status =", xhr.status, "statusText =", xhr.statusText)
    console.log("Request data =", xhr.responseText)
}

function login() {
    return httpRequest(OAuth.GET, account.verify_credentials)
}

function homeTimeline() {
    return httpRequest(OAuth.GET, statuses.home_timeline)
}
