#
#Commands:
#   hubot r1/r2/r3 menu <day> - Gives the R1/R2/R3 lunch menu for the given day
#   hubot r1/r2/r3 (menu1, menu2,pizza, etc) <day> - Gives the R1/R2/R3 menu for a specific dish.

translate = require('google-translate-api')

printMenuInEnglish = (menu, menu_str, i, res) ->
  if i < menu.length
    dish = menu[i]
    type = dish["type"]
    name = dish["name"]
    price = dish["price"]
    translate(name, {from: 'fr', to: 'en'}).then (data) ->
      en_name = data.text
      menu_str += "*"+type+"*: **"+name+" / "+en_name+"** (*CHF "+price+"*)\n"
      printMenuInEnglish(menu, menu_str, i+1, res)
    .catch (err) ->
      robot.emit 'error', err
      res.send 'Google Translate API error.'
  else
    res.send menu_str

showMenu = (robot, res, restaurant, day, english) ->
  restaurant = restaurant.toLowerCase()
  day = day.toLowerCase()
  robot.http("https://bots.bijanhaney.com/r1d2/#{restaurant}/#{day}").get() (err, resp, body) ->
  #robot.http("https://r1d2.herokuapp.com/#{restaurant}/#{day}").get() (err, resp, body) ->
    if err
      res.send "Encountered an error!"
      return
    output = JSON.parse body
    menu = output["menu"]
    if menu
      result = "This is the #{restaurant.toUpperCase()} menu for #{day}\n"
      if english
        printMenuInEnglish(menu, result, 0, res)
      else
        for dish, i in menu
          type = dish["type"]
          name = dish["name"]
          price = dish["price"]
          result += "*"+type+"*: **"+name+"** (*CHF "+price+"*)\n"
        res.send result

  
showSingleMenu = (robot, res, restaurant, day, type, english) ->
  restaurant = restaurant.toLowerCase()
  day = day.toLowerCase()
  type = type.toLowerCase()
  robot.http("https://bots.bijanhaney.com/r1d2/#{restaurant}/#{day}/#{type}").get() (err, resp, body) ->
  #robot.http("https://r1d2.herokuapp.com/#{restaurant}/#{day}").get() (err, resp, body) ->
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
          if english
            translate(name, {from: 'fr', to: 'en'}).then (data) ->
              name = data.text
              result += "*"+type+"*: **"+name+"** (*CHF "+price+"*)\n"
              res.send result
            .catch (err) ->
              res.send "Google Translate API error."
              robot.emit 'error', err
          else
            result += "*"+type+"*: **"+name+"** (*CHF "+price+"*)\n"
            res.send result

module.exports = (robot) ->
  robot.respond /(?:what's|what is) (?:\bthe menu\b)( in R2)? *(?:for|on)? *(tomorrow|Monday|Tuesday|Wednesday|Thursday|Friday)?\s?(in english)?/i, (res) ->
    restaurant = 'r1'
    if res.match[1]
      restaurant = 'r2'
    day = res.match[2] || 'today'
    english = if res.match[3] then true else false
    showMenu robot, res, restaurant, day, english
    return

  robot.respond /(r1|r2|r3) menu\s?(today|tomorrow|monday|tuesday|wednesday|thursday|friday)?\s?(english)?$/i, (res) ->
    restaurant = res.match[1]
    day = res.match[2] or 'today'
    day = day.toLowerCase()
    english = if res.match[3] then true else false
    showMenu robot, res, restaurant, day, english
    return

  robot.respond /(r1|r2|r3) (menu1|menu2|veg|vegetarian|grill|pasta|pizza|speciality|special)\s?(today|tomorrow|monday|tuesday|wednesday|thursday|friday)?\s?(english)?$/i, (res) ->
    restaurant = res.match[1]
    type = res.match[2] || 'error'
    if type == 'veg'
      type = 'vegetarian'
    if type == 'special'
      type = 'speciality'
    day = if res.match[3] then res.match[3].toLowerCase() else 'today'
    english = if res.match[4] then true else false
    showSingleMenu robot, res, restaurant, day, type, english
    return
