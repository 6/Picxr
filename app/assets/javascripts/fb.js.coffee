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
  $("#user-info").html "<img id='fb-avatar' src='#{avatar_url user_id}'>"
  FB.api '/me', (res) ->
    $("#user-info").append res.name
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

avatar_url = (user_id) -> "https://graph.facebook.com/#{user_id}/picture"

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
    #TODO use client-side templates
    $album = $("<li><a href='#'><img class='thumbnail' src='#{album.cover}' title='#{album.name}' alt='#{album.name}'></a></li>")
    $album.click ->
      console.p "#{album.name}, #{album.aid}"
    $album.appendTo("#fb-photos")

$ ->
  $("#fb-auth").click (e) ->
    fb_login()
    e.preventDefault()
  $("#fb-logout").click (e) ->
    fb_logout()
    e.preventDefault()
