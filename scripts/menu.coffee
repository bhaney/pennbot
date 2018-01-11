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
        result += "_#{type}_: *#{name}* (_CHF #{price}_)\n"
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
          result += "_#{type}_: *#{name}* (_CHF #{price}_)\n"
    res.reply result

module.exports = (robot) ->
  robot.respond /lunch/i, (res) ->
    restaurant = 'r1'
    day = 'today'
    showMenu robot, res, restaurant, day
    return

  robot.respond /(?:what's|what is) (?:\bthe menu\b|\bfor lunch\b)( in R2)? *(?:for|on)? *(tomorrow|Monday|Tuesday|Wednesday|Thursday|Friday)?/i, (res) ->
    restaurant = 'r1'
    if res.match[1]
      restaurant = 'r2'
    day = res.match[2] || 'today'
    showMenu robot, res, restaurant, day
    return

  robot.respond /(?:what's|what is) the (\w+) (?:\bmenu\b|\blunch\b|\boption\b|\bchoice\b|\bdish\b)? (in R2)? *(?:for|on)? *(tomorrow|Monday|Tuesday|Wednesday|Thursday|Friday)?/i, (res) ->
    type = res.match[1] || 'error'
    if type == 'murder'
      type = 'menu1'
    if type == 'carnivore'
      type = 'menu1'
    if type == 'other'
      type = 'menu2'
    restaurant = 'r1'
    if res.match[2]
      restaurant = 'r2'
    day = res.match[3] || 'today'
    showSingleMenu robot, res, restaurant, day, type
    return
