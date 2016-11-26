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
    update: HOST + "/statuses/update." + FORMAT + "?mode=lite&format=html"
}

// users
var users = {
    packageUrl: function(path) {return users[path]},
    show: HOST + "/users/show." + FORMAT + "?format=html",
    followers: HOST + "/users/followers." + FORMAT + "?format=html",
    friends: HOST + "/users/friends." + FORMAT + "?format=html"
}

// direct-messages
var direct_messages = {
    conversation_list: HOST + "/direct_messages/conversation_list." + FORMAT,
    conversation: HOST + "/direct_messages/conversation." + FORMAT,
    newMessage: HOST + "/direct_messages/new." + FORMAT
}

// search
var search = {
    public_timeline: HOST + "/search/public_timeline." + FORMAT + "?count=60&format=html",
    user_timeline: HOST + "/search/user_timeline." + FORMAT + "?count=60&format=html"
}
