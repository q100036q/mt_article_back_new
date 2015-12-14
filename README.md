## 3G站页面

### Usage
##前提
1. 开通静态资源服务器权限
2. 开通[f2e server](http://f2e.developer.163.com/glli/f2e-server/index.html#10)
3. 本地已安装openssl

```
$ git clone https://git.ws.netease.com/ybduan/3g.git
$ cd 3g
$ npm install .
$ touch .ftppass (存放ftp密码)
$ touch .developer (内容为邮箱前缀)
$ grunt serve (开发时本地启动服务器，建议host一个163域的地址到本地，有的接口有校验)
$ grunt test (测试用，部署静态资源到f2eserver，且没有缓存，且外网可访问)
$ grunt deploy (部署用，静态资源部署到cdn，html手动拷贝到3gcms中)
```

* .ftppass文件格式为

  ```
    {
      "key1": {
        "username": "ybduan",
        "password": "...."
      }
    }
  ```

* .developer 为f2e server的用户名，为了方便测试。


### 目录
* article.html [文章页](http://3g.163.com/touch/article.html?from=index.yw&docid=ANV72N2G00963VRO)
* index.html [首页](http://3g.163.com/touch)
* emberedIndex.html [邮箱嵌入版首页](http://3g.163.com/ntes/special/0034073A/embered.html)
* article_back_new.html [新版文章回流页](http://3g.163.com/ntes/special/0034073A/wechat_article.html?docid=ALUNJTAK000853RO)
* list_back.html [文章回流页的首页](http://3g.163.com/ntes/special/0034073A/back_list.html?tab=headline)
* photoshare.html [图集回流页](http://3g.163.com/ntes/special/0034073A/photoshare.html?setid=63571)
* nba.html   NBA积分页
* live_new.html  直播页 [临时地址](http://f2e.developer.163.com/ybduan/test/live_new.html?roomid=63220)
* level.html 新闻客户端内个人信息页
* special.html 专题页

### 链接规则
* touch站：
  * 专题： http://3g.163.com/ntes/special/00340EPA/wapSpecialModule.html?sid=[专题ID]
  * 图集： http://3g.163.com/touch/photoview.html?channelid=[频道ID]&setid=[图集ID]
  * 直播： http://3g.163.com/ntes/special/00340BF8/seventlive.html?roomid=[房间ID]
  * 文章： http://3g.163.com/touch/article.html?docid=[文章ID]
* X版：
  * 图集： http://3g.163.com/gallery/photoview/54GI0096/65181.html 
  * 直播： http://live.163.com/3g/livelog/[房间ID]/30/desc/0/1/page.do

### 另外
1. 模板存放于[3gcms](https://3gcms.ws.netease.com/template/template.jsp?topicid=0034073A)
2. 各频道页代码直接存放在[3gcms](https://3gcms.ws.netease.com/template/template.jsp?topicid=003407PU)
3. 图集页代码直接存放在[3gcms](https://3gcms.ws.netease.com/template/model3g.jsp?topicid=0034073A&modelid=00343glargephoto_touch)







