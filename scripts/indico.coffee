#
#Commands:
#   hubot next meeting [group] - Gives a link to the next group meeting - defaults to UPenn 

nextMeeting = (robot, res, category) ->
  robot.http("https://bots.bijanhaney.com/indico/next/#{category}").get() (err, resp, body) ->
    if err
      res.send "Encountered an error!"
      return
    output = JSON.parse body
    result = output["body"]
    if result
      res.send result

announceMeeting = (robot, res, category) ->
  robot.http("https://bots.bijanhaney.com/indico/next/#{category}").get() (err, resp, body) ->
    if err
      res.send "Encountered an error!"
      return
    output = JSON.parse body
    if output["date"] != ''
      meeting_time = new Date(output["date"])
      #difference in seconds
      difference = Math.floor((meeting_time - Date.now())/1000)
      #announce meeting between 2 and 31 minutes before the start
      if (difference > 120) and (difference < 1860)
        minute_diff = Math.floor(difference/60)
        res.send "Meeting in #{minute_diff} minutes.\n#{output['body']}"

module.exports = (robot) ->
  robot.respond /next meeting\s?(\w+)?/i, (res) ->
    category = res.match[1] or 'upenn'
    nextMeeting robot, res, category
    return

  robot.respond /announce meeting\s?(\w+)?/i, (res) ->
    category = res.match[1] or 'upenn'
    announceMeeting robot, res, category
    return
