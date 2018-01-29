# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#Commands:
#   hubot roll a die - Roll a six-sided die.
#   hubot flip a coin - Flip a coin.
#   hubot (what's for lunch / where should I eat ) - Selects a place to get lunch.
#

module.exports = (robot) ->
#   robot.hear /badger/i, (res) ->
#     res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
#  
#   robot.respond /open the (.*) doors/i, (res) ->
#     doorType = res.match[1]
#     if doorType is "pod bay"
#       res.reply "I'm afraid I can't let you do that."
#     else
#       res.reply "Opening #{doorType} doors"
#  
#   robot.hear /I like pie/i, (res) ->
#     res.emote "makes a freshly baked pie"
#  
   thanks = ["you're welcome!", "😊 ", 'no problem']
  
   robot.hear /thanks (pennbot|pb).*/i, (res) ->
     res.send res.random thanks

   robot.respond /thanks.*/i, (res) ->
     res.send res.random thanks

# food recommender 
   food = ["Lovash", "Lovash", "MexiCali", "Mexicali", "Rice under lamb", "Magic Carpet", "Dos Hermanos", "Dos Hermanos", "Old Nelson", "Decide for yourself.", "Tilapia burrito"]

   robot.respond /(where|what) should .* eat.*/i, (res) ->
     day = new Date
     today = day.getDay()
     todayDate = day.getDate()
     storedDay = robot.brain.get('foodDay') or todayDate
     storedFood = robot.brain.get('foodRec') or 'Mexicali'
     if today == 1
       res.send "HEP Lunch"
     else if storedDay == todayDate
       res.send "I've already said "+storedFood
     else
       todayFoodRec = res.random food
       res.send todayFoodRec
       robot.brain.set 'foodDay', todayDate
       robot.brain.set 'foodRec', todayFoodRec

   robot.respond /(where|what) should .* lunch.*/i, (res) ->
     day = new Date
     today = day.getDay()
     todayDate = day.getDate()
     storedDay = robot.brain.get('foodDay') or todayDate
     storedFood = robot.brain.get('foodRec') or 'Mexicali'
     if today == 1
       res.send "HEP Lunch"
     else if storedDay == todayDate
       res.send "I've already said "+storedFood
     else
       todayFoodRec = res.random food
       res.send todayFoodRec
       robot.brain.set 'foodDay', todayDate
       robot.brain.set 'foodRec', todayFoodRec

   robot.respond /what('s|s| is) for lunch.*/i, (res) ->
     day = new Date
     today = day.getDay()
     todayDate = day.getDate()
     storedDay = robot.brain.get('foodDay') or todayDate
     storedFood = robot.brain.get('foodRec') or 'Mexicali'
     if today == 1
       res.send "HEP Lunch"
     else if storedDay == todayDate
       res.send "I've already said "+storedFood
     else
       todayFoodRec = res.random food
       res.send todayFoodRec
       robot.brain.set 'foodDay', todayDate
       robot.brain.set 'foodRec', todayFoodRec

   coin = ["Heads","Tails"]
   robot.respond /flip a coin/i, (res) ->
     res.send res.random coin

   dice = ["One","Two","Three","Four","Five","Six"]
   robot.respond /roll a dice/i, (res) ->
     res.send res.random dice
#  
#   robot.topic (res) ->
#     res.send "#{res.message.text}? That's a Paddlin'"
#  
#  
#   enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
#   leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
#  
#   robot.enter (res) ->
#     res.send res.random enterReplies
#   robot.leave (res) ->
#     res.send res.random leaveReplies
#  
#   answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
#  
#   robot.respond /what is the answer to the ultimate question of life/, (res) ->
#     unless answer?
#       res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
#       return
#     res.send "#{answer}, but what is the question?"
#  
#   robot.respond /you are a little slow/, (res) ->
#     setTimeout () ->
#       res.send "Who you calling 'slow'?"
#     , 60 * 1000
#  
#   annoyIntervalId = null
#  
#   robot.respond /annoy me/, (res) ->
#     if annoyIntervalId
#       res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
#       return
#  
#     res.send "Hey, want to hear the most annoying sound in the world?"
#     annoyIntervalId = setInterval () ->
#       res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
#     , 1000
#  
#   robot.respond /unannoy me/, (res) ->
#     if annoyIntervalId
#       res.send "GUYS, GUYS, GUYS!"
#       clearInterval(annoyIntervalId)
#       annoyIntervalId = null
#     else
#       res.send "Not annoying you right now, am I?"
#  
#   robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
#     room   = req.params.room
#     robot.messageRoom room, "this is a test"
#     data = if req.body.payload? then JSON.parse req.body.payload else req.body
#     secret = data.secret
#  
#     robot.messageRoom room, "I have a secret: #{secret}"
#  
#     res.send 'OK'
#  
#  
#   robot.error (err, res) ->
#     robot.logger.error "DOES NOT COMPUTE"
#  
#     if res?
#       res.reply "DOES NOT COMPUTE"
#  
#   robot.respond /have a soda/i, (res) ->
#     # Get number of sodas had (coerced to a number).
#     sodasHad = robot.brain.get('totalSodas') * 1 or 0
#  
#     if sodasHad > 4
#       res.reply "I'm too fizzy.."
#  
#     else
#       res.reply 'Sure!'
#  
#       robot.brain.set 'totalSodas', sodasHad+1
#  
#   robot.respond /sleep it off/i, (res) ->
#     robot.brain.set 'totalSodas', 0
#     res.reply 'zzzzz'
