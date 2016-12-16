.pragma library

var FANFOU_HOME = "http://fanfou.com/"
var HOST = "http://api.fanfou.com"
var FORMAT = "json"

// account
var account = {
    verify_credentials: HOST + "/account/verify_credentials." + FORMAT + "?mode=lite"
}

// favorites
var favorites = {
    getFavoriteUrl: function(messageId, favorite) {
                        if (favorite === undefined)
                            favorite = true;

                        return (favorite ? favorites.create : favorites.destroy)
                                + messageId + ".json?format=html"
                    },
    favorites: HOST + "/favorites/id." + FORMAT + "?count=10&format=html",
    create: HOST + "/favorites/create/",
    destroy: HOST + "/favorites/destroy/"
}

// photos
var photos = {
    upload: HOST + "/photos/upload." + FORMAT + "?format=html",
    user_timeline: HOST + "/photos/user_timeline." + FORMAT + "?count=10&format=html"
}

// status
var statuses = {
    packageUrl: function(path) {return statuses[path]},
    home_timeline: HOST + "/statuses/home_timeline." + FORMAT + "?mode=lite&count=10&format=html",
    user_timeline:  HOST + "/statuses/user_timeline." + FORMAT + "?mode=lite&count=10&format=html",
    public_timeline: HOST + "/statuses/public_timeline." + FORMAT + "?mode=lite&count=60&format=html",
    context_timeline: HOST + "/statuses/context_timeline." + FORMAT + "?format=html",
    replies: HOST + "/statuses/replies." + FORMAT + "?mode=lite&count=10&format=html",
    update: HOST + "/statuses/update." + FORMAT + "?mode=lite&format=html",
    destroy: HOST + "/statuses/destroy." + FORMAT,
    mentions: HOST + "/statuses/mentions." + FORMAT + "?count=10&format=html",
    favorites: favorites.favorites,
    photos_user_timeline: photos.user_timeline
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

// register
var register = {
    check: "http://fanfou.com/register.check",
    register: "http://fanfou.com/register"
}

// friendships
var friendships = {
    create: HOST + "/friendships/create." + FORMAT + "?format=html",
    destroy: HOST + "/friendships/destroy." + FORMAT + "?format=html"
}
