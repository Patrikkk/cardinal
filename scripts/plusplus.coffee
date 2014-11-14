# Description:
#   Give or take away points. Keeps track and even prints out graphs.
#
# Dependencies:
#   "underscore": ">= 1.0.0"
#   "clark": "0.0.6"
#
# Configuration:
#
# Commands:
#   <name>++
#   <name>--
#   hubot score <name>
#   hubot top <amount>
#   hubot bottom <amount>
#   GET http://<url>/hubot/scores[?name=<name>][&direction=<top|botton>][&limit=<10>]
#
# Author:
#   ajacksified


_ = require('underscore')
clark = require('clark')
querystring = require('querystring')
ScoreKeeper = require('./scorekeeper')
brainLoaded = false
module.exports = (robot) ->
  scoreKeeper = null
  robot.brain.on 'loaded', ->
    if(brainLoaded)
      return
    brainLoaded = true
    scoreKeeper = new ScoreKeeper(robot)

  # sweet regex bro
  robot.hear ///
    # from beginning of line
    ^
    # the thing being upvoted, which is any number of words and spaces
    ([\s\w']*)
    # the increment/decrement operator ++ or --
    ([-+]{2}|—)
    # optional reason for the plusplus
    (?:\s+(?:for|because|cause|cuz)\s+(.+))?
    $ # end of line
  ///i, (msg) ->
    if not brainLoaded
      return

    # let's get our local vars in place
    [_, name, operator, reason] = msg.match
    from = msg.message.user.name.toLowerCase()
    room = msg.message.room

    # do some sanitizing
    reason = reason?.trim().toLowerCase()
    name = (name.replace /(^\s*@)|([,:\s]*$)/g, "").trim().toLowerCase() if name

    # check whether a name was specified. use MRU if not
    unless name?
      [name, lastReason] = scoreKeeper.last(room)
      reason = lastReason if !reason? && lastReason?

    # do the {up, down}vote, and figure out what the new score is
    [score, reasonScore] = if operator == "++"
              scoreKeeper.add(name, from, room, reason)
            else
              scoreKeeper.subtract(name, from, room, reason)

    # if we got a score, then display all the things and fire off events!
    if score?
      message = if reason?
                  "#{name} has #{score} points, #{reasonScore} of which are for #{reason}."
                else
                  "#{name} has #{score} points"

      msg.send message

      robot.emit "plus-one", {
        name: name
        direction: operator
        room: room
        reason: reason
      }

  robot.respond /score (for\s)?(.*)/i, (msg) ->
    if not brainLoaded
      return
    name = msg.match[2].trim().toLowerCase()
    score = scoreKeeper.scoreForUser(name)
    reasons = scoreKeeper.reasonsForUser(name)

    reasonString = if typeof reasons == 'object' && Object.keys(reasons).length > 0
                     "#{name} has #{score} points. here are some raisins:" +
                     _.reduce(reasons, (memo, val, key) ->
                       memo += "\n#{key}: #{val} points"
                     , "")
                   else
                     "#{name} has #{score} points."

    msg.send reasonString

  robot.respond /(top|bottom) (\d+)/i, (msg) ->
    if not brainLoaded
      return
    amount = parseInt(msg.match[2]) || 10
    message = []

    tops = scoreKeeper[msg.match[1]](amount)

    for i in [0..tops.length-1]
      message.push("#{i+1}. #{tops[i].name} : #{tops[i].score}")

    if(msg.match[1] == "top")
      graphSize = Math.min(tops.length, Math.min(amount, 20))
      message.splice(0, 0, clark(_.first(_.pluck(tops, "score"), graphSize)))

    msg.send message.join("\n")

  robot.router.get "/hubot/normalize-points", (req, res) ->
    if not brainLoaded
      return
    scoreKeeper.normalize((score) ->
      if score > 0
        score = score - Math.ceil(score / 10)
      else if score < 0
        score = score - Math.floor(score / 10)

      score
    )

    res.end JSON.stringify('done')

  robot.router.get "/hubot/scores", (req, res) ->
    if not brainLoaded
      return
    query = querystring.parse(req._parsedUrl.query)

    if query.name
      obj = {}
      obj[query.name] = scoreKeeper.scoreForUser(query.name)
      res.end JSON.stringify(obj)
    else
      direction = query.direction || "top"
      amount = query.limit || 10

      tops = scoreKeeper[direction](amount)

      res.end JSON.stringify(tops)