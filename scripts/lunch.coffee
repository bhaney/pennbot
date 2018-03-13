#
#Commands:
#   hubot (what's for lunch / where should I eat ) - Selects a place to get lunch.
#   hubot nominate X for lunch - adds a tally for X to be added to the lunch list.
#   hubot remove X from the lunch list - adds a tally for X to be removed from the lunch list.
#   hubot what's on the lunch list - list the lunch options that are saved.

module.exports = (robot) ->
# food recommender 
   food = ["Lovash", "MexiCali", "Mexicali", "Rice under lamb", "Magic Carpet", "Dos Hermanos", "Dos Hermanos", "Old Nelson", "Decide for yourself", "Cucina Zapata"]
   #initialize foodVec if it doesn't exist
   if !robot.brain.get('foodVec')
     food = food.map (x) -> x.toLowerCase() 
     robot.brain.set 'foodVec', food
   foodVec = robot.brain.get('foodVec')
   food2 = foodVec

   robot.respond /(what('s|s| is) for lunch.*|(where|what) should .* (eat|lunch).*)/i, (res) ->
     day = new Date
     today = day.getDay()
     todayDate = day.getDate()
     #intialize the varible if it doesn't exist
     if !robot.brain.get('foodRec')
       robot.brain.set 'foodDay', 0
       robot.brain.set 'foodRec', res.random foodVec
     #compare stored day with today's date
     storedDay = robot.brain.get('foodDay')
     storedFood = robot.brain.get('foodRec')
     if today == 1
       res.send "HEP Lunch"
     else if storedDay == todayDate
       res.send "I've already said "+storedFood
     else
       todayFoodRec = res.random foodVec
       res.send todayFoodRec
       robot.brain.set 'foodDay', todayDate
       robot.brain.set 'foodRec', todayFoodRec

   robot.respond /nominate (.*) for( the)? lunch( list)?.*/i, (res) ->
     #initialize nominee object if it does not exist
     if !robot.brain.get('nomineeList')
       robot.brain.set 'nomineeList', {}
     #get all relevant variables
     nomineeList = robot.brain.get('nomineeList')
     nominee = res.match[1].toLowerCase().trim()
     user = res.message.user.name
     #if first time place is nominated, initialize the nominee
     if !nomineeList[nominee]
       nomineeList[nominee] = []
     #can't vote more than once
     if user in nomineeList[nominee] 
       res.send "You've already nominated "+nominee+". It has "+nomineeList[nominee].length+" votes."
     else
       nomineeList[nominee].push user
       #more than 5 votes adds the nominee to the lunch list
       if nomineeList[nominee].length > 5
         foodVec.push nominee
         robot.brain.set 'foodVec', foodVec
         res.send nominee+" has been added to the lunch list."
         delete nomineeList[nominee]
       else
         res.send "Your vote has been registered. "+nominee+" has "+nomineeList[nominee].length+" vote(s)."
     robot.brain.set 'nomineeList', nomineeList
     
   robot.respond /remove (.*) from( the)? lunch( list)?.*/i, (res) ->
     #initialize nominee object if it does not exist
     if !robot.brain.get('denominateList')
       robot.brain.set 'denominateList', {}
     #get all relevant variables
     nomineeList = robot.brain.get('denominateList')
     nominee = res.match[1].toLowerCase().trim()
     user = res.message.user.name
     #check if nominee if even in foodVec
     if nominee not in foodVec
       res.send nominee+" is not on the lunch list"
     else
       #if first time place is nominated, initialize the nominee
       if !nomineeList[nominee]
         nomineeList[nominee] = []
       #can't vote more than once
       if user in nomineeList[nominee] 
         res.send "You've already nominated "+nominee+" for removal. It has "+nomineeList[nominee].length+" votes."
       else
         nomineeList[nominee].push user
         if nomineeList[nominee].length > 5
           i = foodVec.indexOf(nominee)
           if i is not -1
             foodVec.splice(i, 1)
           robot.brain.set 'foodVec', foodVec
           res.send nominee+" has been removed from the lunch list."
           delete nomineeList[nominee]
         else
           res.send "Your vote has been registered. "+nominee+" has "+nomineeList[nominee].length+" vote(s) for removal."
       #more than 5 votes deletes the nominee from the lunch list
       robot.brain.set 'denominateList', nomineeList

   robot.respond /what('s|s| is) on the( lunch) list.*/i, (res) ->
     foodString = foodVec.toString()
     res.send foodString

   robot.respond /what('s|s| is) for (second|2nd) lunch.*/i, (res) ->
     day = new Date
     today = day.getDay()
     todayDate = day.getDate()
     #intialize the varible if it doesn't exist
     if !robot.brain.get('food2Rec')
       robot.brain.set 'food2Day', 0
       robot.brain.set 'food2Rec', res.random food2
     #compare stored day with today's date
     storedDay = robot.brain.get('food2Day') 
     storedFood = robot.brain.get('food2Rec') 
     if storedDay == todayDate
       res.send "I've already said "+storedFood
     else
       todayFoodRec = res.random food2
       res.send todayFoodRec
       robot.brain.set 'food2Day', todayDate
       robot.brain.set 'food2Rec', todayFoodRec
