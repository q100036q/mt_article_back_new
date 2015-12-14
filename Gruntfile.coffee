module.exports = (grunt)->

  require('load-grunt-tasks')(grunt)
  require('time-grunt')(grunt)
  fs = require('fs')
  path = require('path')
  exec = require('child_process').exec

  appConfig = {
    app: 'app'
    dist: 'dist'
    developer: grunt.file.read('.developer')
    version: grunt.template.today("yyyymmddHHMMss")
  }


  grunt.initConfig {
    ntes: appConfig

    watch:{
      coffee: 
        files: ['<%= ntes.app %>/scripts/{,*/}*.coffee'],
        tasks: ['newer:coffee:compile']
      less:
        files: ['<%= ntes.app %>/styles/{,*/}*.less'],
        tasks: ['less:compile']
      style:
        files: ['<%= ntes.app %>/styles/{,*/}*.css'],
        tasks: ['copy:styles']
      js:
        files: ['<%= ntes.app %>/scripts/{,*/}*.js'],
        tasks: ['newer:copy:js']
      jsx:
        files: ['<%= ntes.app %>/jsx/{,*/}*.js'],
        tasks: ['react:compile']

      livereload:
        options:
          livereload: '<%= connect.options.livereload %>'
        files: [
          '<%= ntes.app %>/{,*/}*.html',
          '.tmp/styles/{,*/}*.css',
          '.tmp/scripts/{,*/}*.js',
          '<%= ntes.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
        ]
    }

    connect: {
      options: 
        port: 6600
        # Change this to '0.0.0.0' to access the server from outside.
        hostname: 'localhost'
        livereload: 35729
      livereload:
        options: 
          open: true,
          middleware: (connect)->
            return [
              connect.static('.tmp')
              connect.static(appConfig.app)
            ]
      dist:
        options:
          open: true
          base: '<%= ntes.dist %>'
        
    }

    less:{
      options:
        compress: true
      compile:
        files: [{
          expand: true,
          cwd: '<%= ntes.app %>/styles/'
          src: ['{,*/}*.less', '!{,*/}*.mixin.less'],
          dest: '.tmp/styles/'
          ext: '.css'
        }]
    }

    coffee: {
      compile: {
        files: [{
          expand: true
          cwd: '<%= ntes.app %>/scripts/'
          src: ['{,*/}*.coffee']
          dest: '.tmp/scripts/'
          ext: '.js'
        }]
      }
    }

    react: {
      compile:
        files: [
          expand: true
          cwd: '<%= ntes.app %>/jsx/'
          src: ['*.js']
          dest: '.tmp/scripts'
          ext: '.js'
        ]
    }

    uglify: {
      dist: 
        files: [{
          expand: true
          cwd: '.tmp/scripts/'
          src: ['*.js']
          dest: '.tmp/scripts/'
          ext: '.js'
        },{
          expand: true
          cwd: '<%= ntes.app %>/scripts/'
          src: ['*.js']
          dest: '.tmp/scripts/'
          ext: '.js'
        }]
          
    }
    htmlbuild: {
      test:
        src: '<%=ntes.app%>/*.html'
        dest: '<%=ntes.dist%>/'
        options:
          prefix: 'http://f2e.developer.163.com/<%= ntes.developer %>/3g/'
          scripts:
            article:
              main: 'dist/scripts/article.js'
            nba:
              main: 'dist/scripts/nba.js'
            index:
              main: 'dist/scripts/index.js'
            live:
              main: 'dist/scripts/live.js'
            special:
              main: 'dist/scripts/special.js'
            article_back:
              main: 'dist/scripts/article_back.js'
            article_back_new:
              main: 'dist/scripts/article_back_new.js'
            live_new:
              main: 'dist/scripts/live_new.js'
            radio_back:
              main: 'dist/scripts/radio_back.js'
            video_back:
              main: 'dist/scripts/video_back.js'
            ember:
              main: 'dist/scripts/embered_index.js'
          styles:
            article:
              main: 'dist/styles/article.css'
            nba:
              main: 'dist/styles/nba.css'
            index:
              main: 'dist/styles/index.css'
            live:
              main: 'dist/styles/live.css'
            special:
              main: 'dist/styles/special.css'
            article_back:
              main: 'dist/styles/article_back.css'
            article_back_new:
              main: 'dist/styles/article_back_new.css'
            live_new:
              main: 'dist/styles/live_new.css'
            radio_back:
              main: 'dist/styles/radio_back.css'
            video_back:
              main: 'dist/styles/video_back.css'
            ember:
              main: 'dist/styles/embered_index.css'
      dist:
        src: '<%=ntes.app%>/*.html'
        dest: '<%=ntes.dist%>/<%= ntes.version %>/html'
        options:
          prefix: 'http://img1.cache.netease.com/utf8/3g/touch/<%= ntes.version %>/holder/'
          # relative: false
          scripts:
            article:
              main: 'dist/<%= ntes.version %>/scripts/article.js'
            nba:
              main: 'dist/<%= ntes.version %>/scripts/nba.js'
            index:
              main: 'dist/<%= ntes.version %>/scripts/index.js'
            special:
              main: 'dist/<%= ntes.version %>/scripts/special.js'
            article_back:
              main: 'dist/<%= ntes.version %>/scripts/article_back.js'
            article_back_new:
              main: 'dist/<%= ntes.version %>/scripts/article_back_new.js'
            live_new:
              main: 'dist/<%= ntes.version %>/scripts/live_new.js'
            local_back:
              main: 'dist/<%= ntes.version %>/scripts/local_back.js'
            radio_back:
              main: 'dist/<%= ntes.version %>/scripts/radio_back.js'
            video_back:
              main: 'dist/<%= ntes.version %>/scripts/video_back.js'
            ember:
              main: 'dist/<%= ntes.version %>/scripts/embered_index.js'
          styles:
            article:
              main: 'dist/<%= ntes.version %>/styles/article.css'
            nba:
              main: 'dist/<%= ntes.version %>/styles/nba.css'
            index:
              main: 'dist/<%= ntes.version %>/styles/index.css'
            special:
              main: 'dist/<%= ntes.version %>/styles/special.css'
            article_back:
              main: 'dist/<%= ntes.version %>/styles/article_back.css'
            article_back_new:
              main: 'dist/<%= ntes.version %>/styles/article_back_new.css'
            live_new:
              main: 'dist/<%= ntes.version %>/styles/live_new.css'
            local_back:
              main: 'dist/<%= ntes.version %>/styles/local_back.css'
            radio_back:
              main: 'dist/<%= ntes.version %>/styles/radio_back.css'
            video_back:
              main: 'dist/<%= ntes.version %>/styles/video_back.css'
            ember:
              main: 'dist/<%= ntes.version %>/styles/embered_index.css'
    }

    clean: {
      dist: 
        files: [{
          dot: true,
          src: [
            '.tmp',
            '<%= ntes.dist %>/{,*/}*',
            '!<%= ntes.dist %>/.git*'
          ]
        }]
      
      server: '.tmp'
    }

    autoprefixer: {
      options: 
        remove: false,
        browsers: ['> 1%', 'Android >= 2.1', 'Chrome >= 21', 'Explorer >= 10', 'Firefox >= 17', 'Opera >= 12.1', 'Safari >= 6.0']
      dist: 
        files: [{
          expand: true,
          cwd: '.tmp/styles/',
          src: '{,*/}*.css',
          dest: '.tmp/styles/'
        }]
    }

    copy: {
      test: {
        files:[{
          expand: true
          cwd: '.tmp'
          dest: '<%= ntes.dist %>/'
          src: [
            'scripts/{,*/}*.js'
            'styles/{,*/}*.css'
          ]
        },{
          expand: true
          cwd: '<%= ntes.app %>'
          dest: '<%= ntes.dist %>/'
          src: [
            'images/{,*/}*.*', 'scripts/{,*/}*.js'
          ]
        }]
      }
      dist: {
        files: [{
          expand: true
          cwd: '.tmp'
          dest: '<%= ntes.dist %>/<%= ntes.version %>'
          src: [
            'scripts/{,*/}*.js'
            'styles/{,*/}*.css'
          ]
        },{
          expand: true
          cwd: '<%= ntes.app %>'
          dest: '<%= ntes.dist %>/<%= ntes.version %>'
          src: [
            'images/{,*/}*.*'
          ]
        }]
      }
      styles: {
        expand: true
        cwd: '<%= ntes.app %>/styles',
        dest: '.tmp/styles/',
        src: '{,*/}*.css'
      }
      js: {
        expand: true,
        cwd: '<%= ntes.app %>/scripts',
        dest: '.tmp/scripts/',
        src: '{,*/}*.js'
      }
    }

    ftps_deploy: {
      deploy: {
        options: 
          auth:
            host:'61.135.251.132'
            port: 16321
            authKey: 'key1'
            secure: true
        
        files: [{
          expand: true,
          cwd:'<%= ntes.dist %>',
          src: ['**/*','!**/*.html'],
          dest: '/utf8/3g/touch'
        }]
      }
    }
  }

  grunt.registerTask 'serve', 'Compile then start a connect web server', (target)->
    if target is 'dist'
      grunt.task.run ['build', 'connect:dist:keepalive']
      return

    grunt.task.run([
      'clean:server'
      'react'
      'coffee'
      'less'
      'copy:styles'
      'copy:js'
      'autoprefixer'
      'connect:livereload'
      'watch'
    ])
    return

  grunt.registerTask 'build', (target)->
    if target
      target += '.html' if not /\.html$/.test(target)
      grunt.config.set('htmlbuild.dist.src', "<%=ntes.app%>/#{target}")
    grunt.task.run([
      'clean:dist'
      'react'
      'coffee'
      'less'
      'autoprefixer'
      'uglify'
      'copy:dist'
      'htmlbuild:dist'
    ])

  grunt.registerTask 'deploy', (target)->
    target = '' if not target
    grunt.task.run ['build:' + target, 'ftps_deploy']
    return

  grunt.registerTask 'f2e', (target)->
    done = this.async()
    upload = exec "scp -r -P 16322 dist/* #{appConfig.developer}@223.252.197.245:/home/#{appConfig.developer}/3g/", (error, stdout, stderr)->
      console.log('stdout: ' + stdout)
      console.log('stderr: ' + stderr)
      if error
        console.log('exec error: ' + error)
      else
        console.log('Upload done')
      done()
    return
  grunt.registerTask 'test', (target)->
    html = ""
    if target
      if not /\.html$/.test(target)
        html = target + '.html' 
      grunt.config.set('htmlbuild.test.src', "<%=ntes.app%>/#{html}")
    grunt.task.run([
      'clean:dist'
      'react'
      'coffee'
      'less'
      'autoprefixer'
      # 'uglify'
      'copy:test'
      'htmlbuild:test'
      'f2e'
    ])


