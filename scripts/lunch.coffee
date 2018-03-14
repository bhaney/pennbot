#
#Commands:
#   hubot (what's for lunch / where should I eat ) - Selects a place to get lunch.
#   hubot nominate X for lunch - adds a tally for X to be added to the lunch list.
#   hubot unnominate X for lunch - remove your vote for X to be added to the lunch list.
#   hubot remove X from the lunch list - adds a tally for X to be removed from the lunch list.
#   hubot what's on the lunch list - list the lunch options that are saved.
#   hubot (what / who) are the nominees for lunch - list the nominees for the lunch list and their votes.
#   hubot (what / who) is nominated for removal - list the nominees for removal and their votes.

module.exports = (robot) ->
# food recommender 
   food = ["Lovash", "MexiCali", "Mexicali", "Rice under lamb", "Magic Carpet", "Dos Hermanos", "Dos Hermanos", "Old Nelson", "Decide for yourself", "Cucina Zapata"]
   #initialize foodVec if it doesn't exist
   if !robot.brain.get('foodVec')
     food = food.map (x) -> x.toLowerCase() 
     robot.brain.set 'foodVec', food

   robot.respond /(what('s|s| is) for lunch.*|(where|what) should .* (eat|lunch).*)/i, (res) ->
     foodVec = robot.brain.get('foodVec')
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
     foodVec = robot.brain.get('foodVec')
     nomineeList = robot.brain.get('nomineeList')
     nominee = res.match[1].toLowerCase().trim()
     user = res.message.user.name
     #if first time place is nominated, initialize the nominee
     if !nomineeList[nominee]
       nomineeList[nominee] = []
     #can't vote more than once
     if user in nomineeList[nominee] 
       res.send "You've already nominated "+nominee+". It has "+nomineeList[nominee].length+" vote(s)."
     else
       nomineeList[nominee].push user
       #more than 5 votes adds the nominee to the lunch list
       if nomineeList[nominee].length > 5
         foodVec.push nominee
         robot.brain.set 'foodVec', foodVec
         res.send nominee+" has been added to the lunch list."
         delete nomineeList[nominee]
       else
         res.send "OK. "+nominee+" has "+nomineeList[nominee].length+" vote(s)."
     robot.brain.set 'nomineeList', nomineeList
     
   robot.respond /unnominate (.*) (for|from)( the)? lunch( list)?.*/i, (res) ->
     #initialize nominee object if it does not exist
     if !robot.brain.get('nomineeList')
       robot.brain.set 'nomineeList', {}
     #get all relevant variables
     nomineeList = robot.brain.get('nomineeList')
     nominee = res.match[1].toLowerCase().trim()
     user = res.message.user.name
     #check if nominee exists
     if !nomineeList[nominee] or (nomineeList[nominee].length == 0)
       res.send nominee+" hasn't been nominated for the lunch list by anyone."
     else
       #find user's vote, and remove it.
       i = nomineeList[nominee].indexOf(user)
       if i != -1
         nomineeList[nominee].splice(i, 1)
         res.send "Your vote has been removed. "+nominee+" has "+nomineeList[nominee].length+" vote(s)."
         if nomineeList[nominee].length == 0
           delete nomineeList[nominee]
         robot.brain.set 'nomineeList', nomineeList
       else
         res.send "You have not nominated "+nominee+". You can only un-nominate your own votes. If you would like to remove an entry, use 'remove X from the lunch list'"

   robot.respond /remove (.*) (from|for)( the)? lunch( list)?.*/i, (res) ->
     #initialize nominee object if it does not exist
     if !robot.brain.get('denominateList')
       robot.brain.set 'denominateList', {}
     #get all relevant variables
     foodVec = robot.brain.get('foodVec')
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
         res.send "You've already nominated "+nominee+" for removal. It has "+nomineeList[nominee].length+" vote(s)."
       else
         nomineeList[nominee].push user
         #more than 5 votes deletes the nominee from the lunch list
         if nomineeList[nominee].length > 5
           i = foodVec.indexOf(nominee)
           if i is not -1
             foodVec.splice(i, 1)
           robot.brain.set 'foodVec', foodVec
           res.send nominee+" has been removed from the lunch list."
           delete nomineeList[nominee]
         else
           res.send "OK. "+nominee+" has "+nomineeList[nominee].length+" vote(s) for removal."
       robot.brain.set 'denominateList', nomineeList

   robot.respond /what('s|s| is) on the( lunch) list.*/i, (res) ->
     foodVec = robot.brain.get('foodVec')
     foodString = foodVec.join(', ')
     res.send foodString

   robot.respond /(what|who) (are the nominees|is nominated) for( the)? lunch( list)?.*/i, (res) ->
     #initialize nominee object if it does not exist
     if !robot.brain.get('nomineeList')
       robot.brain.set 'nomineeList', {}
     #get all relevant variables
     nomineeList = robot.brain.get('nomineeList')
     keyArr = Object.keys(nomineeList)
     nomineeString = "Nominee list is: \n"
     for nom in keyArr
       nomString = "**"+nom+"**: "+nomineeList[nom].join(', ')
       #nomString = "**"+nom+"**: "+nomineeList[nom].length
       nomineeString += nomString+"\n"
     res.send nomineeString

   robot.respond /(what|who) (are the nominees|is nominated)( up)? for removal( from the lunch list)?.*/i, (res) ->
     #initialize nominee object if it does not exist
     if !robot.brain.get('denominateList')
       robot.brain.set 'denominateList', {}
     #get all relevant variables
     nomineeList = robot.brain.get('denominateList')
     keyArr = Object.keys(nomineeList)
     nomineeString = "Entries up for removal are: \n"
     for nom in keyArr
       nomString = "**"+nom+"**: "+nomineeList[nom].join(', ')
       #nomString = "**"+nom+"**: "+nomineeList[nom].length
       nomineeString += nomString+"\n"
     res.send nomineeString

   robot.respond /what('s|s| is) for (second|2nd) lunch.*/i, (res) ->
     food2 = robot.brain.get('foodVec')
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

