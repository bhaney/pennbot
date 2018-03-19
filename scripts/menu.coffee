#
#Commands:
#   hubot r1 menu - Gives the R1 lunch menu for today
#   hubot r2menu  - Gives the R2 lunch menu for today
#

showMenu = (robot, res, restaurant, day) ->
  restaurant = restaurant.toLowerCase()
  day = day.toLowerCase()
  robot.http("https://r1d2.herokuapp.com/#{restaurant}/#{day}").get() (err, resp, body) ->
    if err
      res.send "Encountered an error!"
      return
    output = JSON.parse body
    menu = output["menu"]
    if menu
      result = "This is the #{restaurant.toUpperCase()} menu for #{day}\n"
      for dish, i in menu
        type = dish["type"]
        name = dish["name"]
        price = dish["price"]
        result += "*"+type+"*: **"+name+"** (*CHF "+price+"*)\n"
    res.reply result

showSingleMenu = (robot, res, restaurant, day, type) ->
  restaurant = restaurant.toLowerCase()
  day = day.toLowerCase()
  type = type.toLowerCase()
  robot.http("https://r1d2.herokuapp.com/#{restaurant}/#{day}/#{type}").get() (err, resp, body) ->
    if err
      res.send "Encountered an error!"
      return
    output = JSON.parse body
    menu = output["menu"]
    if menu
      result = "This is the #{restaurant.toUpperCase()} #{type} option for #{day}\n"
      for dish, i in menu
        if type == dish["type"]
          name = dish["name"]
          price = dish["price"]
          result += "*"+type+"*: **"+name+"** (*CHF "+price+"*)\n"
    res.reply result

module.exports = (robot) ->
  robot.respond /(?:what's|what is) (?:\bthe menu\b)( in R2)? *(?:for|on)? *(tomorrow|Monday|Tuesday|Wednesday|Thursday|Friday)?/i, (res) ->
    restaurant = 'r1'
    if res.match[1]
      restaurant = 'r2'
    day = res.match[2] || 'today'
    showMenu robot, res, restaurant, day
    return

  robot.respond /(r1|r2) menu?/i, (res) ->
    restaurant = 'r1'
    if res.match[1] == 'r2'
      restaurant = 'r2'
    day = 'today'
    showMenu robot, res, restaurant, day
    return

  robot.respond /(r1|r2) (menu1|menu2|veg|vegetarian|grill|pasta|pizza|speciality|special)/i, (res) ->
    type = res.match[2] || 'error'
    if type == 'veg'
      type = 'vegetarian'
    if type == 'special'
      type = 'speciality'
    restaurant = 'r1'
    if res.match[1]
      restaurant = 'r2'
    day = 'today'
    showSingleMenu robot, res, restaurant, day, type
    return
