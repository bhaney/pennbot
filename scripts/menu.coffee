#
#Commands:
#   hubot (r1/r2/r3) menu <day> - Gives the R1/R2/R3 lunch menu for the given day
#   hubot (r1/r2/r3) (menu1, menu2,pizza, etc) <day> - Gives the R1/R2/R3 menu for a specific dish.

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

  robot.respond /(r1|r2|r3) menu\s?(today|tomorrow|tuesday|wednesday|thursday|friday|saturday|sunday)?$/i, (res) ->
    restaurant = res.match[1]
    day = res.match[2] or 'today'
    day = day.toLowerCase()
    showMenu robot, res, restaurant, day
    return

  robot.respond /(r1|r2|r3) (menu1|menu2|veg|vegetarian|grill|pasta|pizza|speciality|special)\s?(today|tomorrow|tuesday|wednesday|thursday|friday|saturday|sunday)?$/i, (res) ->
    restaurant = res.match[1]
    type = res.match[2] || 'error'
    if type == 'veg'
      type = 'vegetarian'
    if type == 'special'
      type = 'speciality'
    day = res.match[3].toLowerCase() or 'today'
    showSingleMenu robot, res, restaurant, day, type
    return
