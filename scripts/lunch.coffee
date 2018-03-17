#
#Commands:
#   hubot (what's for lunch / where should I eat ) - Selects a place to get lunch.
#   hubot (nom)inate <place>  - adds a tally for <place> to be added to the lunch list.
#   hubot (unnom)inate <place>  - remove your vote for <place> to be added to the lunch list.
#   hubot remove lunch <place> - adds a tally for <place> to be removed from the lunch list.
#   hubot list lunch - list the lunch options that are saved.
#   hubot list noms - list the nominees for the lunch list and their votes.
#   hubot list removals - list the nominees for removal and their votes.

class PlaceList
  constructor: (load_places) ->
    @places = load_places
  get: ->
    return @places
  set: (places) ->
    @places = places
  #creates a new place
  addPlace: (place_name) ->
    id = Math.floor(Math.random() * 1000) while !id? || @places[id]  
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
  #get name
  getName: (place) ->
    id = this.getId(place)
    if !id
      return false
    return @places[id].name
  #get users from list of places
  getUsers: (place) ->
    id = this.getId(place)
    if !id
      return false
    return @places[id].users
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
  NUM_VOTES = 4 #treshold of votes required to change lists
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

  robot.respond /(?:nom|nominate) (.*)/i, (res) ->
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
    name = nominee_list.getName(id)
    if user in nominee_list.getUsers(id)
      res.send "You've already nominated **"+name+"**. It has "+nominee_list.getUsers(id).length+" vote(s)."
    else
      nominee_list.addUserToPlace(user, id)
      #more than 5 votes moves the nominee to the lunch list
      if nominee_list.getUsers(id).length > NUM_VOTES
        nominee_list.movePlaceToList(name, food_list) #use actual name here
        robot.brain.data.food_list = food_list.places
        res.send "**"+name+"** has been added to the lunch list."
      else
        res.send "OK. **"+name+"**, id "+id+", has "+nominee_list.getUsers(id).length+" vote(s)."
      robot.brain.data.nominee_list = nominee_list.places
    
  robot.respond /(?:unnom|unnominate) (.*)/i, (res) ->
    #get all relevant variables
    nominee_list = new PlaceList(robot.brain.data.nominee_list)
    nominee = res.match[1].toLowerCase().trim()
    user = res.message.user.name
    id = nominee_list.getId(nominee)
    #check if nominee exists
    if !id or (nominee_list.getUsers(id).length == 0)
      res.send "**"+nominee+"** hasn't been nominated for the lunch list by anyone. To remove an entry, use 'rm lunch <place>'"
    else
      #find user's vote, and remove it.
      name = nominee_list.getName(id)
      if nominee_list.removeUserFromPlace(user, nominee)
        if nominee_list.getUsers(id).length == 0 
          nominee_list.removePlace(id)
          res.send "Your vote has been removed. **"+name+"** has 0 vote(s)."
        else
          res.send "Your vote has been removed. **"+name+"**, id "+id+", has "+nominee_list.getUsers(id).length+" vote(s)."
        robot.brain.data.nominee_list = nominee_list.places
      else
        res.send "You have not nominated **"+name+"**. You can only un-nominate your own votes. If you would like to remove an entry, use 'rm lunch <place>'"

  robot.respond /(?:unlunch|(?:remove|rm) lunch) (.*)/i, (res) ->
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
    name = denominate_list.getName(id)
    if user in denominate_list.getUsers(id)
      res.send "You've already nominated **"+name+"**, id "+id+", for removal. It has "+denominate_list.getUsers(id).length+" vote(s)."
    else
      denominate_list.addUserToPlace(user, id)
      #more than 5 votes moves the nominee to the lunch list
      if denominate_list.getUsers(id).length > NUM_VOTES
        food_list.removePlace(nominee) #need to use actual name rather than ID
        denominate_list.removePlace(id)
        robot.brain.set 'food_list', food_list
        res.send nominee+" has been removed the lunch list."
      else
        res.send "OK. **"+name+"**, id "+id+", has "+denominate_list.getUsers(id).length+" vote(s) for removal."
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

  robot.respond /((list|ls) removals|(what|who)( is| are) up for removal( from the lunch list)?).*/i, (res) ->
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

