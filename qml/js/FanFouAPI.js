.pragma library

var HOST = "http://api.fanfou.com"
var FORMAT = "json"

// account
var account = {
    verify_credentials: HOST + "/account/verify_credentials." + FORMAT + "?mode=lite"
}

// status
var statuses = {
    home_timeline: HOST + "/statuses/home_timeline." + FORMAT + "?mode=lite"
}
