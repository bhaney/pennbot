#
#Commands:
#   hubot (what's for lunch / where should I eat ) - Selects a place to get lunch.
#   hubot (nom)inate <place>  - adds a tally for <place> to be added to the lunch list.
#   hubot (unnom)inate <place>  - remove your vote for <place> to be added to the lunch list.
#   hubot remove lunch <place> - adds a tally for <place> to be removed from the lunch list.
#   hubot review lunch location:"[1]" rating:"[2]" comment:"[3]"  - Review the location, give a rating between 1-10, and leave an optional comment.
#   hubot I brought lunch rating:"[1]" comment:"[2]" - Sets your location as brought. 
#   hubot lunch csv - Generates a new CSV of all the lunch reviews.
#   hubot list lunch - list the lunch options that are saved.
#   hubot list noms - list the nominees for the lunch list and their votes.
#   hubot list removals - list the nominees for removal and their votes.

class PlaceList
  constructor: (load_places) ->
    @places = load_places ?= {}
  get: (id) ->
    return @places[id]
  #creates a new place
  add: (place_name) ->
    id = Math.floor(Math.random() * 1000) while !id? || @places[id]
    @places[id] = { id:id, name: place_name, users: []}
    return id
  #gets the id for place, or returns false
  find: (place_name) ->
    if @places[place_name]?
      return place_name
    if place_name.id?
      return place_name.id
    for key,val of @places
      if val.name is place_name then return val.id
    return false
  #return an array of names
  list: ->
    pla = @places
    vec = []
    for k,v of pla
      vec.push v.name
    return vec
  #removes a place, returns true is success
  remove: (place) ->
    id = place.id
    if !@places[id]? then return false
    delete @places[place.id]
    return true
  #delete place from this list, and move to new list
  moveToList: (place, new_list) ->
    id = place.id
    if !@places[id]? then return false
    place_name = @places[id].name
    new_id = new_list.add(place_name)
    delete @places[id]
    return true
  #add a user to the place's user list, returns true if success
  removeUserFromPlace: (user, place) ->
    id = place.id
    if !@places[id]? then return false
    i = @places[id].users.indexOf(user)
    if i != -1
      @places[id].users.splice(i, 1)
      return true
    else
      return false

insertReview = (robot, res, username, place, rating, comment) ->
  #get database token
  database_token = process.env.HUBOT_LUNCH_TOKEN or null
  #get weather info
  api_key = process.env.HUBOT_OWM_APIKEY or null
  robot.http("http://api.openweathermap.org/data/2.5/weather?q=Philadelphia&units=imperial&APPID=#{api_key}")
    .header('Accept', 'application/json')
    .get() (w_err, w_res, w_body) ->
      if w_err
        res.send "Encountered an error \n `#{w_err}`"
      else
        w_data = JSON.parse(w_body)
        if w_data.message
          msg.send "#{w_data.message}"
        #create data object that will inserted into database
        data = JSON.stringify({
          token: database_token,
          time: Date.now(),
          suggest: robot.brain.get('food_rec'),
          weather: w_data.weather[0].main,
          temp: w_data.main.temp,
          user: username,
          actual: place,
          rating: rating,
          comment: comment
        })
        #now insert the info into the database
        robot.http("https://bots.bijanhaney.com/lunch/insert")
          .header('Content-Type', 'application/json')
          .post(data) (err, response, body) ->
            if err
              res.send "Encountered an error `#{err}`"
            else
              result = JSON.parse body
              if result.success
                robot.brain.data.user_reviewed_today.push username
                res.send "Thanks for your feedback! \n
                          location: #{place} \n 
                          rating: #{rating} \n
                          comment: #{comment} \n"
              else
                res.send "Was not able to commit review to database: \n #{result.text}"

module.exports = (robot) ->
  NUM_VOTES = 4 #treshold of votes required to change lists
  #intialize food variables if they don't exist
  robot.brain.data.nominee_list ?= {}
  robot.brain.data.denominate_list ?= {}
  robot.brain.data.food_list ?= {}
  robot.brain.data.user_reviewed_today ?= []
  robot.brain.data.food_rec ?= 'mexicali'
  robot.brain.data.food_day ?=  -1
  robot.brain.data.food_rec_2 ?= 'mexicali'
  robot.brain.data.food_day_2 ?=  -1

  robot.respond /(?:nom|nominate) (.*)\s?(?:for lunch)?$/i, (res) ->
    #get all relevant variables
    food_list = new PlaceList(robot.brain.data.food_list)
    nominee_list = new PlaceList(robot.brain.data.nominee_list)
    nom = res.match[1].toLowerCase().trim()
    user = res.message.user.name
    id = nominee_list.find(nom)
    #if first time place is nominated, initialize the nominee
    if !id
      id = nominee_list.add(nom)
    nominee = nominee_list.get(id)
    #can't vote more than once
    if user in nominee.users
      res.send "You've already nominated **"+nominee.name+"**. 
                It has "+nominee.users.length+" vote(s)."
    else
      nominee.users.push user
      #more than 5 votes moves the nominee to the lunch list
      if nominee.users.length > NUM_VOTES
        name = nominee.name
        test = nominee_list.moveToList(nominee, food_list) #deletes nominee from nominee_list
        if not test then res.send "this doesnt work well."
        robot.brain.data.food_list = food_list.places #save updated lunch list to brain
        res.send "**"+name+"** has been added to the lunch list."
      else
        res.send "OK. **"+nominee.name+"**,
                  id "+nominee.id+", 
                  has "+nominee.users.length+" vote(s)."
      robot.brain.data.nominee_list = nominee_list.places #save updated nominee list to brain
    
  robot.respond /(?:unnom|unnominate) (.*)\s?(?:for lunch)?$/i, (res) ->
    #get all relevant variables
    nominee_list = new PlaceList(robot.brain.data.nominee_list)
    nom = res.match[1].toLowerCase().trim()
    user = res.message.user.name
    id = nominee_list.find(nom)
    #check if nominee exists
    if !id or (nominee_list.get(id).users.length == 0)
      res.send "No one has nominated **"+nom+"** for lunch.
               To remove an entry, use 'pennbot rm lunch <place>'"
    else
      nominee = nominee_list.get(id)
      name = nominee.name
      #find user's vote, and remove it.
      if nominee_list.removeUserFromPlace(user, nominee)
        if nominee.users.length == 0
          nominee_list.remove(nominee)
          res.send "Your vote has been removed.
                   **"+name+"** has 0 vote(s)."
        else
          res.send "Your vote has been removed. 
                   **"+name+"**, id "+id+", has "+nominee.users.length+" vote(s)."
        #either way, save the updated nominee list to robot brain.
        robot.brain.data.nominee_list = nominee_list.places
      else
        res.send "You have not nominated **"+name+"**. 
                  You can only un-nominate your own votes. 
                  If you would like to remove an entry, use 'pennbot rm lunch <place>'"

  robot.respond /(?:unlunch|(?:remove|rm) lunch) (.*)$/i, (res) ->
    #get all relevant variables
    food_list = new PlaceList(robot.brain.data.food_list)
    denominate_list = new PlaceList(robot.brain.data.denominate_list)
    nom = res.match[1].toLowerCase().trim()
    user = res.message.user.name
    #check if nominee if even in food_list
    if !food_list.find(nom) and !denominate_list.find(nom)
      res.send "**"+nom+"** is not on the lunch list"
      return
    id = denominate_list.find(nom)
    #initialize if not in the denominate_list
    if !id
      id = denominate_list.add(nom)
    nominee = denominate_list.get(id)
    name = nominee.name
    #can't vote more than once
    if user in nominee.users
      res.send "You've already nominated **"+name+"**, id "+id+", for removal.
                It has "+nominee.users.length+" vote(s)."
    else
      nominee.users.push user
      #more than 5 votes moves the nominee off the lunch list
      if nominee.users.length > NUM_VOTES
        food_list.remove(food_list.get(food_list.find(nominee.name)))
        denominate_list.remove(nominee)
        robot.brain.set 'food_list', food_list
        res.send name+" has been removed the lunch list."
      else
        res.send "OK. **"+name+"**, id "+id+", 
                  has "+nominee.users.length+" vote(s) for removal."
    robot.brain.data.denominate_list = denominate_list.places

  robot.respond /((list|ls) lunch|what('s|s| is) on the( lunch) list).*/i, (res) ->
    places = robot.brain.data.food_list
    if !Object.keys(places).length
      res.send "The lunch list is empty."
    else
      foodString = ""
      for k,v of places
        foodString += v.name+", "
      res.send foodString

  robot.respond /((list|ls) noms|(what|who) (are the nom(inee)?s|is nominated)( for lunch)?).*/i, (res) ->
    #get all relevant variables
    places = robot.brain.data.nominee_list
    if !Object.keys(places).length
      res.send "The nominee list is empty."
    else
      nomineeString = "Nominee list is: \n"
      for k,v of places
        nom = "**"+v.name+"**: id "+v.id+" : "+v.users.join(', ')
        nomineeString += nom+"\n"
      res.send nomineeString

  robot.respond /((list|ls) (removals|unlunch)|(what|who)( is| are) up for removal( from the lunch list)?).*/i, (res) ->
    #get all relevant variables
    places = robot.brain.data.denominate_list
    if !Object.keys(places).length
      res.send "The removal list is empty."
    else
      names = ("**"+lunch.name+"**: "+lunch.users.join(', ') for lunch in places)
      nomineeString = "Entries up for removal: \n"
      for k,v of places
        nom = "**"+v.name+"**: id "+v.id+" : "+v.users.join(', ')
        nomineeString += nom+"\n"
      res.send nomineeString

  robot.respond /(what('s|s| is) for lunch.*|(where|what) should .* (eat|lunch).*)/i, (res) ->
    food_list = new PlaceList(robot.brain.data.food_list)
    day = new Date
    today = day.getDay()
    today_date = day.getDate()
    #compare stored day with today's date
    stored_day = robot.brain.get('food_day')
    stored_food = robot.brain.get('food_rec')
    if stored_day == today_date
      res.send "I've already said "+stored_food
    else if today == 1
      today_food_rec = "HEP Lunch"
      res.send today_food_rec
      robot.brain.data.user_reviewed_today = []
      robot.brain.set 'food_day', today_date
      robot.brain.set 'food_rec', today_food_rec
    else
      robot.brain.data.user_reviewed_today = []
      today_food_rec = res.random food_list.list()
      res.send today_food_rec
      robot.brain.set 'food_day', today_date
      robot.brain.set 'food_rec', today_food_rec

  robot.respond /what('s|s| is) for (second|2nd) lunch.*/i, (res) ->
    food_list = new PlaceList(robot.brain.data.food_list)
    day = new Date
    today = day.getDay()
    today_date = day.getDate()
    #compare stored day with today's date
    stored_day = robot.brain.get('food_day_2')
    stored_food = robot.brain.get('food_rec_2')
    if stored_day == today_date
      res.send "I've already said "+stored_food
    else
      today_food_rec = res.random food_list.list()
      res.send today_food_rec
      robot.brain.set 'food_day_2', today_date
      robot.brain.set 'food_rec_2', today_food_rec

  robot.respond /review lunch location:\s?"(.*)" rating:\s?"(.*)" comment:\s?"(.*)"$/i, (res) ->
    ##asking for lunch sets the suggested location in the row
    day = new Date
    today_date = day.getDate()
    stored_day = robot.brain.get('food_day')
    if stored_day != today_date
      res.send "Before you give a review, you have to ask what's for lunch."
      return
    #no one is allowed to vote more than once a day
    username = res.message.user.name
    if username in robot.brain.data.user_reviewed_today
      res.send "You've already given a review for today."
      return
    # send the review to the database
    place = res.match[1] or ''
    rating = res.match[2] or ''
    comment = res.match[3] or ''
    insertReview(robot, res, username, place, rating, comment)

  robot.respond /(?:I )brought lunch rating:\s?"(.*)" comment:\s?"(.*)"$/i, (res) ->
    ##asking for lunch sets the suggested location in the row
    day = new Date
    today_date = day.getDate()
    stored_day = robot.brain.get('food_day')
    if stored_day != today_date
      res.send "Before you give a review, you have to ask what's for lunch."
      return
    #no one is allowed to vote more than once a day
    username = res.message.user.name
    if username in robot.brain.data.user_reviewed_today
      res.send "You've already given a review for today."
      return
    # send the review to the database
    place = 'brought'
    rating = res.match[1] or ''
    comment = res.match[2] or ''
    insertReview(robot, res, username, place, rating, comment)

  robot.respond /lunch csv/i, (res) ->
      robot.http("https://bots.bijanhaney.com/lunch/getcsv")
        .get() (err, response, body) ->
          if err
            res.send "Encountered an error #{err}"
          else
            result = JSON.parse body
            if result.success
              res.send "Successfully generated CSV: #{result.text}"
            else
              res.send "#{result.text}"

  robot.respond /check lunch review/i, (res) ->
    #asking for lunch sets the suggested location in the row
    day = new Date
    today_date = day.getDate()
    stored_day = robot.brain.get('food_day')
    if res.message.user.name == "Shell"
      res.send robot.brain.data.user_reviewed_today.join(', ')
    if (stored_day == today_date) and (robot.brain.data.user_reviewed_today.length < 2)
      res.send "Please consider leaving a review about today's lunch. 'pennbot review lunch location:\"[food]\" rating:\"[1 - 10]\" comment:\"[optional]\"' "
