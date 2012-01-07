user_id = null
access_token = null

window.fbAsyncInit = ->
  FB.init
    appId: window.fb_app_id
    status: true
    cookie: true
    oauth: true

  # run once with current status and whenever the status changes
  FB.getLoginStatus update_status
  FB.Event.subscribe 'auth.statusChange', update_status
  #$("#fb-auth").removeClass("disabled") #TODO disable click until here

update_status = (res) ->
  if res.authResponse? and !user_id?
    #user is already logged in and connected
    user_id = res.authResponse.userID
    access_token = res.authResponse.accessToken
    toggle_login_html false
    set_user_info()
    console.p "Auth token:",res.authResponse.accessToken, "expires:", res.authResponse.expiresIn
    #TODO show "Loading Facebook photos [loading img]"
    $("#canvas-placeholder").hide(0);
    fetch_albums user_id, show_albums
  else if !user_id?
    # user is not connected to your app or logged out
    toggle_login_html true
    console.p "no facebook user_id"
    
set_user_info = ->
  #TODO loading message
  FB.api '/me', (res) ->
    $("#user-info").html JST["fb_user_info"](fb_user_id: user_id, fb_name: res.name)
    create_session user_id, res.name
  
toggle_login_html = (show_bool) ->
  if show_bool
    $("#fb-auth").show(0)
    $("#fb-logout").hide(0)
    $("#user-info").hide(0)
  else
    $("#fb-auth").hide(0)
    # only show logout if they're not using canvas frame
    $("#fb-logout").show(0) unless window.is_fb_frame
    $("#user-info").show(0)

fb_login = ->
  FB.login (res) ->
    # user cancelled login or did not grant authorization
    console.p "DENY" unless res.authResponse?
  , {scope: 'user_photos,friends_photos'}
  
fb_logout = ->
  user_id = null
  FB.logout (res) -> redirect "logout"

create_session = (user_id, name) ->
  $.post '/session/facebook',
    uid: user_id
    info:
      name: name

fetch_albums = (uid, cb) ->
  uid ?= user_id
  albums = []
  q_albums = FB.Data.query("SELECT aid, name, cover_pid, photo_count FROM album WHERE owner='{0}' AND photo_count > 0", user_id)
  q_albums.wait (rows) ->
    cb [] if rows.length is 0
    results_count = rows.length
    $.each rows, (i, row) ->
      q_album_cover = FB.Data.query("SELECT src, src_width, src_height FROM photo WHERE pid='{0}'", row["cover_pid"])
      q_album_cover.wait (res) ->
        res = res[0]
        if res.src? and res.src.length > 0 # may be blank. TODO: don't ignore if blank
          albums.push
            cover: res.src
            name: row.name
            aid: row.aid
            count: row.photo_count
        else results_count -= 1
        if albums.length is results_count
          console.p "FETCHED ALBUMS", albums
          cb albums

show_albums = (albums) ->
  $("#fb-photos").html("").show(0)
  $.each albums, (i, album) ->
    $album = $(JST['grid_thumb'](src: album.cover, title: album.name, alt: album.name))
    $album.click (e) ->
      #TODO extract this to "click builder"
      fetch_album_photos album.aid, (photos) ->
        $("#fb-photos-title").text(album.name).show(0)
        $("#fb-photos").html("").show(0)
        $.each photos, (i, photo) ->
          $photo = $(JST['grid_thumb'](src: photo.src, title: photo.caption, alt: "Photo from #{album.name}"))
          $photo.click (e) ->
            #TODO extract
            alert "TODO: start editing #{photo.src_big}"
            e.preventDefault()
          $photo.appendTo("#fb-photos")
      e.preventDefault()
    $album.appendTo("#fb-photos")

fetch_album_photos = (aid, cb) ->
  q_photos = FB.Data.query("SELECT pid, caption, src, src_width, src_height, src_big, src_big_width, src_big_height FROM photo WHERE aid='{0}'", aid)
  q_photos.wait (rows) ->
    console.p "FETCHED PHOTOS", rows
    cb rows

$ ->
  $("#fb-auth").click (e) ->
    fb_login()
    e.preventDefault()
  $("#fb-logout").click (e) ->
    fb_logout()
    e.preventDefault()
