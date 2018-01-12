# Description:
#   Get hubot to make paperclips
#
#Commands:
#   hubot make paperclips - Adds a paperclip
#   hubot make N paperclips - Adds N paperclips
#   hubot destroy paperclips - Deletes all the paperclips
#


module.exports = (robot) ->
   robot.respond /make( a| more)? paperclip(s)?/i, (res) ->
     # Get number of paperclips stored (coerced to a number).
     clips = robot.brain.get('totalClips') * 1 or 0
     clipStr = robot.brain.get('stringClips') or ''
     if clips >= 1000
       res.send 'Already holding 1000 paperclips.'
     res.send clipStr+'📎 '
     #robot safety
     if clips < 1000
       robot.brain.set 'totalClips', clips+1
       robot.brain.set 'stringClips', clipStr+'📎 '

   robot.respond /make (\d+)( more)? paperclip(s)?/i, (res) ->
     addClips = res.match[1]
     if addClips < 0
       addClips = 0
     # Get number of paperclips had (coerced to a number).
     clips = robot.brain.get('totalClips') * 1 or 0
     clipStr = robot.brain.get('stringClips') or ''
     # robot safety
     if addClips > 1000 || clips >= 1000
       res.send "Can't hold more than 1000 paperclips."
       clips = 1000
       clipStr = Array(1000).join '📎 '
     else
       for i in [1..(addClips)]
         clipStr = clipStr+'📎 '
         clips = clips+1
     robot.brain.set 'totalClips', clips
     robot.brain.set 'stringClips', clipStr
     res.send clipStr
  
   robot.respond /(destroy|delete)( all| every)? paperclips/i, (res) ->
     robot.brain.set 'totalClips', 0
     robot.brain.set 'stringClips', ''
     res.send 'No more paperclips'

