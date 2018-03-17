#
#Commands:
#   hubot (what's for lunch / where should I eat ) - Selects a place to get lunch.
#   hubot nominate <place>  - adds a tally for X to be added to the lunch list.
#   hubot unnominate <place>  - remove your vote for X to be added to the lunch list.
#   hubot unlunch <place> - adds a tally for X to be removed from the lunch list.
#   hubot what's on the lunch list - list the lunch options that are saved.
#   hubot (what / who) is nominated - list the nominees for the lunch list and their votes.
#   hubot (what / who) is up for removal - list the nominees for removal and their votes.

class PlaceList
  constructor: (load_places) ->
    @places = load_places
  get: ->
    return @places
  set: (places) ->
    @places = places
  #creates a new place
  addPlace: (place_name) ->
    id = Math.floor(Math.random() * 1000000) while !id? || @places[id]  
    @places[id] = { id:id, name: place_name, users: []} 
    return id
  #gets the id for place, or returns false
  getId: (place_name) ->
    if @places[place_name]
      return place_name
    else
      for key,val of @places
        if val.name == place_name
          return key
      return false 
  #removes a place, returns true is success
  removePlace: (place) ->
    id = this.getId(place)
    if !id
      return false
    else
      delete @places[id]
      return true
  #delete place from this list, and move to new list
  movePlaceToList: (place, new_list) ->
    id = this.getId(place)
    if !id
      return false
    place_name = @places[id].name
    new_id = new_list.addPlace(place_name)
    delete @places[id]
    return new_id
  #get users from list of places
  getUsers: (place) ->
    id = this.getId(place)
    if !id
      return false
    return @places[id].users
  #add a user to the place's user list
  addUserToPlace: (user, place) ->
    #is it place id, or place name?
    id = this.getId(place)
    if !id
      return false
    @places[id].users.push user
  #add a user to the place's user list, returns true if success
  removeUserFromPlace: (user, place) ->
    #is it place id, or place name?
    id = this.getId(place)
    if !id
      return false
    i = @places[id].users.indexOf(user)
    if i != -1
      @places[id].users.splice(i, 1)
      return true
    else
      return false

module.exports = (robot) ->
  NUM_VOTES = 0 #number of votes required to change lists
  robot.brain.data.nominee_list or= {}
  robot.brain.data.denominate_list or= {}
  robot.brain.data.food_list or= {}
  #intialize foodRec if it doesn't exist
  if !robot.brain.get('foodRec')
    robot.brain.set 'foodDay', -1
    robot.brain.set 'foodRec', 'mexicali'
  if !robot.brain.get('food2Rec')
    robot.brain.set 'food2Day', -1
    robot.brain.set 'food2Rec', 'mexicali'

  robot.respond /nominate (.*)/i, (res) ->
    #get all relevant variables
    food_list = new PlaceList(robot.brain.data.food_list)
    nominee_list = new PlaceList(robot.brain.data.nominee_list)
    nominee = res.match[1].toLowerCase().trim()
    user = res.message.user.name
    id = nominee_list.getId(nominee)
    #if first time place is nominated, initialize the nominee
    if !id
      id = nominee_list.addPlace(nominee)
    #can't vote more than once
    if user in nominee_list.getUsers(id)
      res.send "You've already nominated "+nominee+". It has "+nominee_list.getUsers(id).length+" vote(s)."
    else
      nominee_list.addUserToPlace(user, id)
      #more than 5 votes moves the nominee to the lunch list
      if nominee_list.getUsers(id).length > NUM_VOTES
        nominee_list.movePlaceToList(nominee, food_list)
        robot.brain.data.food_list = food_list.places
        res.send nominee+" has been added to the lunch list."
      else
        robot.brain.data.nominee_list = nominee_list.places
        res.send "OK. "+nominee+" has "+nominee_list.getUsers(id).length+" vote(s)."
    
  robot.respond /unnominate (.*)/i, (res) ->
    #get all relevant variables
    nominee_list = new PlaceList(robot.brain.data.nominee_list)
    nominee = res.match[1].toLowerCase().trim()
    user = res.message.user.name
    id = nominee_list.getId(nominee)
    #check if nominee exists
    if !id or (nominee_list.getUsers(id).length == 0)
      res.send nominee+" hasn't been nominated for the lunch list by anyone."
    else
      #find user's vote, and remove it.
      if nominee_list.removeUserFromPlace(user, nominee)
        if nominee_list.getUsers(id).length == 0 
          nominee_list.removePlace(nominee)
          res.send "Your vote has been removed. "+nominee+" has 0 vote(s)."
        else
          res.send "Your vote has been removed. "+nominee+" has "+nominee_list.getUsers(id).length+" vote(s)."
        robot.brain.data.nominee_list = nominee_list.places
      else
        res.send "You have not nominated "+nominee+". You can only un-nominate your own votes. If you would like to remove an entry, use 'remove X from the lunch list'"

  robot.respond /unlunch (.*)/i, (res) ->
    #get all relevant variables
    food_list = new PlaceList(robot.brain.data.food_list)
    denominate_list = new PlaceList(robot.brain.data.denominate_list)
    nominee = res.match[1].toLowerCase().trim()
    user = res.message.user.name
    #check if nominee if even in food_list
    if !food_list.getId(nominee)
      res.send nominee+" is not on the lunch list"
      return
    id = denominate_list.getId(nominee)
    #initialize if not in the denominate_list
    if !id
      id = denominate_list.addPlace(nominee)
    #can't vote more than once
    if user in denominate_list.getUsers(id)
      res.send "You've already nominated "+nominee+" for removal. It has "+denominate_list.getUsers(id).length+" vote(s)."
    else
      denominate_list.addUserToPlace(user, id)
      #more than 5 votes moves the nominee to the lunch list
      if denominate_list.getUsers(id).length > NUM_VOTES
        food_list.removePlace(nominee)
        denominate_list.removePlace(id)
        robot.brain.set 'food_list', food_list
        res.send nominee+" has been removed the lunch list."
      else
        res.send "OK. "+nominee+" has "+denominate_list.getUsers(id).length+" vote(s) for removal."
    robot.brain.data.denominate_list = denominate_list.places

  robot.respond /what('s|s| is) on the( lunch) list.*/i, (res) ->
    places = robot.brain.data.food_list
    if !Object.keys(places).length
      res.send "The lunch list is empty."
    else
      foodString = "Here it is:\n"
      for k,v of places
        foodString += v.name+", "
      res.send foodString

  robot.respond /(what|who) (are the nominees|is nominated)( for lunch)?.*/i, (res) ->
    #get all relevant variables
    places = robot.brain.data.nominee_list
    if !Object.keys(places).length
      res.send "The nominee list is empty."
    else
      nomineeString = "Nominee list is: \n"
      for k,v of places
        nom = "**"+v.name+"**: "+v.users.join(', ') 
        nomineeString += nom+"\n"
      res.send nomineeString

  robot.respond /(what|who) is up for removal( from the lunch list)?.*/i, (res) ->
    #get all relevant variables
    places = robot.brain.data.denominate_list
    if !Object.keys(places).length
      res.send "The removal list is empty."
    else
      names = ("**"+lunch.name+"**: "+lunch.users.join(', ') for lunch in places)
      nomineeString = "Entries up for removal: \n"
      for k,v of places
        nom = "**"+v.name+"**: "+v.users.join(', ') 
        nomineeString += nom+"\n"
      res.send nomineeString

  robot.respond /(what('s|s| is) for lunch.*|(where|what) should .* (eat|lunch).*)/i, (res) ->
    food_list = new PlaceList(robot.brain.get('food_list'))
    day = new Date
    today = day.getDay()
    todayDate = day.getDate()
    #compare stored day with today's date
    storedDay = robot.brain.get('foodDay')
    storedFood = robot.brain.get('foodRec')
    if today == 1
      res.send "HEP Lunch"
    else if storedDay == todayDate
      res.send "I've already said "+storedFood
    else
      todayFoodRec = res.random food_list.places
      res.send todayFoodRec.name
      robot.brain.set 'foodDay', todayDate
      robot.brain.set 'foodRec', todayFoodRec

  robot.respond /what('s|s| is) for (second|2nd) lunch.*/i, (res) ->
    food_list = new PlaceList(robot.brain.get('food_list'))
    day = new Date
    today = day.getDay()
    todayDate = day.getDate()
    #compare stored day with today's date
    storedDay = robot.brain.get('food2Day') 
    storedFood = robot.brain.get('food2Rec') 
    if storedDay == todayDate
      res.send "I've already said "+storedFood
    else
      todayFoodRec = res.random food_list.places
      res.send todayFoodRec.name
      robot.brain.set 'food2Day', todayDate
      robot.brain.set 'food2Rec', todayFoodRec

