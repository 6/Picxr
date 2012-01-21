user_id = null
access_token = null

window.Face =
  active: -> user_id?
  update_status_cb: null
  default_route: -> "albums/#{user_id}"

window.fbAsyncInit = ->
  UT.p "fbAsyncInit"
  FB.init
    appId: $("html").data("fb-app-id")
    status: true
    cookie: true
    oauth: true
  FB.Event.subscribe 'auth.statusChange', update_status

update_status = (res) ->
  if res.authResponse? and !user_id?
    #user is already logged in and connected
    user_id = res.authResponse.userID
    access_token = res.authResponse.accessToken
    Face.view = new PicMixr.Views.TopbarFbUserInfo
    set_user_info()
    UT.p "Auth token:",res.authResponse.accessToken, "expires:", res.authResponse.expiresIn
    Face.update_status_cb() if Face.update_status_cb?
  else if !user_id?
    # user is not connected to your app or logged out
    UT.p "no facebook user_id"
    
set_user_info = ->
  UT.p "set_user_info"
  $("#cta-row").html JST["tween/loading"]()
  FB.api '/me', (res) ->
    Face.view.render(fb_user_id: user_id, fb_name: res.name)
    create_session user_id, res.name

Face.fb_login = ->
  FB.login (res) ->
    # user cancelled login or did not grant authorization
    unless res.authResponse?
      UT.p "DENY"
      Face.view.render()
  , {scope: 'user_photos,friends_photos'}
  
Face.fb_logout = ->
  user_id = null
  FB.logout (res) -> UT.redirect "logout"

create_session = (user_id, name) ->
  $.post '/session/facebook',
    uid: user_id
    info:
      name: name

Face.user_albums = (uid, cb) ->
  UT.p "Face.user_albums #{uid}"
  albums = []
  q_albums = FB.Data.query("SELECT aid, name, cover_pid, photo_count FROM album WHERE owner='{0}' AND photo_count > 0", user_id)
  q_albums.wait (rows) ->
    cb [] if rows.length is 0
    results_count = rows.length
    $.each rows, (i, album) ->
      q_album_cover = FB.Data.query("SELECT src, src_width, src_height FROM photo WHERE pid='{0}'", album["cover_pid"])
      q_album_cover.wait (result) ->
        cover = result[0]
        if cover.src? and cover.src.length > 0 # may be blank. TODO: don't ignore if blank
          albums.push new PicMixr.Models.Picture(
            src_small: cover.src
            title: album.name
            alt: album.name
            count: album.photo_count
            href: "/album/#{album.aid}"
          )
        else results_count -= 1
        if albums.length is results_count
          UT.p "Found albums", albums
          cb albums

Face.album_photos = (aid, cb) ->
  UT.p "Face.album_photos #{aid}"
  q_photos = FB.Data.query("SELECT pid, caption, src, src_width, src_height, src_big, src_big_width, src_big_height FROM photo WHERE aid='{0}'", aid)
  q_photos.wait (results) ->
    photos = []
    $.each results, (i, photo) ->
      photos.push new PicMixr.Models.Picture(
        src_small: photo.src
        title: photo.caption
        alt: photo.caption
        href: "/edit/#{encodeURIComponent(photo.src_big or photo.src).replace(/\./g, '@')}"
      )
    UT.p "Found photos", photos
    cb photos

$ ->
  Face.view = new PicMixr.Views.TopbarFbImport
  Face.view.render()
