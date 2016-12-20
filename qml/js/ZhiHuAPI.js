// api from: https://github.com/izzyleung/ZhihuDailyPurify/wiki/%E7%9F%A5%E4%B9%8E%E6%97%A5%E6%8A%A5-API-%E5%88%86%E6%9E%90

.pragma library

var Z_API_VERSION = 4;
var Z_HOST = "http://news-at.zhihu.com/api/" + Z_API_VERSION

var z_news = {
    latest: Z_HOST + "/news/latest",
    before: function(date) {return Z_HOST + "/news/before/" + date;},
    newsContent: function(newsId) {return Z_HOST + "/news/" + newsId;}
}
