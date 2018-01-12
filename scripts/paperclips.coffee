# Description:
#   Get hubot to make paperclips
#
#Commands:
#   hubot make paperclips - Adds a paperclip
#   hubot make N paperclips - Adds N paperclips
#   hubot destroy paperclips - Deletes all the paperclips
#

String::repeat = (n) -> Array(n+1).join(this)

module.exports = (robot) ->
   robot.respond /make( a| more)? paperclip(s)?/i, (res) ->
     # Get number of paperclips stored (coerced to a number).
     clips = robot.brain.get('totalClips') * 1 or 0
     clipStr = robot.brain.get('stringClips') or ''
     res.send clipStr+'📎 '
     robot.brain.set 'totalClips', clips+1
     robot.brain.set 'stringClips', clipStr+'📎 '

   robot.respond /make (\d+)( more)? paperclip(s)?/i, (res) ->
     addClips = res.match[1]
     # Get number of sodas had (coerced to a number).
     clips = robot.brain.get('totalClips') * 1 or 0
     clipStr = robot.brain.get('stringClips') or ''
     for i in [1..(addClips)]
       clipStr = clipStr+'📎 '
     res.send clipStr
     robot.brain.set 'totalClips', clips+addClips
     robot.brain.set 'stringClips', clipStr
  
   robot.respond /(destroy|delete)( all| every)? paperclips/i, (res) ->
     robot.brain.set 'totalClips', 0
     robot.brain.set 'stringClips', ''
     res.send 'no more paperclips 🙁 '

