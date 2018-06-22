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

module.exports = (robot) ->
  robot.respond /next meeting\s?(\w+)?/i, (res) ->
    category = res.match[1] or 'upenn'
    nextMeeting robot, res, category
    return

