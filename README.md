## 文章回流页嵌入mt增量更新

### 背景

如果不是新的产品上线，每次改的东西都挺少的，可能只是改改bug或是做些样式的调整，并不影响线上的大体功能，尤其是文章页，然而每次修改的js不超过10%。每次上线之后，都需要重新下载js，无形中浪费了用户的流量。

### 生产环境流程图

![生产环境流程图](https://github.com/liuyan5258/mt_article_back_new/blob/master/step01.png?raw=true)

### 使用方法

1. npm install mtbuild --save-dev
2. 但mtbuild这个包里没有mt的基础文件，这需要到mt的[git地址](https://github.com/mtjs/mt)里面mt/mt1.0/js/mt/base/目录下拷贝core.js和storeincLoad.js文件。我把这两个文件grunt混淆合并后在article\_back_new.html里面引用。
3. 在 article\_back_new.html 里面配置

        <script type="text/javascript" id="file_config">
            var g_config = {
              jsmap:{
                "article_back_new": "article_back_new.js"
              },
              storeInc:{
                //统计回调，统计脚本请求情况,jsUrl是js地址，mode是请求模式，
                //full:表示全量请求，inc表示增量请求，local表示从本地存储读取
                'statFunc':function(jsUrl,mode){
                  console.log('get '+jsUrl+' from '+mode);
                },
                //写本地存储异常回调，将脚本内容写入本地存储出现异常的时候调用，
                //用来提供给业务清理本地存储，storekey表示写入的key
                'storeExFunc':function(storeKey){
                  console.log('set store item '+storeKey+' exception') ;
                },
                'store': true,
                'inc': true,
                'proxy':true,
                'debug': false
              },
              //是否本地调试js
              testEnv: true,
              staticPath: '/release',
              serverDomain: 'http://localhost:6600',
              ver: '2015121600120',
              buildType: 'project'
            };
            //如果只是本地调试js，只需修改一下映射
            if(g_config.testEnv){
              g_config.jsmap={
                "article_back_new": "article_back_new.js"
              };
              g_config.storeInc = {};
              g_config.staticPath='/scripts';
              g_config.serverDomain='http://localhost:6600';
            }
        </script>
    
        //引用合并后的基础文件
        <script src="http://f2e.developer.163.com/liuyan/3g/scripts/mt/core.js"></script>
    
        //入口
        <script type="text/javascript">
              MT.config(g_config);
              require('article_back_new');
        </script>

4. 自定义/release的存放目录,mtbuild是默认会在虚拟目录的最外层新建release文件夹,这里我需要把它放在app目录下。所以我修改了mtupload.js、mtbuild.js、build_project.js、build_files.js、build.conf这些配置文件，只是在release的外层加了个app/。（ps:mtbuild注释中有说明可以自定义release的存放路径。）
5. build.conf的配置

            {
              './app/release/{pv}/article_back_new-{fv}.js': {
                  files: ['./.tmp/scripts/article_back_new.js']
              }
            }
            
        意思是以.tmp/scripts/下的js为原js文件进行增量更新后保存在app/release/{pv}/下面。因为增量更新的算法原理最后是用eval执行新增的js内容。而不是coffee。

6. 添加mt增量更新的启动命令，官方的是写了一个build.bat批处理文件，为了方便我把命令行添加在package.json里用npm start来执行:

            "scripts": {
                "start": "node node_modules/mtbuild/mtbuild.js app/article_back_new.html app/build.conf  lcs",
                "test": "echo \"Error: no test specified\" && exit 1"
              }

7. 做好了以上工作，就可以自己操作一遍啦。

### 演示过程

演示之前把本地调试js关闭testEnv: false,确保可以走增量更新。清除之前的localstorage。

第一次运行mt增量更新：

![图1](https://github.com/liuyan5258/mt_article_back_new/blob/master/result01.png?raw=true)

![图2](https://github.com/liuyan5258/mt_article_back_new/blob/master/result02.png?raw=true)

没有对js的修改，所以article\_back_new后面只有当前版本号（称全量js）。localStorage里面已经加入了对应版本的js数据。

不修改js，再次刷新页面：

![图3](https://github.com/liuyan5258/mt_article_back_new/blob/master/result03.png?raw=true)

已经不加载js了，而是获取本地存储数据。

让我们来修改一个js试试：

![图4](https://github.com/liuyan5258/mt_article_back_new/blob/master/result04.png?raw=true)

![图5](https://github.com/liuyan5258/mt_article_back_new/blob/master/result05.png?raw=true)

![图6](https://github.com/liuyan5258/mt_article_back_new/blob/master/result06.png?raw=true)

这时候article\_back_new后面有新旧两个版本号（称增量js），看一下body的内容，只有那么点，modify:true表示增量更新成功。这时候localStorage里面保存了对应版本的增量js数据。

再刷新试试：
ok！已经不重新下载js了。

哈哈，是不是很简单！
