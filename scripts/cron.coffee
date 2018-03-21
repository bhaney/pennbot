# Description:
#   register cron jobs to schedule messages on the current channel
#
# Commands:
#   hubot new job "<crontab format>" <message> - Schedule a cron job to say something
#   hubot new job <crontab format> "<message>" - Ditto
#   hubot new job <crontab format> say <message> - Ditto
#   hubot list jobs - List current cron jobs
#   hubot remove job <id> - remove job
#   hubot remove job with message <message> - remove with message
#
# Author:
#   miyagawa (https://github.com/miyagawa/hubot-cron)

cronJob = require('cron').CronJob
Qs = require 'qs'
try
  {Robot,Adapter,TextMessage,User} = require 'hubot'
catch
  prequire = require('parent-require')
  {Robot,Adapter,TextMessage,User} = prequire 'hubot'

JOBS = {}

createNewJob = (robot, pattern, user, message, do_action) ->
  id = Math.floor(Math.random() * 1000000) while !id? || JOBS[id]
  job = registerNewJob robot, id, pattern, user, message, "America/New_York", do_action
  robot.brain.data.cronjob[id] = job.serialize()
  return id

registerNewJobFromBrain = (robot, id, pattern, user, message, timezone, do_action) ->
  # for jobs saved in v0.2.0..v0.2.2
  user = user.user if "user" of user
  registerNewJob(robot, id, pattern, user, message, timezone, do_action)

storeJobToBrain = (robot, id, job) ->
  robot.brain.data.cronjob[id] = job.serialize()

  envelope = user: job.user, room: job.user.room
  robot.send envelope, "Job #{id} stored in brain asynchronously"

registerNewJob = (robot, id, pattern, user, message, timezone, do_action) ->
  job = new Job(id, pattern, user, message, timezone, do_action)
  try
    job.start(robot)
  catch err
    if err.message.includes('timezone')
      job = new Job(id, pattern, user, message, "America/New_York")
      robot.brain.data.cronjob[id] = job.serialize()
      job.start(robot)
  JOBS[id] = job
  return job

unregisterJob = (robot, id)->
  if JOBS[id]
    JOBS[id].stop()
    delete robot.brain.data.cronjob[id]
    delete JOBS[id]
    return yes
  no

handleNewJob = (robot, msg, pattern, message, act) ->
  do_action = if act is "action" then true else false
  try
    id = createNewJob robot, pattern, msg.message.user, message, do_action
    msg.send "Job #{id} created"
  catch error
    msg.send "Error caught parsing crontab pattern: #{error}. See http://crontab.org/ for the syntax"

updateJobTimezone = (robot, id, timezone) ->
  if JOBS[id]
    JOBS[id].stop()
    old_timezone = JOBS[id].timezone
    JOBS[id].timezone = timezone
    robot.brain.data.cronjob[id] = JOBS[id].serialize()
    JOBS[id].start(robot)
    return yes
  no

syncJobs = (robot) ->
  nonCachedJobs = difference(robot.brain.data.cronjob, JOBS)
  for own id, job of nonCachedJobs
    registerNewJobFromBrain robot, id, job...

  nonStoredJobs = difference(JOBS, robot.brain.data.cronjob)
  for own id, job of nonStoredJobs
    storeJobToBrain robot, id, job

difference = (obj1, obj2) ->
  diff = {}
  for id, job of obj1
    diff[id] = job if id !of obj2
  return diff

module.exports = (robot) ->
  robot.brain.data.cronjob or= {}
  robot.brain.on 'loaded', =>
    syncJobs robot

  robot.respond /(?:new|add) (job|action) "(.*?)" (.*)$/i, (msg) ->
    handleNewJob robot, msg, msg.match[2], msg.match[3], msg.match[1]

  robot.respond /(?:new|add) (job|action) (.*) "(.*?)" *$/i, (msg) ->
    handleNewJob robot, msg, msg.match[2], msg.match[3], msg.match[1]

  robot.respond /(?:new|add) (job|action) (.*?) say (.*?) *$/i, (msg) ->
    handleNewJob robot, msg, msg.match[2], msg.match[3], msg.match[1]

  robot.respond /(?:list|ls) jobs?/i, (msg) ->
    text = ''
    for id, job of JOBS
      room = job.user.reply_to || job.user.room
      if room == msg.message.user.reply_to or room == msg.message.user.room
        text += "#{id}: `#{job.pattern} tz:#{job.timezone}` \"#{job.message}\"\n"
    text = robot.adapter.removeFormatting text if robot.adapterName == 'slack'
    if text.length > 0
      msg.send text
    else
      msg.send 'There are no jobs saved in this channel.'

  robot.respond /(?:rm|remove|del|delete) job (\d+)/i, (msg) ->
    if (id = msg.match[1]) and unregisterJob(robot, id)
      msg.send "Job #{id} deleted"
    else
      msg.send "Job #{id} does not exist"

  robot.respond /(?:rm|remove|del|delete) job with message (.+)/i, (msg) ->
    message = msg.match[1]
    for id, job of JOBS
      room = job.user.reply_to || job.user.room
      if (room == msg.message.user.reply_to or room == msg.message.user.room) and job.message == message and unregisterJob(robot, id)
        msg.send "Job #{id} deleted"

  robot.respond /(?:tz|timezone) job (\d+) (.*)/i, (msg) ->
    if (id = msg.match[1]) and (timezone = msg.match[2]) and (job = JOBS[id])
      old_timezone = job.timezone
      try
        updateJobTimezone(robot, id, timezone)
        msg.send "Job #{id} updated to use #{timezone}"
      catch err
        msg.send "#{err} Select a location from this list https://timezonedb.com/time-zones"
        updateJobTimezone(robot, id, old_timezone)
    else
      msg.send "Job #{id} does not exist or timezone not specified"

class Job
  constructor: (id, pattern, user, message, timezone, do_action) ->
    @id = id
    @pattern = pattern
    # cloning user because adapter may touch it later
    clonedUser = {}
    clonedUser[k] = v for k,v of user
    @user = clonedUser
    @message = message
    @timezone = timezone
    @do_action = do_action

  start: (robot) ->
    @cronjob = new cronJob({
      cronTime: @pattern,
      onTick: () => @sendMessage(robot),
      start: false,
      timeZone: @timezone
    })
    @cronjob.start()

  stop: ->
    @cronjob.stop()

  serialize: ->
    [@pattern, @user, @message, @timezone, @do_action]

  sendMessage: (robot) ->
    envelope = user: @user, room: @user.room
    robot.send envelope, @message
    if @do_action
      msg = @message
      user = @user
      robot.receive new TextMessage(user, msg)
