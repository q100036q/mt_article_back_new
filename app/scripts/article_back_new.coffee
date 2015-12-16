
(()->
  alert("修改第一次")
  window.NTES =
    isAndroid: navigator.userAgent.match(/android/ig),
    isNewsapp: navigator.userAgent.match(/NewsApp/ig),
    isIos:navigator.userAgent.match(/iphone|ipod|ipad/ig),
    isWeixin: navigator.userAgent.match(/micromessenger/gi)
    isWeibo: navigator.userAgent.match(/weibo/gi)
    simpleParse: (tpl, values) ->
      if values then String(tpl).replace(/<#=(\w+)#>/g, (($1, $2) ->
        if values[$2] != null then values[$2] else $1
      )) else tpl
    localParam: (search, hash) ->
      search = search or window.location.search
      hash = hash or window.location.hash

      fn = (str, reg) ->
        if str
          data = {}
          str.replace reg, ($0, $1, $2, $3) ->
            data[$1] = $3
            return
          return data
        return

      {
        search: fn(search, new RegExp('([^?=&]+)(=([^&]*))?', 'g')) or {}
        hash: fn(hash, new RegExp('([^#=&]+)(=([^&]*))?', 'g')) or {}
      }
    importJs: (a, b, c) ->
      d = document.createElement('script')
      d.src = a
      c and (d.charset = c)

      d.onload = ->
        @onload = @onerror = null
        @parentNode.removeChild(this)
        b and b(!0)
        return

      d.onerror = ->
        @onload = @onerror = null
        @parentNode.removeChild(this)
        b and b(!1)
        return
      document.head.appendChild(d)
      return
    ajax: (option)->
      if not option.url
        throw new Error('Need for url')
      dataType = option.dataType or 'text'
      method = option.method or 'GET'
      data = ""
      if !!option.data
        for key of option.data
          data += "#{key}=#{option.data[key]}&"
        data = data.slice(0, data.length - 1)
      request = new XMLHttpRequest()
      request.open(method, option.url, true)
      if method.toUpperCase() is 'POST'
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
      request.onload = ->
        if request.status >= 200 and request.status < 400
          if dataType is 'json'
            result = JSON.parse(request.responseText)
          option.success?(result)
        else
          option.error?()
        return
      request.send(data)
      return
)()
# 音频播放器
;((X) ->
  AudioPlayer = (options) ->
    this.wrap = options.wrap
    this.src = options.src
    this.cover = options.cover 
    this.onplayhead = false
    this.doms = {}
    this.duration = 0
    this.init()
    return this
  AudioPlayer.prototype.reset = (newSrc) ->
    this.doms.music.src = newSrc
    if not this.isPlaying()
      this.play()
    return this

  AudioPlayer.prototype.init = ->
    that = this
    style = ''
    if this.cover
      style = "background-image: url(#{this.cover});background-size: cover;"
    this.wrap.innerHTML = '\
      <audio class="music" src="' + this.src + '"></audio>\
      <div class="radio-box">
        <div class="scrubber">\
          <div class="progress"></div><i class="playhead"></i>\
          <div class="loaded"></div>\
          <div class="time-length">\
            <span class="time-progress">00:00</span>\
            <span class="time-all"></span>\
          </div>\
        </div>\
        <div class="play-pause play">\
          <div class="btn"></div><span class="background" style="'+style+'"></span>\
        </div>\
      </div>'
    this.wrap.offsetWidth
    this.doms = {
      music: this.wrap.querySelector('.music'),
      pButton: this.wrap.querySelector('.btn'),
      timeline: this.wrap.querySelector('.scrubber'),
      playhead: this.wrap.querySelector('.playhead'),
      audioplayer: this.wrap.querySelector('.radio-box')
    }
    eventBind.call(this)
    window.cancelRequestAnimFrame = ( ->
      window.cancelAnimationFrame          ||
        window.webkitCancelRequestAnimationFrame    ||
        clearTimeout
    )()
    window.requestAnimFrame = ( ->
      window.requestAnimationFrame       || 
        window.webkitRequestAnimationFrame || 
        (callback,element) ->
          window.setTimeout(callback, 1000 / 60)
    )()


  AudioPlayer.prototype.play = ->
    music = this.doms.music
    playPause = this.wrap.querySelector('.play-pause')
    # start music
    if music.paused 
      music.play()
      playPause.classList.remove('play')
      playPause.classList.add('pause')
    else 
      # pause music
      music.pause()
      playPause.classList.remove('pause')
      playPause.classList.add('play')
    return this
  AudioPlayer.prototype.isPlaying = ->
    !this.doms.music.paused
  AudioPlayer.prototype.isEnded = ->
    this.doms.music.ended
  eventBind = ->
    doms = this.doms
    that = this
    timer = null
    timelineWidth = doms.timeline.offsetWidth - doms.playhead.offsetWidth
    touchMove = (e)->
      e.preventDefault()
      movePlayhead(e.touches[0])
      return
    touchEnd = (e) ->
      if that.onplayhead == true
        movePlayhead(e.changedTouches[0])
        doms.music.addEventListener('timeupdate', timeUpdate, false)
        doms.music.currentTime = that.duration * clickPercent(e.changedTouches[0])
        doms.playhead.removeEventListener('touchmove', touchMove, false)
      cancelRequestAnimFrame(timer)
      that.onplayhead = false
      return
    touchStart = (e) ->
      e.preventDefault()
      that.onplayhead = true
      doms.playhead.addEventListener('touchmove', touchMove, true)
      doms.playhead.addEventListener('touchend', touchEnd, false)
      doms.music.removeEventListener('timeupdate', timeUpdate, false)
      drawPlayhead()
      return
    
    clickPercent = (e) ->
      (e.pageX - doms.timeline.offsetLeft) / timelineWidth
    movePlayhead = (e) ->
      newMargLeft = e.pageX - that.doms.timeline.offsetLeft
      that.distX = newMargLeft
      return
    drawPlayhead = ->
      newMargLeft = that.distX
      if newMargLeft >= 0 and newMargLeft <= timelineWidth
        doms.playhead.style.marginLeft = newMargLeft + "px"
        that.wrap.querySelector('.progress').style.width = newMargLeft + 'px'
      if newMargLeft < 0
        doms.playhead.style.marginLeft = "0px"
        that.wrap.querySelector('.progress').style.width = '0'
      if newMargLeft > timelineWidth
        doms.playhead.style.marginLeft = timelineWidth + "px"
        that.wrap.querySelector('.progress').style.width = timelineWidth + 'px'
      timer = window.requestAnimFrame(drawPlayhead)
      return

    timeUpdate = ->
      playPercent = timelineWidth * (doms.music.currentTime / that.duration)
      doms.playhead.style.marginLeft = playPercent + "px"
      that.wrap.querySelector('.progress').style.width = playPercent + 'px'
      that.wrap.querySelector('.time-progress').textContent = getTime(that.doms.music.currentTime)
      if doms.music.currentTime == that.duration
        doms.pButton.classList.remove('pause')
        doms.pButton.classList.add('play')
        return
    getTime = (time) ->
      time = Math.floor(time)
      min = Math.floor(time / 60)
      sec = time % 60
      if min < 10 then min = '0' + min
      if sec < 10 then sec = '0' + sec
      return time = min + ':' + sec

    doms.music.addEventListener("timeupdate", timeUpdate, false)
    doms.pButton.addEventListener('click', this.play.bind(this), false)
    doms.timeline.addEventListener("click", (e) ->
      movePlayhead(e)
      doms.music.currentTime = that.duration * clickPercent(e)
      return
    ,false)
    doms.playhead.addEventListener('touchstart', touchStart, false)
    document.addEventListener('touchmove', (e) ->
      if that.onplayhead
        e.preventDefault()
        return
    ,false)
    doms.music.addEventListener("loadedmetadata", ->
      that.duration = doms.music.duration
      that.wrap.querySelector('.time-all').textContent = getTime(that.duration)
      return
    ,false)
    doms.music.addEventListener("canplaythrough", ->
      that.duration = doms.music.duration
      that.wrap.querySelector('.time-all').textContent = getTime(that.duration)
      return
    ,false)

    return
  window.AudioPlayer = AudioPlayer
  
  # X(document).on 'click',".btn", ->
  #   audio.reset('http://audio.m.126.net/201507/23/6bd256d99f1296652e20bf6c07deb6a2.mp3')
  #   return
  return
)($);
(->
  search = NTES.localParam().search
  uri = 'newsapp://doc/' + search.docid
  if search.videoid
    uri = 'newsapp://video/' + search.videoid
  if search.videoid and NTES.isAndroid
    uri = 'newsapp://startup'
  if navigator.userAgent.match(/safari/ig) and not navigator.userAgent.match(/yixin/ig) and +search['no'] isnt 1
    document.getElementById('iframe').src = uri

  # 判断URL中含有&o=1时，打开客户端
  if +search['o'] is 1
    search = NTES.localParam().search
    uri = "newsapp://doc/#{search.docid}"
    if search.videoid
      uri = "newsapp://video/#{search.videoid}"
    if search.videoid and NTES.isAndroid
      uri = 'newsapp://startup'

    if NTES.isWeixin
        window.location.href = "http://3g.163.com/ntes/special/0034073A/weixinopen.html?uri=#{uri}"
    else
      $('#iframe').attr 'src', uri
)()

# 文章内容
;((X) ->
  #分页
  pageBtnCtrl = (pcount) ->
    if pcount is 1
      X("#pageArea").css('display', 'none')
      return
    X("#pageArea .tNum").text pcount
    pNum = X(".pNum")
    pNumShow = 0
    X("#pageArea").on "click", ".pbtn", ->
      
      #翻页
      if X(this).hasClass("pbtn-pre") #是否上一页按钮
        unless X(this).hasClass("pbtn-pre-end") #是否是第一页
          X(".pbtn-next").removeClass "pbtn-next-end" #下一页按钮可点击
          pNumShow = parseInt(pNum.html())
          pNum.html pNumShow - 1 #页数加少
          X(this).addClass "pbtn-pre-end"  if pNumShow - 1 is 1 #页数为1时上一页按钮不可点击
          pageBuild pNumShow - 1
          scrollTo 0, 1
      if X(this).hasClass("pbtn-next") #是否下一页按钮
        unless X(this).hasClass("pbtn-next-end") #是否最后一页
          X(".pbtn-pre").removeClass "pbtn-pre-end" #上一页按钮可点击
          pNumShow = parseInt(pNum.html())
          pNum.html pNumShow + 1 #页数增加
          X(this).addClass "pbtn-next-end"  if pNumShow + 1 is pcount #页数为最大页数时下一页按钮不可点击
          pageBuild pNumShow + 1
          scrollTo 0, 1
      return

    showAllArticle() #显示全部文章
    return
  pageBuild = (pageNum) ->
    X(".page-content").removeClass "page-on"
    X(".page-content").eq(pageNum - 1).addClass "page-on"
    return
  showAllArticle = ->
    showAllArticle = X("#showAllArticle")
    showAllArticle.on "click", ->
      X(".page-content img").each (e)->
        if not this.src
          this.src = this.dataset.src or 'about:blank'
      X(".page-content").addClass "page-on"
      X("#pageArea").css('display', 'none')
      return

    return
  
  # 视频
  videoControl = ->
    X(".video-holder").click ->
      X("#video")[0].play()
      X("#video")[0].webkitEnterFullscreen()
      return

    # X(".play-btn").css({display:'none'});
    X(".play-btn").click ->
      X("#video")[0].play()
      return

    document.onwebkitfullscreenchange = ->
      X("#video")[0].pause()
      return

    return
  
  # 投票
  buildVoteHtml = (voteid)->
    X.getJSON "http://3g.163.com/touch/vote/detail/#{voteid}.html", (data)->
      optionHtml = ''
      data.voteItems.forEach (item, i)->
        if +data.isVoteOver is 0
          optionHtml += """
            <li data-id="#{item.id}" data-votenum="#{item.votenum}">#{i + 1}. #{item.name} <i class=""></i></li>
          """
        else
          rate = item.votenum * 100 / data.sumnum
          optionHtml += """
            <li>
              <div>#{i + 1}. #{item.name} </div>
              <div class="bar"><span style="width: #{rate}%"></span> #{rate.toFixed(0)}%</div>
            </li>
          """
        return
      html = """
        <div><span class="title">#{data.question}</span><span class="type">#{if data.optionType then "多选" else "单选"}</span></div>
      """
      if +data.isVoteOver is 0
        #投票有效
        html += """
          <div><span class="subtitle">#{data.beginDate.slice(0, 10)} &nbsp; 投票进行中</span><span class="count">#{data.sumnum} 人</span></div>
          <ol class="unvoted">
            #{optionHtml}
          </ol> 
        """
        if +data.optionType isnt 0
          # 多选
          html += """
            <div class="submit">提交并查看结果</div>
          """
      else
        #投票无效
        html += """
          <div><span class="subtitle">#{data.beginDate.slice(0, 10)} &nbsp; 投票已结束</span><span class="count">#{data.sumnum} 人</span></div>
          <ol class="voted show">
            #{optionHtml}
          </ol> 
        """
      X("[data-voteid=\"#{data.voteid}\"] .content").html html
      X("[data-voteid=\"#{data.voteid}\"]").attr('data-optiontype', data.optionType)
    return
  voteEvent = ->
    voteResult = (dom)->
      NTES.importJs("http://c.3g.163.com/nc/jsonp/vote/result/#{dom.dataset.voteid}.html")
      window.vote_result = (data)->
        window.vote_result = null
        html = ''
        data.voteitem.forEach (item, i)->
          rate = item.num * 100 / data.sumnum
          html += """
            <li>
              <div>#{i + 1}. #{item.name} </div>
              <div class="bar"><span style="width: #{rate}%"></span> #{rate.toFixed(0)}%</div>
            </li>
          """
          return
        X(dom).find('ol').attr('class', 'voted').html html
        setTimeout ->
          X(dom).find('.voted').addClass('show')
        , 100
        return
      return

    X('.type-vote').click (event)->
      voteid = this.dataset.voteid
      voteType = this.dataset.optiontype
      target = X(event.target)
      if target.hasClass('submit')
        options = ''
        if X(this).find('li.active').length is 0
          return
        if X(this).find('li').length is X(this).find('li.active').length
          return
        X(this).find('li.active').forEach (item)->
          options = options + item.dataset.id + ','
          return
        options = options.slice(0, -1)
        NTES.importJs("http://vote.3g.163.com/vote2/mobileVote.do?vote#{voteid}=#{options}&voteId=#{voteid}")
        voteResult(this)
        target[0].style.display = 'none'
      if event.target.tagName.toUpperCase() is 'LI'
        if +voteType
          # 多选
          target.toggleClass('active')
        else
          # 单选
          X(this).removeClass('active')
          target.addClass('active')
          NTES.importJs("http://vote.3g.163.com/vote2/mobileVote.do?vote#{voteid}=#{target.data('id')}&voteId=#{voteid}")
          voteResult(this)

      return
    return
  index = 0
  loading = true
  Next = false
  pageCount = 1
  docid = NTES.localParam().search['docid']
  contentHolder = X(".text1")
  sitemapUrl = "http://3g.163.com/touch/sitemap/main.html"
  artiUrl = "http://3g.163.com/touch/article/" + docid + "/full.html"
  tailUrl = "http://3g.163.com/touch/article/" + docid + "/full.html"
  tpl =
    imgList: "<div class=\"photoNews\"><img class=\"photoImg\" alt=\"<#=alt#>\" src=\"http://img2.cache.netease.com/3g/2015/11/2/20151102141437e4822.png\" data-echo=\"<#=src#>\" width=\"<#=pixelW#>\" height=\"<#=pixelH#>\"><div class=\"photo_mag\" style=\"display:block;\"><#=alt#></div></div>"
    liveLink: "<a style=\"color:blue;\" href=\"<#=href#>\" title=\"<#=title#>\" class=\"liveLink\"><#=title#></a>"
    sugNews: "<li><a href=\"http://3g.163.com/touch/article.html?from=article.hotnews&docid=<#=sDocid#>\"><#=sTitle#></a></li>"
    relNews: "<li><a href=\"http://3g.163.com/touch/article.html?from=article.relate&docid=<#=rDocid#>\"><#=rTitle#></a></li>"
    sitemapLink: "<a href=\"http://3g.163.com/touch/<#=curl#>/?from=article.sitemap\"><#=cname#></a>"
    sitemapOuterLink: "<a href=\"<#=curl#>\"><#=cname#></a>"
    replyLink: "http://3g.163.com/touch/comment.html?docid=<#=docid#>&board=<#=board#>&title=<#=title#>&from=article"
    albumTpl: "<div class=\"albumholder\"><a href=\"http://3g.163.com/touch/photoview.html?setid=<#=albumId#>&channelid=<#=channelId#>&from=article\"><img src=\"<#=cover#>\" width=\"100%\"/></a><span>图集</span></div>"
    audio: "<div class=\"audio-holder\"><audio  controls=\"controls\" src=\"<#=url_mp4#>\" style=\"width:100%\"></audio><span class=\"audio-comment\"><#=alt#></span> </div>"
    video: "<span class=\"video-holder\"><#=playbtntpl#><video  id=\"video\" src=\"<#=url_mp4#>\" poster=\"<#=cover#>\" style=\"width:100%\"></video></span>"
    links: "<a class=\"news-links\" href=\"<#=links_href#>\"><#=links_title#></a>"
    vote: """
      <div><span class="v-title"><#=title#></span><span class="v-type"><#=type#></span></div>
      <div><span class="v-subtitle"><#=time#> &nbsp; <#=progress#></span><span class="v-count"><#=count#></span></div>
      <ol>
        <#=options#>
      <ol> 
    """
  # docid截端跳转
  window.location.href = "http://3g.163.com/ntes/13/0109/15/8KPP95RR00963VRO.html"  if docid is "http://news.163.com/special/2012home/"

  fillContent = (data)->
    if data.template and data.template is 'webview'
      window.location.href = data.links[0].href
    X("title").html data.title
    X(".article-title").html data.title
    X(".time").html data.ptime.substr(0, 16)
    X(".source").html data.source
    X(".replyCount").text data.replyCount or 0
    X(".article-digest").text data.digest or ''
    X(".replyLink").attr "href", NTES.simpleParse(tpl.replyLink,
      docid: docid
      board: data.replyBoard
      title: encodeURIComponent(data.title)
    )
    actualWidth = X(".f-w").width()
    # 获取正文内容
    data.body = data.body.replace(/<p>(\s*)/g, '<p>')
    # 图片输出
    data.body = data.body.replace(/<!--IMG#(\d+)-->/g, ($0, $1) ->
      index = $1  unless $1 is index
      cimg = data.img[index++]
      _w = cimg.pixel.split("*")[0]
      _h = cimg.pixel.split("*")[1]
      NTES.simpleParse tpl.imgList,
        pixelW: _w
        pixelH: actualWidth * _h / _w
        alt: cimg.alt or ''
        src: cimg.src
    )
    # 视频输出
    data.body = data.body.replace(/<!--VIDEO#(\d+)-->/g, ($0, $1) ->
      index = $1  unless $1 is index
      cmedia = data.video[index++]
      if cmedia.url_mp4.match(/.mp3/g)
        NTES.simpleParse tpl.audio,
          url_mp4: cmedia.url_mp4
          alt: cmedia.alt

      else
        if NTES.isAndroid
          playbtn = "<div class=\"play-btn\"></div>"
        else
          playbtn = ""
        NTES.simpleParse tpl.video,
          cover: cmedia.cover
          url_mp4: cmedia.url_mp4
          playbtntpl: playbtn

    )
    # 投票
    data.body = data.body.replace /<!--@@VOTEID=(\d*)-->/g, ($0, $1)->
      buildVoteHtml($1)
      return """
        <div class="type-vote" data-voteid="#{$1}">
          <div class="u-title">投票</div>
          <div class="content">
            投票加载中...
          </div>
        </div>
      """

    # 分页
    data.body = data.body.replace(/<!--splitpage-->/g, ($0, $1) ->
      pageCount++
      "</div><div class=\"page-content\">"
    )

    # 图集
    data.body = data.body.replace(/<!--photoSet#(\d+)-->/g, ($0, $1) ->
      index = $1  unless $1 is index
      calbum = data.photoSetList[index++]
      NTES.simpleParse tpl.albumTpl,
        cover: calbum.cover
        albumId: calbum.photosetID.split("|")[1]
        channelId: calbum.photosetID.split("|")[0]

    )
    findEstateInfo = (e)->
      t = {
        AUTODEALER: "",
        ADDRESS: "",
        TEL: "",
        EXT: "",
        LINKURL: "",
        PRICE: ""
      };
      i = e.match(/AUTODEALER=["|“|”].*?["|“|”]/)?[0];
      t["AUTODEALER"] = i?.substring(12, i.length - 1) or '';
      s = e.match(/ADDRESS=["|“|”].*?["|“|”]/)?[0];
      t["ADDRESS"] = s?.substring(9, s.length - 1) or '';
      o = e.match(/TEL=["|“|”].*?["|“|”]/)?[0];
      t["TEL"] = o?.substring(5, o.length - 1) or '';
      n = e.match(/EXT=["|“|”].*?["|“|”]/)?[0];
      t["EXT"] = n?.substring(5, n.length - 1) or '';
      l = e.match(/LINKURL=["|“|”].*?["|“|”]/)?[0];
      t["LINKURL"] = l?.substring(9, l.length - 1) or '';
      a = e.match(/PRICE=["|“|”].*?["|“|”]/)?[0];
      t["PRICE"] = a?.substring(7, a.length - 1) or '';
      return t

    # 房产
    data.body = data.body.replace(/<!--@@AUTODEALER.*?-->/g, (a)->
      obj = findEstateInfo(a)
      return """
        <div class="house_detail">
          <div class="house_detail_title">
            <a href="#{obj.LINKURL}">#{obj.AUTODEALER}</a>
            <span>#{obj.PRICE}</span>
          </div>
          <div class="house_detail_position">
            <span class="icon"></span>
            <span>#{obj.ADDRESS}</span>
          </div>
          <div class="house_detail_phone">
            <a href="javascript:window.location = 'tel:\\\\#{obj.TEL},#{obj.EXT}';">
              <span class="phone_bg">
                <span class="icon"></span>
                <span>#{obj.TEL}</span>
              </span>
              转#{obj.EXT}
            </a>
            <span class="rz">官方认证</span>
          </div>
        </div>
      """
    )

    # 链接
    data.body = data.body.replace(/<!--link(\d+)-->/g, ($0, $1) ->
      index = $1  unless $1 is index
      clinks = data.links[index++]
      NTES.simpleParse tpl.links,
        links_href: clinks.href
        links_title: clinks.title
    )
    # 表格
    data.body = data.body.replace /<table/g, ($0)->
      return '<div class="table-wrapper">' + $0
    data.body = data.body.replace /<\/table>/g, ($0)->
      return $0 + '</div>'

    # 物品
    data.body = data.body.replace /<!--GOOD#(\d+)-->/g, ($0, $1) ->
      index = $1  unless $1 is index
      cgood = data.good[index++]
      return """
        <div class="m-good open-newsapp" data-href="http://3g.163.com/newsapp">
          <div class="good-data">
            <div class="good-title">#{cgood.title}</div>
            <div class="good-desc">#{cgood.desc}</div>
            <div class="good-time">有效期：#{cgood.beginDate} 至 #{cgood.endDate}</div>
          </div>
          <div class="buy-now">立即购买</div>
        </div>
      """

    # 店铺
    data.body = data.body.replace /<!--STORE#(\d+)-->/g, ($0, $1) ->
      index = $1  unless $1 is index
      cstore = data.store[index++]
      style = ''
      if cstore.info[0].icon and cstore.info[0].icon isnt ''
        style = "background-image:url(#{cstore.info[0].icon});background-size: cover;"
      return """
        <div class="m-store open-newsapp" data-href="http://3g.163.com/newsapp">
          <a class="down">
            <div class="store-name">
              <i class="avatar" style="#{style}"></i>
              <span>#{cstore.info[0].name}</span>
            </div>
            <div class="store-tel">
              <span>#{cstore.info[0].tel}</span>
            </div>
            <div class="store-address">
              <span>#{cstore.info[0].address}</span>
            </div>
            <div class="view-all">查看全部适用分店</div>
          </a>
        </div>
      """

    # 本地宝相关新闻
    if data.localRec and data.localRec.length > 0
      localHtml = ''
      data.localRec.forEach (item)->
        className = 'rec' if item.recType
        localHtml += """
          <li class="type#{item.msgType} #{className}">
            <a href="http://3g.163.com/ntes/special/0034073A/localback.html?docid=#{item.docId}">
              <div class="img-wrap">
                <img src="#{item.img}" onerror="this.src='http://img2.cache.netease.com/3g/img11/3gtouch13/default.jpg'">
              </div>
              <div class="news-wrap">
                <div class="news-title">#{item.title}</div>
                <div class="news-subtitle">#{item.storeName}</div>
                <span class="news-tip">#{item.recType}</span>
              </div>
            </a>
          </li>
        """
        return
      
      X('.m-relative .list').html(localHtml)
      X('.m-relative').show()


    # 相关新闻
    data.body = data.body.split(/<p>\s*\*相关新闻<\/p>/)
    if data.body.length > 1
      X('.relative-news').show()
      X('.relative-news .list').html(data.body[1])
      X('.relative-news a').each ->
        this.href = this.href + '&from=wechat_article.related'
    data.body = data.body[0]

    # 又一个相关新闻
    if data.relative and data.relative.length > 0
      relativeHtml = ''
      data.relative.forEach (item)->
        relativeHtml += """
          <li>
            <a href="http://3g.163.com/touch/article.html?from=wechat_article.relative&docid=#{item.id}">#{item.title}</a>
          </li>
        """
        return
      X('.m-related ul').html relativeHtml
      X('.m-related').show()

    isWinPhone = navigator.userAgent.match(/Windows Phone/g)

    # 直播链接
    j = 0
    while data.liveLink and j < data.liveLink.length
      reg_link = new RegExp("<!--LiveLink#" + j + "-->", "g")
      if NTES.isIos or NTES.isAndroid or isWinPhone
        liveLinkHref = "http://3g.163.com/ntes/special/00340BF8/seventlive.html?roomid=" + data.liveLink[j].href.split("/")[5]
      else
        liveLinkHref = data.liveLink[j].href
      tplLiveLinkHtml = NTES.simpleParse(tpl.liveLink,
        href: liveLinkHref
        title: '正在直播：' + data.liveLink[j].title
      )
      data.body = data.body.replace(reg_link, tplLiveLinkHtml)
      j++
    contentHolder.prepend "<div class='page-content page-on'>" + data.body + "</div>"
    X('.page-content.page-on img').each ()->
      if not this.src
        this.src = this.dataset.src or 'about:blank'
    videoControl() #视频调用
    pageBtnCtrl pageCount #分页
    voteEvent() # 投票事件绑定

    if loading
      # 客户端显示操作
      if NTES.isNewsapp
        X("header").css "display", "none"

      # 显示全文
      X(".articleList").css display: "block"
      X("#contentHolder").css display: "block"
      X('#mask').css display: "none"

      loading = false
      X('.firstScreen').hide()
    if data.hasNext
      X("#nextPage").css "display", "block"
      X("#nextPage").click ->
        X("#nextPage").css "display", "none"
        NTES.importJs tailUrl
        Next = true
        return
    return
  window.artiContent = (d) ->
    return unless d
    data = d[docid]
    if data.body == undefined
      window.location.href = "http://3g.163.com/ntes/special/0034073A/back_list.html?notfound"
    if NTES.localParam().search['tid']
      window.setShareData('【电台】' + data.title, '【电台】' + data.body, 'http://img4.cache.netease.com/utf8/3g/touch/images/radio.png')
      window.posthandle d[docid].replyBoard, docid  if typeof posthandle isnt "undefined"
      tid = NTES.localParam().search['tid']
      NTES.ajax
        method: 'GET'
        url: "http://3g.163.com/touch/audio/list/relate/#{tid}.html"
        dataType: 'json'
        success: (data)->
          audioRecommend(data)
          return
      #音频回流页
      audioBodyContent(data)
      $('#contentHolder').addClass('audio').show()
      $('.firstScreen').hide()
    else
      window.setShareData(data.title, data.body)
      fillContent(data)
      if docid.substring(8,10) isnt '06'
        posthandle d[docid].replyBoard, docid  if typeof posthandle isnt "undefined"
    return
  videoid = NTES.localParam().search['videoid']
  if docid
    if docid.substring(8,10) is '06'
      #本地宝回流页
      X('body').addClass('localback')
      NTES.importJs "http://3g.163.com/touch/article/#{docid}/full.html"
    else
      #正常页
      NTES.importJs artiUrl
  else 
    if videoid
      if videoid.length > 9
        videoid = 'V' + videoid.slice(0, 8)
      # 视频回流页
      NTES.ajax
        method: 'GET'
        url: "http://3g.163.com/touch/video/detail/#{videoid}.html"
        dataType: 'json'
        success: (data)->
          window.posthandle(data.replyBoard, data.replyid)
          videoBodyContent(data)
          videoRecommend(data)
          window.setShareData('【视频】' + data.title, '', 'http://img4.cache.netease.com/utf8/3g/touch/images/video.png')

          $('#contentHolder').addClass('video').show()
          $('.firstScreen').hide()
          return

  videoBodyContent = (data)->
    holder = $('#contentHolder')
    holder.find('.articleList').hide()
    if NTES.isIos
      icon = ''
    else
      icon = '<span class="u-video-icon"></span>'
    $('.replyCount').text data.replyCount
    time = Math.floor(data.length / 60) + ':' + data.length % 60
    holder.prepend """
      <div class="m-video-holder">
        <div class="video-wrap">
          <video src="#{data.mp4_url}" poster="#{data.cover}"></video>
          #{icon}
        </div>
        <div class="video-title">#{data.title}</div>
        <div class="video-subtitle">
          <span>##{data.videotype} #{time}</span><span class="reply">#{data.replyCount}跟贴</span>
        </div>
      </div>
    """
    holder[0].offsetWidth
    holder.find('video').on 'click', (e)->
      this.play()
      this.webkitEnterFullscreen()
      return
    document.onwebkitfullscreenchange = ->
      holder.find('video')[0].pause()
      return
    return
  videoRecommend = (data)->
    html = ''
    return unless data.recommend?.length > 0
    data.recommend.forEach (item)->
      time = Math.floor(item.length / 60) + ':' + item.length % 60
      html += """
        <li>
          <a class="clearfix" href="http://3g.163.com/ntes/special/0034073A/wechat_article.html?videoid=#{item.videoid}">
            <div class="cover">
              <img src="#{item.cover}" />
              <span class="u-video-icon"></span>
            </div>
            <div class="info">
              <div class="title">#{item.title}</div>
              <div class="subtitle">##{item.videotype}  #{time}</div>
            </div>
          </a>
        </li>
      """
      return
    $('.m-video-recommond .list').html html
    $('.m-video-recommond').show()
    return
  
  audio = null
  audioBodyContent = (data)->
    holder = $('#contentHolder')
    holder.find('.articleList').hide()
    holder.prepend """
      <div class="m-audio-holder"></div>
      <ul class="m-audio-list"></ul>
      <div class="m-down">
        <a data-href="http://3g.163.com/newsapp" class="open-newsapp" onclick="neteaseTracker(false, 'http://3g.163.com/ntes/special/0034073A/wechat_article.html?action=radioDownButton', 'article_back', 'wap')">
          打开网易新闻,收听更多电台节目
        </a>
      </div>
    """
    holder[0].offsetWidth
    docid = NTES.localParam().search['docid']
    tid = NTES.localParam().search['tid']
    $('.m-audio-list').prepend """
      <li>
        <a href="http://3g.163.com/ntes/special/0034073A/wechat_article.html?docid=#{docid}&tid=#{tid}">
          <div class="title ellipsis">#{data.title}</div>
          <div class="time">#{data.ptime.slice(0, 10)}</div>
        </a>
      </li>
    """
    setTimeout ->
      audio = new window.AudioPlayer({wrap: holder.find('.m-audio-holder')[0], src: data.video[0]?.url_mp4, cover: data.video[0]?.cover})
    , 100

    return
  audioRecommend = (data)->
    html = ''
    tid = NTES.localParam().search['tid']
    data[tid].forEach (item)->
      html += """
        <li>
          <a href="http://3g.163.com/ntes/special/0034073A/wechat_article.html?docid=#{item.docid}&tid=#{tid}">
            <div class="title ellipsis">#{item.title}</div>
            <div class="time">#{item.ptime.slice(0, 10)}</div>
          </a>
        </li>
      """
      return
    $('.m-audio-list').append(html)
    return
  return
) $

# 跟帖
;((X) ->
  window.posthandle = (replyBoard, docid) ->
    return if not replyBoard
    window.hotList = (data) ->
      window.hotList = null
      holder = document.querySelector(".comment-list")
      if +data.code isnt 1
        X('.m-comment').hide()
        X('.m-down-tie').hide()
        return
      posts = data["hotPosts"]
      if not posts or posts.length is 0
        X('.m-comment').hide()
        X('.m-down-tie').hide()

        return
      html = ''
      posts.forEach (_item)->
        i = 1
        while _item[i]
          item = _item[i]
          i++
        tags = ''
        classList = ''
        if item.label
          tagkey = JSON.parse(item.label)
          className = ''
          tagkey.forEach (_index) ->
            className = 'tagkey-' + _index.tagKey
            classList += _index.tagKey + ' '
            tags += """
              <span class="#{className}"></span>
            """
            return
        tags = "<span class='tagkey-wrap' data-tags='#{classList.slice(0, -1)}'>#{tags}</span>"
        names = item.f.trim().replace('：','').split('&nbsp;')
        if names.length > 1
          username = names[1]
          p = "<p>#{names[0]}[#{username}]#{tags}</p>"
        else
          p = "<p>#{names[0]}#{tags}</p>"
        content = item.b
        # if content.length > 42
        #   content = content.slice(0,58) + '...'
        html += """
          <div class="comment-item ui-item">
            <div class="item-title">
              <div class="avatar"></div>
              <div class="name">#{p}</div>
              <div class="ding">#{item.v or 0}顶</div>
            </div>
            <div class="comment-content">#{content}</div>
          </div>
        """
        return
      $('.comment-list').html(html)
      $('.comment-list').on 'click', '.tagkey-wrap', ->
        tags = {
          '100': '地域汪'
          '101': '日美喵'
          '102': '50分'
          '103': '二楼'
          '104': '才子'
          '105': '大湿'
        }
        classList = this.dataset.tags.split(' ')
        html = ''
        classList.forEach (item)->
          html += "#{tags[item]}<span class=\"tagkey-#{item}\"></span>、"
        html = html.slice(0, -1)
        $('.tagkey-box').find('.js-html').html html
        $(".tagkey-box,.overlay").show()
        return
      $('.close,.overlay').on 'click', ->
        $(".tagkey-box,.overlay").hide()
        return

    NTES.importJs "http://comment.api.163.com/api/jsonp/post/list/hot/" + replyBoard + "/" + docid + "/0/3/7/3/1/hotList"
    return

  return
)($);

# 分享
((X)->
  # 图片延迟加载
  (()->
    ((root, factory) ->
      if typeof define == 'function' and define.amd
        define ->
          factory root
      else if typeof exports == 'object'
        module.exports = factory
      else
        root.echo = factory(root)
      return
    ) this, (root) ->
      'use strict'
      echo = {}

      callback = ->

      offset = undefined
      poll = undefined
      delay = undefined
      useDebounce = undefined
      unload = undefined

      isHidden = (element) ->
        element.offsetParent == null

      inView = (element, view) ->
        if isHidden(element)
          return false
        box = element.getBoundingClientRect()
        box.right >= view.l and box.bottom >= view.t and box.left <= view.r and box.top <= view.b

      debounceOrThrottle = ->
        if !useDebounce and ! !poll
          return
        clearTimeout poll
        poll = setTimeout((->
          echo.render()
          poll = null
          return
        ), delay)
        return

      echo.init = (opts) ->
        opts = opts or {}
        offsetAll = opts.offset or 0
        offsetVertical = opts.offsetVertical or offsetAll
        offsetHorizontal = opts.offsetHorizontal or offsetAll

        optionToInt = (opt, fallback) ->
          parseInt opt or fallback, 10

        offset =
          t: optionToInt(opts.offsetTop, offsetVertical)
          b: optionToInt(opts.offsetBottom, offsetVertical)
          l: optionToInt(opts.offsetLeft, offsetHorizontal)
          r: optionToInt(opts.offsetRight, offsetHorizontal)
        delay = optionToInt(opts.throttle, 250)
        useDebounce = opts.debounce != false
        unload = ! !opts.unload
        callback = opts.callback or callback
        echo.render()
        if document.addEventListener
          root.addEventListener 'scroll', debounceOrThrottle, false
          root.addEventListener 'load', debounceOrThrottle, false
        else
          root.attachEvent 'onscroll', debounceOrThrottle
          root.attachEvent 'onload', debounceOrThrottle
        return

      echo.render = ->
        nodes = document.querySelectorAll('img[data-echo], [data-echo-background]')
        length = nodes.length
        src = undefined
        elem = undefined
        view = 
          l: 0 - (offset.l)
          t: 0 - (offset.t)
          b: (root.innerHeight or document.documentElement.clientHeight) + offset.b
          r: (root.innerWidth or document.documentElement.clientWidth) + offset.r
        i = 0
        while i < length
          elem = nodes[i]
          if inView(elem, view)
            if unload
              elem.setAttribute 'data-echo-placeholder', elem.src
            if elem.getAttribute('data-echo-background') != null
              elem.style.backgroundImage = 'url(' + elem.getAttribute('data-echo-background') + ')'
            else
              elem.src = elem.getAttribute('data-echo')
            if !unload
              elem.removeAttribute 'data-echo'
              elem.removeAttribute 'data-echo-background'
            callback elem, 'load'
          else if unload and ! !(src = elem.getAttribute('data-echo-placeholder'))
            if elem.getAttribute('data-echo-background') != null
              elem.style.backgroundImage = 'url(' + src + ')'
            else
              elem.src = src
            elem.removeAttribute 'data-echo-placeholder'
            callback elem, 'unload'
          i++
        if !length
          echo.detach()
        return

      echo.detach = ->
        if document.removeEventListener
          root.removeEventListener 'scroll', debounceOrThrottle
        else
          root.detachEvent 'onscroll', debounceOrThrottle
        clearTimeout poll
        return

      echo

    echo.init
      offset: 100
      throttle: 250
      unload: false
  )()
  _extend = (source, target) ->
    item = undefined
    _results = undefined
    _results = []
    for item of source
      if source.hasOwnProperty(item) and typeof target[item] isnt "undefined"
        _results.push target[item] = source[item]
      else
        _results.push undefined
    _results
  
  shareToSns = (type, _shareData) ->
    _s = []
    for i of _shareData
      _shareData[i]? and _s.push(i.toString() + "=" + encodeURIComponent(_shareData[i].toString() or ""))  if _shareData.hasOwnProperty(i)
    window.open urls[type] + _s.join("&")
    return

  getShareUrl = ->
    url = window.location.origin + location.pathname
    if docid
      url += '?docid=' + docid
    if tid 
      url += '&tid=' + tid
    if videoid
      url +='?videoid=' + videoid

    url +='&s=newsapp'

    w = +NTES.localParam().search['w']
    if w
      w++
      url += '&w=' + w
    else
      url += '&w=1'
      
    return url


  params =
    lofter:
      from: "news"
      title: ""
      content: ""
      sourceUrl: ""
      charset: "utf8"

    wb:
      appkey: "603437721"
      url: ""
      title: ""
      pic: ""

    renren:
      resourceUrl: ""
      title: ""
      description: ""
      pic : ''                         
    qq:
      url: ""
      title: ""
      summary: ""
      pics: ''

    yx:
      type: "webpage"
      url: ""
      title: ""
      desc: ""
      appkey: 'yxb7d5da84ca9642ab97d73cd6301664ad'

    youdao:
      title: ""
      summary: ""

  urls =
    lofter: "http://www.lofter.com/sharetext/?"
    yx: "http://open.yixin.im/share?"
    wb: "http://service.weibo.com/share/share.php?"
    qq: "http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?"
    renren: "http://widget.renren.com/dialog/share?"
    youdao: "http://note.youdao.com/memory?"

  # UC浏览器
  # UCweb广告
  # if NTES.getParameter('platform') is 'ucweb'
  #   if window.ucweb
  #     # Android
  #     X('.uc iframe')[0].src = 'http://tc.uc.cn/?src=http%3A%2F%2Fuc.gre%2Fgre%2Fucshare%2Fhtml%2Fandroid_default_float.html'
  #     X('.uc')[0].style.display = 'block'
  #   else if window.ucbrowser
  #     X('.uc iframe')[0].src = 'http://tc.uc.cn/?src=http%3A%2F%2Fuc.gre%2Fgre%2Fucshare%2Fhtml%2Fiphone_default_float.html'
  #     X('.uc')[0].style.display = 'block'
  isWeixin = navigator.userAgent.match(/micromessenger/gi)
  isWeibo = navigator.userAgent.match(/weibo/gi)
  isYixin = navigator.userAgent.match(/yixin/gi)
  isQQ = navigator.userAgent.match(/qq/gi) and not navigator.userAgent.match(/qqbrowser/gi)
  isQzone = navigator.userAgent.match(/qzone/gi)
  search = NTES.localParam().search
  videoid = search.videoid
  docid = search.docid
  tid = search.tid
  X(document).on 'click', (e)->
    return if e.target.classList.contains('item')
    X('.wx-share').hide()
  shareArea = X('.share-list')
  if isWeixin or isWeibo or isQQ or isQzone
    shareArea.find('.item.wx, .item.wb1').css({'display': 'inline-block'})
    shareArea.find('.item.wb2').hide()
  data = {}
  window.setShareData = (title, body, imgurl)->
    window.setShareData = null
    data.title = title
    body = body or title
    data.body = body.replace(/<.*?>/g, "").replace(/(^\s*)/g, "").substr(0, 30) or data.title
    data.imgurl = imgurl
    return
  shareArea.click (e)->
    e.preventDefault()
    target = e.target
    if target.classList.contains("item")
      type = target.dataset.type
      if isWeibo and (type is 'wx' or type is 'wb')
        X('.wx-share').show()
        return
      # if isWeixin and (type is 'wx' or type is 'qq')
      if isWeixin and (type is 'wx')
        X('.wx-share').show()
        return
      if isQQ or isQzone and type isnt 'wb'
        X('.wx-share').show()
        return
      if isYixin and type is 'yx'
        X('.wx-share').show()
        return
      shareSummary = data.body
      shareTitle = data.title
      shareImg = data.imgurl || "http://img1.cache.netease.com/travel/2014/7/22/20140722172931b2127.png"
      if target.dataset.type
        _extend
          title: shareTitle
          userdesc: shareSummary
          description: shareSummary
          desc: shareSummary
          info: shareSummary
          text: shareSummary
          content: shareSummary
          summary: shareSummary
          pic: shareImg
          pics: shareImg
        , params[type]
      
      url = getShareUrl()
      params["lofter"].sourceUrl = url + "&f=lofter"
      params["wb"].url = url + "&f=wb"
      params["renren"].resourceUrl = url + "&f=renren"
      params["qq"].url = url + "&f=qq"
      params["yx"].url = url + "&f=yx"
      params["youdao"].url = url + "&f=youdao"
      if type is 'wb'
        params['wb'].title = "分享网易新闻：「#{shareTitle}」 @网易新闻客户端"

      spsw = NTES.localParam().search['w'] || 1
      neteaseTracker?(false,'http://sps.163.com/func/?func=sharedone&spss=newsapp&spst=0&docid=' + docid + '&spsw=' + spsw + '&spsf=' + type, '', 'sps')
      # if target.dataset.uc and window.ucweb 
      #   shareTitle = shareTitle.replace('"', '')
      #   offset = X('#contentHolder .page-content').eq(0).offset()
      #   ucweb.startRequest("shell.page_share", [shareTitle, shareSummary, url + '&platform=ucweb' + '&f=' + target.dataset.uc, target.dataset.uc, '', '', 'ucScreen'])
      # else if target.dataset.ios and window.ucbrowser and window.ucbrowser.web_shareEX
      #   shareTitle = shareTitle.replace(/"/g, '')
      #   if target.dataset.ios is 'kWeixinFriend'
      #     shareSummary = shareTitle
      #   link = '{"title":"'+shareTitle+'","content":"'+shareSummary+'","sourceUrl":"'+url + '&platform=ucweb' + '&f=' + target.dataset.ios+'","target":"'+target.dataset.ios+'","imageUrl":"'+shareImg+'"}'
      #   ucbrowser.web_shareEX(link)
      # else if target.dataset.ios and window.ucbrowser and window.ucbrowser.web_share
      #   if target.dataset.ios is 'kWeixinFriend'
      #     shareSummary = shareTitle
      #   alert(X('#ucScreen'))
      #   ucbrowser.web_share(shareTitle, shareSummary, url + '&platform=ucweb' + '&f=' + target.dataset.ios, target.dataset.ios, '', '', 'ucScreen')
      # else
      shareToSns type, params[type]

    return false
  # 微信朋友圈
  (->
    shareUrl = getShareUrl() + '&f=wx'
    imgurl = "http://img1.cache.netease.com/travel/2014/7/22/20140722172931b2127.png"
    document.addEventListener 'WeixinJSBridgeReady', ->
      window.WeixinJSBridge.on 'menu:share:appmessage', (argv)->
        window.WeixinJSBridge.invoke 'sendAppMessage',{
          "img_url": data.imgurl || imgurl,
          "link": shareUrl,
          "desc": data.body,
          "title": data.title
        }, ->
          spss = NTES.localParam().search['s'] || 'newsapp'
          spsw = NTES.localParam().search['w'] || 1
          neteaseTracker?(false,'http://sps.163.com/func/?func=sharedone&spst=0&docid=' + docid + '&spsw=' + spsw + '&spss=' + spss + '&spsf=wx', '', 'sps')

          return
      window.WeixinJSBridge.on 'menu:share:timeline', (argv)->
        window.WeixinJSBridge.invoke 'shareTimeline',{
          "img_url":  data.imgurl || imgurl,
          "img_width": "200",
          "img_height": "200",
          "link": shareUrl,
          "desc": data.body,
          "title": data.title
        }, ()->
          spss = NTES.localParam().search['s'] || 'newsapp'
          spsw = NTES.localParam().search['w'] || 1
          neteaseTracker?(false,'http://sps.163.com/func/?func=sharedone&spst=0&docid=' + docid + '&spsw=' + spsw + '&spss=' + spss + '&spsf=wx', '', 'sps')
    document.addEventListener 'YixinJSBridgeReady', ->
      window.YixinJSBridge.on 'menu:share:appmessage', (argv)->
        window.YixinJSBridge.invoke 'sendAppMessage',{
          "img_url": 'http://img1.cache.netease.com/travel/2014/7/22/20140722172931b2127.png',
          "link": shareUrl,
          "desc": data.body,
          "title": data.title
        }, ->
          spss = NTES.localParam().search['s'] || 'newsapp'
          spsw = NTES.localParam().search['w'] || 1
          neteaseTracker?(false,'http://sps.163.com/func/?func=sharedone&spst=0&docid=' + docid + '&spsw=' + spsw + '&spss=' + spss + '&spsf=wx', '', 'sps')

          return
        return

    return

  )()
  return
)($) 

;((X)->
  search = NTES.localParam().search
  uri = "newsapp://doc/#{search.docid}"
  if search.videoid
    uri = "newsapp://video/#{search.videoid}"
  if search.videoid and NTES.isAndroid
    uri = 'newsapp://startup'
  t = null
  X('.m-body-wrap').on 'click', '.open-newsapp', (e)->
    that = X(this)
    if NTES.isWeixin
      window.location.href = "http://3g.163.com/ntes/special/0034073A/weixinopen.html?uri=#{uri}"
    else
      X('#iframe').attr 'src', uri
      clearTimeout(t) if t
      t = setTimeout( -> 
        window.location.href = that.attr('data-href')
      ,200)
    return

  channelId = NTES.localParam().search['docid']?.slice(8,12)

  channels = {
    '0005': 'sports'
    '0003': 'ent'
    '0025': 'money'
    '0009': 'tech'
  }
  url = 'http://3g.163.com/ntes/special/0034073A/back_list.html?tab=' + ( channels[channelId] or 'headline' )
  X('.m-share .home').attr('href', url)
  return
)($)

# 热门推荐
;((X) ->

  # index = 0
  # loading = false
  # loadMore = ()->
  #   return if loading
  #   loading = true
  #   url = "http://3g.163.com/touch/article/list/#{tid}/#{index}-10.html"
  #   NTES.importJs(url)  
  #   index = index + 10

  # t =  0
  screenHeight = document.documentElement.clientHeight
  scrollTop = 0
  window.onscroll = (e)->
    X('.wx-share').hide()
    currentScrollTop = X(window).scrollTop()
    hotNewsScrollTop = X('.m-hotnews').offset().top
    if hotNewsScrollTop < currentScrollTop + screenHeight
      X('.share-trigger').addClass('hide')
    else
      X('.share-trigger').removeClass('hide')

  # window.onscroll = (e)->
  #   now = Date.now()
  #   if now - t > 300
  #     X('.wx-share').hide()
  #     currentScrollTop = X(window).scrollTop()
  #     hotNewsScrollTop = X('.m-hotnews').offset().top
  #     if hotNewsScrollTop < currentScrollTop + screenHeight
  #       X('.share-trigger').hide()
  #     else
  #       X('.share-trigger').show()

  #     scrollTop = currentScrollTop

  #     if document.body.clientHeight - currentScrollTop - screenHeight < 400
  #       loadMore()
  #     t = now
  #   return

  # channelId = NTES.localParam().search['docid'].slice(8,12)
  # tid = '9GA842UHbjwangjian'
  # switch channelId
  #   when '0005' then tid = '9ARM854Kbjwangjian' # 体育
  #   when '0026' then tid = '9ARLAQSKyswang' # 女人
  #   when '0009' then tid = '9ARIUJ61yswang' # 科技
  #   when '0016' then tid = 'AE8I2TA8bj_libo'# 数码
  #   when '0031' then tid = '9ARLJSKOyswang' # 游戏
  #   when '0003' then tid = '9ARMBG0Pyswang' # 娱乐
  #   when '0025' then tid = '9ARI6CIDyswang' # 财经
  #   when '0011' then tid = 'AC2M6B49bj_libo' # 手机
  #   when '0087' then tid = '9ARL2BASyswang' # 房产
  # window.artiList = (list) ->
  #   loading = false
  #   list = list[tid]
  #   html = ''
  #   list.forEach (item)->
  #     html += """
  #       <li>
  #         <a href="http://3g.163.com/ntes/special/0034073A/wechat_article.html?docid=#{item.docid}&from=wechat_article.topnews">
  #           <div class="img-wrap">
  #             <img src="#{item.imgsrc}" onerror="this.src='http://img2.cache.netease.com/3g/img11/3gtouch13/default.jpg'">
  #           </div>
  #           <div class="news-wrap">
  #             <div class="news-title">#{item.title}</div>
  #             <div class="news-subtitle">#{item.digest}</div>
  #             <div class="news-tip">#{item.commentCount}跟贴</div>
  #           </div>
  #         </a>
  #       </li>
  #     """
  #     return
  #   X('.m-hotnews .list').append(html)
  #   return

)($)








