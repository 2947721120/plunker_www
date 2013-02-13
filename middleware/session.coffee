nconf = require("nconf")
request = require("request")

module.exports.middleware = (options = {}) ->
  
  apiUrl = nconf.get("url:api")
  
  console.log "API Url", apiUrl
  
  (req, res, next) ->
    fetchSession = (sessid) ->
      return createSession() unless sessid
      
      request "#{apiUrl}/sessions/#{sessid}", (err, response, body) ->
        if err or response.statusCode >= 400 then createSession()
        else finalize(parse(body))
      
    createSession = ->
      request.post "#{apiUrl}/sessions", (err, response, body) ->
        if err or response.statusCode >= 400 then next("Error creating session: #{JSON.stringify(err or response)}")
        else finalize(parse(body))
    
    parse = (body) ->
      try
        session = JSON.parse(body)
      catch e
        return next("Error parsing session JSON")
      
      return session
      
    finalize = (session) ->
      res.expose ||= {}
      res.expose.session = session
      next()
    
    if sessid = req.cookies.plnk_session then fetchSession(sessid)
    else createSession()
