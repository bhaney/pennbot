# Description:
#   Showing of gitlab issuess via the REST API.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_GITLAB_BASE_URL - URL to your GitLab project
#   HUBOT_GITLAB_BASE_API - API to your GitLab project
#   HUBOT_GITLAB_TOKEN - API key for your selected user
#   HUBOT_GITLABE_SSL - 1 to use https
#
# Commands:
#   hubot link me <discussion-id> - Returns a link to the discussion 
#   hubot add time <e.g. 3h30m> to <discussion-id> - Adds time spent on the discussion
#   hubot show (my|user's) discussions - Show discussions assigned to you
#   hubot list discussions - Show all of the discussions
#   hubot comment on <discussion-id> "<note>"  - Adds a comment to the discussion
#   hubot create discussion about "<subject>" resolution: "<note>"  - Add issue to specific project
#   hubot show discussion <discussion-id> - print the discussion and its comments.
#   hubot edit resolution <discussion-id> "<note>" - edit the resolution of the discussion
#   hubot change priority of <discussion-id> to <0-9> - change the priority, with 9 being highest.
#
if process.env.HUBOT_GITLAB_SSL?
  HTTP = require('https')
else
  HTTP = require('http')

URL = require('url')
QUERY = require('querystring')

module.exports = (robot) ->
  gitlab = new Gitlab process.env.HUBOT_GITLAB_BASE_API, process.env.HUBOT_GITLAB_BASE_URL, process.env.HUBOT_GITLAB_TOKEN

  # Robot link me <issue>
  robot.respond /link me (?:issue )?(?:#)?(\d+)/i, (msg) ->
    id = msg.match[1]
    msg.send "#{gitlab.url}/issues/#{id}"

  # Robot add time <e.g. 3h30m> to <issue_id> 
  robot.respond /add time (\d+h\d+m) to (?:issue )?(?:#)?(\d+)/i, (msg) ->
    [time, id] = msg.match[1..2]

    attributes =
      "issue_iid": id
      "duration": time

    gitlab.TimeEntry(id).create attributes, (error, data, status) ->
      if status == 201
        msg.send "Your time was logged for [##{id}](#{gitlab.url}/issues/#{id})"
      else
        msg.send "Nothing could be logged. Make sure GitLab has a default activity set for time tracking. "

  # Robot show <my|user's> [gitlab] discussions
  robot.respond /show @?(?:my|(\w+\s?'?s?)) (?:gitlab )?discussions/i, (msg) ->
    userMode = true
    userName =
      if msg.match[1]?
        userMode = false
        msg.match[1].replace(/\'.+/, '').trim()
      else
        msg.message.user.name
    params =
      "search" : "#{userName}"

    gitlab.Users params, (err,data) ->
      unless data.length > 0
        msg.send "Couldn't find any users with the name \"#{userName}\""
        return false
      user = data[0]

      params =
        "assignee_id": user.id
        "state": "opened"

      gitlab.Issues params, (err, data) ->
        if err?
          msg.send "Couldn't get a list of discussions for you!"
        else
          _ = []
          if userMode
            _.push "You have #{data.length} discussion(s)."
          else
            _.push "#{user.username} has #{data.length} discussion(s). "

          for issue in data
            do (issue) ->
              _.push "\n [#{issue.iid}: **#{issue.title}**](#{gitlab.url}/issues/#{issue.iid}) [priority: #{issue.weight}] - **Resolution**: #{issue.description} "

          msg.send _.join "\n"

  # Robot list [gitlab] discussions
  robot.respond /list (?:gitlab )?discussions/i, (msg) ->
      params =
        "state": "opened"

      gitlab.Issues params, (err, data) ->
        if err?
          msg.send "Couldn't get a list of discussions for you!"
        else
          _ = []
          _.push "There are #{data.length} discussions."

          for issue in data
            do (issue) ->
              _.push "\n [#{issue.iid}: **#{issue.title}**](#{gitlab.url}/issues/#{issue.iid}) [priority: #{issue.weight}] - **Resolution**: #{issue.description} "
          msg.send _.join "\n"

  # Robot comment on <discussion> "<note>"
  robot.respond /comment on (?:#)?(\d+) "([^"]+)"/i, (msg) ->
    [id, note] = msg.match[1..2]

    attributes =
      "body": "@#{msg.message.user.name}: #{note}"

    gitlab.Issue(id).comment attributes, (err, data, status) ->
      unless data?
        if status == 404
          msg.send "Issue ##{id} doesn't exist."
        else
          msg.send "Couldn't update this issue, sorry :("
      else
        msg.send "Done! Added comment to [##{id}](#{gitlab.url}/issues/#{id}) \"#{note}\""

  # Robot create discussion about "<subject>" resolution: "<note>"
  robot.respond /create (?:discussion )(?:\s*about\s*)"([^"]+)" resolution:\s*"([^"]+)"/i, (msg) ->
    subject = msg.match[1]
    note = msg.match[2]

    params =
      "search": "#{msg.message.user.name}"

    gitlab.Users params, (err,data) ->
      unless data.length > 0
        user = null
      else
        user = data[0]
    
      if user == null
        attributes =
          "title": "#{subject}"
          "description": "#{note}"
      else
        attributes =
          "title": "#{subject}"
          "description": "#{note}"
          "assignee_ids": [user.id]

      gitlab.Issue(0).add attributes, (err2, data2, status2) ->
        unless data2? #if the data does not exist
          if status2 == 404
            msg.send "Couldn't create this discussion, #{status2} :("
        if data2?
          msg.send "Done! Added [#{data2.iid}: #{data2.title}](#{gitlab.url}/issues/#{data2.iid}) with resolution \"#{note}\""

  # Robot show discussion <discussion-id>
  robot.respond /show discussion (?:#)?(\d+)/i, (msg) ->
    id = msg.match[1]
    gitlab.Issue(id).show {}, (err, data, status) ->
      unless status == 200
        msg.send "Discussion ##{id} doesn't exist."
        return false
      gitlab.Issue(id).members {}, (err, participants, status) ->
        unless status == 200
          msg.send "Cant access participants for discussion ##{id}."
          return false
        gitlab.Issue(id).notes {"sort":"asc"}, (err, notes, status) ->
          unless status == 200
            msg.send "Cant access comments for discussion ##{id}."
            return false
          members = []
          for participant in participants
            do(participant) ->
              members.push participant.username
          comments = []
          for note in notes
            unless note.system
              dt = new Date note.created_at
              comments.push "On #{dt.toLocaleString()} from #{note.author.username}: \n #{note.body}"
          _ = []
          _.push "\n [#{data.iid}: **#{data.title}**](#{data.web_url}) [#{data.state} - priority: #{data.weight}] "
          dt = new Date data.created_at
          _.push "Created on #{dt.toLocaleString()}"
          _.push "Participants: #{members.join(', ')}"
          _.push "**Resolution**: #{data.description}"
          #comments
          _.push "\n" + Array(10).join('-') + 'Comments' + Array(50).join('-') + "\n"
          for comment in comments
            _.push "#{comment} \n"
          msg.send _.join "\n"

  # Robot edit resolution <discussion-id> "<note>"
  robot.respond /edit resolution (?:#)?(\d+) "([^"]+)"/i, (msg) ->
    [id, note] = msg.match[1..2]

    attributes =
      "description": "#{note}"

    gitlab.Issue(id).update attributes, (err, data, status) ->
      unless data?
        if status == 404
          msg.send "Issue ##{id} doesn't exist."
        else
          msg.send "Couldn't update this issue, sorry :("
      else
        msg.send "Done! Edited resolution of [##{id}: #{data.title}](#{data.web_url}) to \"#{note}\""

  # Robot change priority of <discussion-id> to <0-9>
  robot.respond /change priority of (\d+) to ([0-9])$/i, (msg) ->
    [id, priority] = msg.match[1..2]

    attributes =
      "weight": "#{priority}"

    gitlab.Issue(id).update attributes, (err, data, status) ->
      unless data?
        if status == 404
          msg.send "Issue ##{id} doesn't exist."
        else
          msg.send "Couldn't update this issue, sorry :("
      else
        msg.send "Done! Edited priority of [##{id}: #{data.title}](#{data.web_url}) to \"#{priority}\""



# simple ghetto fab date formatter this should definitely be replaced, but didn't want to
# introduce dependencies this early
#
# dateStamp - any string that can initialize a date
# fmt - format string that may use the following elements
#       mm - month
#       dd - day
#       yyyy - full year
#       hh - hours
#       ii - minutes
#       ss - seconds
#       ap - am / pm
#
# returns the formatted date
formatDate = (dateStamp, fmt = 'mm/dd/yyyy at hh:ii ap') ->
  d = new Date(dateStamp)

  # split up the date
  [m,d,y,h,i,s,ap] =
    [d.getMonth() + 1, d.getDate(), d.getFullYear(), d.getHours(), d.getMinutes(), d.getSeconds(), 'AM']

  # leadig 0s
  i = "0#{i}" if i < 10
  s = "0#{s}" if s < 10

  # adjust hours
  if h > 12
    h = h - 12
    ap = "PM"

  # ghetto fab!
  fmt
    .replace(/mm/, m)
    .replace(/dd/, d)
    .replace(/yyyy/, y)
    .replace(/hh/, h)
    .replace(/ii/, i)
    .replace(/ss/, s)
    .replace(/ap/, ap)


# Gitlab API Mapping
class Gitlab
  constructor: (api, url, token) ->
    @api = api
    @url = url
    @token = token

  Users: (params, callback) ->
    @get "/users", params, callback

  User: (id) ->

    show: (callback) =>
      @get "/users/#{id}", {}, callback

  Projects: (params, callback) ->
    @get "/projects.json", params, callback

  Issues: (params, callback) ->
    @get "/issues", params, callback

  Issue: (id) ->

    add: (attributes, callback) =>
      @post "/issues", attributes, callback

    show: (params, callback) =>
      @get "/issues/#{id}", params, callback

    members: (params, callback) =>
      @get "/issues/#{id}/participants", params, callback

    notes: (params, callback) =>
      @get "/issues/#{id}/notes", params, callback

    update: (attributes, callback) =>
      @put "/issues/#{id}", attributes, callback

    comment: (attributes, callback) =>
      @post "/issues/#{id}/notes", attributes, callback

  Emoji: (id) ->
    add: (attributes, callback) =>
      @post "/issues/#{id}/award_emoji", attributes, callback

    show: (params, callback) =>
      @get "/issues/#{id}/award_emoji", params, callback

  TimeEntry: (id) ->

    create: (attributes, callback) =>
      @post "/issues/#{id}/add_spent_time", attributes, callback

  # Private: do a GET request against the API
  get: (path, params, callback) ->
    path = "#{path}?#{QUERY.stringify params}" if params?
    @request "GET", path, null, callback

  # Private: do a POST request against the API
  post: (path, body, callback) ->
    @request "POST", path, body, callback

  # Private: do a PUT request against the API
  put: (path, body, callback) ->
    @request "PUT", path, body, callback

  # Private: Perform a request against the GitLab REST API
  request: (method, path, body, callback) ->
    headers =
      "Content-Type": "application/json"
      "PRIVATE-TOKEN": @token

    endpoint = URL.parse(@api)
    pathname = endpoint.pathname.replace /^\/$/, ''

    options =
      "host"   : endpoint.hostname
      "port"   : endpoint.port
      "path"   : "#{pathname}#{path}"
      "method" : method
      "headers": headers

    if method in ["POST", "PUT"]
      if typeof(body) isnt "string"
        body = JSON.stringify body

      options.headers["Content-Length"] = body.length

    request = HTTP.request options, (response) ->
      data = ""

      response.on "data", (chunk) ->
        data += chunk

      response.on "end", ->
        switch response.statusCode
          when 200
            try
              callback null, JSON.parse(data), response.statusCode
            catch err
              callback null, (data or { }), response.statusCode
          when 201
            try
              callback null, JSON.parse(data), response.statusCode
            catch err
              callback null, (data or { }), response.statusCode
          when 401
            throw new Error "401: Authentication failed."
          else
            console.error "Code: #{response.statusCode}"
            callback null, null, response.statusCode

      response.on "error", (err) ->
        console.error "Gitlab response error: #{err}"
        callback err, null, response.statusCode

    if method in ["POST", "PUT"]
      request.end(body, 'binary')
    else
      request.end()

    request.on "error", (err) ->
      console.error "Gitlab request error: #{err}"
      callback err, null, 0
