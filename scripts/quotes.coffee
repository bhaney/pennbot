# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#Commands:
#   hubot aurelius - Receive wisdom from ancient Rome's preeminent Stoic.

quotes = {
  "Marcus Aurelius": ["People out for posthumous fame forget that the Generations To Come will be the same annoying people they know now. And just as mortal. What does it matter to you if they say x about you, or think y? Give yourself a gift: the present moment.",
                      "An arrow has one motion and the mind another. Even when pausing, even when weighing conclusions, the mind is moving forward, toward its goal.",
                      "Today I escaped from anxiety. Or no, I discarded it, because it was within me, in my own perceptions--not outside.",
                      "You can discard most of the junk that clutters your mind -things that exist only there-and clear out space for yourself: 1. by comprehending the scale of the world 2. by contemplating infinite time 3. by thinking of the speed with which things change- each part of every thing; the narrow space between our birth and death; the infinite time before; the equally unbounded time that follows.",
                      "During my illness, my conversations were not about my physical state; I did not waste my visitors' time with things of that sort, but went on discussing philosophy, and concentrated on one point in particular: how the mind can participate in the sensations of the body and yet maintain its serenity, and focus on its own well-being. Nor did I let my doctors strut about like grandees. I went on living my life the way it should be lived.",
                      "If they’ve made a mistake, correct them gently and show them where they went wrong. If you can’t do that, then the blame lies with you. Or no one.",
                      "Whatever happens to you has been waiting to happen since the beginning of time. The twining strands of fate wove both of them together: your own existence and the things that happen to you.",
                      "Epithets for yourself: Upright. Modest. Straightforward. Sane. Cooperative. Disinterested. Try not to exchange them for others. And if you should forfeit them, set about getting them back.",
                      "Why all this guesswork? You can see what needs to be done. If you can see the road, follow it. Cheerfully, without turning back. If not, hold up and get the best advice you can. If anything gets in the way, forge on ahead, making good use of what you have on hand, sticking to what seems right. (The best goal to achieve, and the one we fall short of when we fail.)",
                      "When you wake up, ask yourself: Does it make any difference to you if other people blame you for doing what's right? It makes no difference. ",
                      "Only a short time left. Live as if you were alone-out in the wilderness. No difference between here and there: the city that you live in is the world.",
                      "Stop talking about what the good man is like, and just be one.",
                      "Stop whatever you’re doing for a moment and ask yourself: Am I afraid of death because I wouldn’t be able to do this anymore?",
                      "When faced with people's bad behavior, turn around and ask when you have acted like that. When you saw money as a good, or pleasure, or social position. Your anger will subside as soon as you recognize that they acted under compulsion (what else could they do?). Or remove the compulsion, if you can.",
                      "Given the material we're made of, what’s the sanest thing that we can do or say? Whatever it may be, you can do or say it. Don't pretend that anything’s stopping you.",
                      "Learn to ask of all actions, “Why are they doing that?” Starting with your own.",
                      "'And your profession?' 'Goodness.' (And how is that to be achieved, except by thought--about the world, about the nature of people?)",
                      "Someone despises me. That’s their problem. Mine: not to do or say anything despicable. Someone hates me. Their problem. Mine: to be patient and cheerful with everyone, including them. Ready to show them their mistake. Not spitefully, or to show off my own self-control, but in an honest, upright way. Like Phocion (if he wasn't just pretending). That’s what we should be like inside, and never let the gods catch us feeling anger or resentment.",
                      "Four habits of thought to watch for, and erase from your mind when you catch them. Tell yourself: This thought is unnecessary. This one is destructive to the people around you. This wouldn’t be what you really think (to say what you don’t think-the definition of absurdity). And the fourth reason for self-reproach: that the more divine part of you has been beaten and subdued by the degraded mortal part—the body and its stupid self-indulgence.",
                      "'If you don't have a consistent goal in life, you can't live it in a consistent way.' Unhelpful, unless you specify a goal. There is no common benchmark for all the things that people think are good-except for a few, the ones that affect us all. So the goal should be a common one-a civic one. If you direct all your energies toward that, your actions will be consistent. And so will you.",
                      "Socrates used to call popular beliefs 'the monsters under the bed'-only useful for frightening children with.",
                      "The Pythagoreans tell us to look at the stars at daybreak. To remind ourselves how they complete the tasks assigned them-always the same tasks, the same way. And their order, purity, nakedness. Stars wear no concealment.",
                      "This advice from Epicurean writings: to think continually of one of the men of old who lived a virtuous life.",
                      "At festivals the Spartans put their guests' seats in the shade, but sat themselves down anywhere.",
                      "Grapes. Unripe . . . ripened . . . then raisins. Constant transitions. Not the 'not' but the 'not yet.'",
                      "We need to master the art of acquiescence. We need to pay attention to our impulses, making sure they don’t go unmoderated, that they benefit others, that they're worthy of us. We need to steer clear of desire in any form and not try to avoid what's beyond our control.",
                      "Don't let anything deter you: other people's misbehavior, your own misperceptions, What People Will Say, or the feelings of the body that covers you (let the affected part take care of those). And if, when it's time to depart, you shunt everything aside except your mind and the divinity within . . . if it isn't ceasing to live that you're afraid of but never beginning to live properly . . . then you’ll be worthy of the world that made you.",
                      "It never ceases to amaze me: we all love ourselves more than other people, but care more about their opinion than our own. If a god appeared to us-or a wise human being, even -and prohibited us from concealing our thoughts or imagining anything without immediately shouting it out, we wouldn't make it through a single day. That's how much we value other people's opinions—instead of our own.",
                      "Practice even what seems impossible. The left hand is useless at almost everything, for lack of practice. But it guides the reins better than the right. From practice.",
                      "The student as boxer, not fencer. The fencer's weapon is picked up and put down again. The boxer's is part of him. All he has to do is clench his fist.",
                      "At all times, look at the thing itself-the thing behind the appearance-and unpack it by analysis: 1. cause. 2. substance. 3. purpose. 4. and the length of time it exists.",
                      "It's all in how you perceive it. You're in control. You can dispense with misperception at will, like rounding the point. Serenity, total calm, safe anchorage.",
                      "Constantly run down the list of those who felt intense anger at something: the most famous, the most unfortunate, the most hated, the most whatever. And ask: Where is all that now? Smoke, dust, legend...or not even a legend. How trivial the things we want so passionately are.",
                      "The longest-lived and those who will die soonest lose the same thing. The present is all that they can give up, since that is all you have, and what you do not have, you cannot lose.",
                      "Your ability to control your thoughts-treat it with respect. It’s all that protects your mind from false perceptions-false to your nature, and that of all rational beings. It's what makes thoughtfulness possible, and affection for other people, and submission to the divine.",
                      "Forget everything else. Keep hold of this alone and remember it: Each of us lives only now, this brief instant. The rest has been lived already, or is impossible to see. The span we live is small-small as the corner of the earth in which we live it. Small as even the greatest renown, passed from mouth to mouth by short-lived stick figures, ignorant alike of themselves and those long dead.",
                      "Choose not to be harmed-and you won’t feel harmed. Don’t feel harmed-and you haven’t been.",
                      "Joy for humans lies in human actions. Human actions: kindness to others, contempt for the senses, the interrogation of appearances, observation of nature and of events in nature.",
                      "To erase false perceptions, tell yourself: I have it in me to keep my soul from evil, lust and all confusion. To see things as they are and treat them as they deserve. Don’t overlook this innate ability.",
                      "Apply them constantly, to everything that happens: Physics. Ethics. Logic.",
                      "Nature’s job: to shift things elsewhere, to transform them, to pick them up and move them here and there. Constant alteration. But not to worry: there’s nothing new here. Everything is familiar. Even the proportions are unchanged.",
                      "Alexander and Caesar and Pompey. Compared with Diogenes, Heraclitus, Socrates? The philosophers knew the what, the why, the how. Their minds were their own. The others? Nothing but anxiety and enslavement.",
                      "Everything is here for a purpose, from horses to vine shoots. What’s surprising about that? Even the sun will tell you, 'I have a purpose,' and the other gods as well. And why were you born? For pleasure? See if that answer will stand up to questioning.",
                      "Don’t let your imagination be crushed by life as a whole. Don’t try to picture everything bad that could possibly happen. Stick with the situation at hand, and ask, 'Why is this so unbearable? Why can’t I endure it?' You’ll be embarrassed to answer.",
                      "Are Pantheia or Pergamos still keeping watch at the tomb of Verus? Chabrias or Diotimus at the tomb of Hadrian? Of course they aren’t. Would the emperors know it if they were? And even if they knew, would it please them? And even if it did, would the mourners live forever? Were they, too, not fated to grow old and then die? And when that happened, what would the emperors do?",
                      "This is what you deserve. You could be good today. But instead you choose tomorrow.",
                      "It can ruin your life only if it ruins your character. Otherwise it cannot harm you-inside or out.",
                      "Not to live as if you had endless years ahead of you. Death overshadows you. While you're alive and able-be good.",
                      "Constant awareness that everything is born from change. The knowledge that there is nothing nature loves more than to alter what exists and make new things like it. All that exists is the seed of what will emerge from it. You think the only seeds are the ones that make plants or children? Go deeper.",
                      "Don't be irritated at people's smell or bad breath. What's the point? With that mouth, with those armpits, they’re going to produce that odor. 'But they have a brain! Can’t they figure it out? Can’t they recognize the problem?' So you have a brain as well. Good for you. Then use your logic to awaken his. Show him. Make him realize it. If he'll listen, then you'll have solved the problem. Without anger."]
}

module.exports = (robot) ->
  #initialize variable in brain if doesn't exist
  robot.brain.data.aurelius_quotes ?= []

  robot.respond /aurelius/i, (res) ->
    aurelius_quotes = robot.brain.data.aurelius_quotes
    author = "Marcus Aurelius"
    #if quotes list is empty, re-fill it
    if aurelius_quotes.length == 0
      aurelius_quotes = quotes[author]
    #pick a random quote by marcus aurelius
    picked_quote = res.random aurelius_quotes
    res.send "> #{picked_quote} \n - *#{author}*"
    #delete that quote from the list to keep repeats from happening
    i = aurelius_quotes.indexOf(picked_quote)
    if i != -1
      aurelius_quotes.splice(i, 1)
    robot.brain.data.aurelius_quotes = aurelius_quotes

