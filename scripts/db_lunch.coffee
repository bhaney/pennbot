#
#Commands:
#   hubot plot ratings for <username> - returns a histogram of the user's lunch ratings.

module.exports = (robot) ->

  robot.respond /plot ratings for (.*)/i, (res) ->
      username = res.match[1] or ''
      robot.http("https://bots.bijanhaney.com/lunch/plot/ratings?username=#{username}")
        .get() (err, response, body) ->
          if err
            res.send "Encountered an error #{err}"
          else
            result = JSON.parse body
            res.send result.text

