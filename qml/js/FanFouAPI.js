.pragma library

var HOST = "http://api.fanfou.com"
var FORMAT = "json"

// account
var account = {
    verify_credentials: HOST + "/account/verify_credentials." + FORMAT + "?mode=lite"
}

// status
var statuses = {
    packageUrl: function(path) {return statuses[path]},
    home_timeline: HOST + "/statuses/home_timeline." + FORMAT + "?mode=lite&count=10&format=html",
    user_timeline:  HOST + "/statuses/user_timeline." + FORMAT + "?mode=lite&count=10&format=html",
    public_timeline: HOST + "/statuses/public_timeline." + FORMAT + "?mode=lite&count=60&format=html",
    replies: HOST + "/statuses/replies." + FORMAT + "?mode=lite&count=10&format=html",
    update: HOST + "/statuses/update." + FORMAT + "?mode=lite&status=status_text&format=html&location=Finland"
}

// users
var users = {
    show: HOST + "/users/show." + FORMAT + "?format=html"
}
