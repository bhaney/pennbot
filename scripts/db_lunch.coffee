#
#Commands:
#   hubot plot ratings for <username> - returns a histogram of the user's lunch ratings.
#   hubot plot my ratings - returns a histogram of your own lunch ratings.

plotRatings = (username, res) ->
  res.http("https://bots.bijanhaney.com/lunch/plot/ratings?username=#{username}")
    .get() (err, response, body) ->
      if err
        res.send "Encountered an error #{err}"
      else
        result = JSON.parse body
        res.send result.text

module.exports = (robot) ->
  robot.respond /plot ratings for (?:@)?(.*)/i, (res) ->
    username = res.match[1] or ''
    if (username is 'all') or (username is 'everybody')
      username = 'everyone'
    plotRatings(username, res)

  robot.respond /plot my ratings/i, (res) ->
    username = res.message.user.name
    plotRatings(username, res)

  robot.respond /plot everyone(s|'s) ratings/i, (res) ->
    username = 'everyone'
    plotRatings(username, res)
