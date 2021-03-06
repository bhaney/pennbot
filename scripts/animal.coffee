# Description:
#   Make animals say things
#
# Commands:
#   hubot cowsay <phrase> - Make the cow say <phrase>
#   hubot <animal>say <phrase> - Make the animal say <phrase>
#   hubot randsay <phrase> - Makes a random animal say <phrase>
#   hubot list animals - See which animals can say things
#

cow = require('cowsay')
cows = ['cheese','bunny','dragon','elephant','mule','octopus',
        'flaming-sheep','goat','ghostbusters','hedgehog','kiwi',
        'kitty', 'mech-and-cow','moose','khilesh','lobster',
        'sheep','small','squirrel','stegosaurus','bees','bijan',
        'turtle','whale','elephant-in-snake','moofasa','owl',
        'skeleton','turkey','tux','mail','cat', 'armadillo','shrek']

module.exports = (robot) ->

  robot.respond /cowsay (.*)$/i, (res) ->
    cowtext = cow.say({
      text: res.match[1]
    })
    res.send "``` \n#{cowtext} ```"

  robot.respond /list animals$/i, (res) ->
    res.send cows.join(', ')

  robot.respond /randsay (.*)$/i, (res) ->
    rando = res.random cows
    cowtext = cow.say({
      f: rando,
      text: res.match[1]
    })
    res.send "``` \n#{cowtext} ```"
  
  animal_choices = (animal for animal in cows).sort().join('|')
  pattern = new RegExp("(#{animal_choices})say (.*)$", 'i')
  robot.respond pattern, (res) ->
    animal = res.match[1]
    cowtext = cow.say({
      f: animal,
      text: res.match[2]
    })
    res.send "``` \n#{cowtext} ```"
