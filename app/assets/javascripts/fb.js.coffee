user_id = null

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
    toggle_login_html false
    set_user_info()
    console.p "Auth token:",res.authResponse.accessToken
  else if !user_id?
    # user is not connected to your app or logged out
    toggle_login_html true
    console.p "no facebook user_id"
    
set_user_info = ->
  $("#user-info").html "<img src='#{avatar_url user_id}'>"
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
    alert("DENY") unless res.authResponse?
  , {scope: 'user_photos,friends_photos'}
  
fb_logout = ->
  user_id = null
  FB.logout (res) -> redirect "logout"

create_session = (user_id, name) ->
  $.post '/session/facebook',
    uid: user_id
    info:
      name: name

auth_url = (scope) ->    
  cb_url = "#{window.top_href}auth/facebook/callback"
  "https://www.facebook.com/dialog/oauth?client_id=#{window.fb_app_id}&redirect_uri=#{encodeURIComponent cb_url}&scope=#{scope}"

avatar_url = (user_id) -> "https://graph.facebook.com/#{user_id}/picture"

$ ->
  $("#fb-auth").click (e) ->
    #top.location.href = auth_url window.fb_scope
    fb_login()
    e.preventDefault()
  $("#fb-logout").click (e) ->
    fb_logout()
    e.preventDefault()
