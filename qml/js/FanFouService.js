.pragma library

Qt.include("FanFouAPI.js")

var OAuth = {
    GET: 0,
    POST: 1,
    PUT: 2,
    DELETE: 3
}

var ffkit, appWindow

function initialize(fk, aw) {
    ffkit = fk
    appWindow = aw
}

function HttpRequest(method, url, data) {
    this.method = method
    this.url = url
    this.data = data
}

HttpRequest.prototype.send = function (onFinished, onFailed) {
            var xhr = ffkit.httpRequest(function() {
                                            if (xhr.readyState === xhr.DONE) {
                                                if (xhr.status === 200) {
                                                    try {
                                                        onFinished(JSON.parse(xhr.responseText));
                                                    } catch(e) {
                                                        if (onFailed)
                                                            onFailed(JSON.stringify(e));
                                                    }
                                                } else if (onFailed) {
                                                    onFailed(xhr.status + ",---" + xhr.statusText + "," + xhr.responseText);
                                                }
                                            }
                                        });

            if (this.method === OAuth.POST) {
                xhr.open("POST", this.url);
                xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            } else {
                xhr.open("GET", this.url);
            }

            xhr.setRequestHeader("Authorization", ffkit.generateAuthorizationHeader(this.url, this.method))
            xhr.send(this.data);
        }

function login() {
    var httpRequest = new HttpRequest(OAuth.POST, account.verify_credentials, "mode=lite")

    httpRequest.send(function(obj) {
                         appWindow.showInfoBanner("Login Finished: " + obj.name);
                     }, function(error) {
                         console.log(error, "login error")
                     })
}
