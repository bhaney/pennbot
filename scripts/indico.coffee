#
#Commands:
#   hubot next meeting [group] - Gives a link to the next group meeting - defaults to UPenn 

nextMeeting = (robot, res, category) ->
  robot.http("https://bots.bijanhaney.com/indico/next/#{category}").get() (err, resp, body) ->
    if err
      res.send "Encountered an error in pyindico: #{err}"
      return
    output = JSON.parse body
    result = output["body"]
    if result
      res.send result

announceMeeting = (robot, res, category) ->
  robot.http("https://bots.bijanhaney.com/indico/next/#{category}").get() (err, resp, body) ->
    if err
      res.send "Encountered an error in pyindico: #{err}"
      return
    output = JSON.parse body
    if output['date'] != ''
      now = new Date()
      meeting_time = new Date(output["date"])
      #difference in seconds
      difference = Math.floor((meeting_time - now)/1000)
      #difference in minutes
      minute_diff = Math.ceil(difference/60)
      # testing strings
      #res.send output["date"]
      #res.send "time now is #{now.toLocaleString()}\nmeeting time is #{meeting_time.toLocaleString()}\nMeeting in #{minute_diff} minutes."
      #announce meeting between 1 and 31 minutes before the start
      if (difference > 60) and (difference < 1860)
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
