# Configures the plugin
if process.env.FURRY_ROOMS_ALLOWED
  nsfw_allowed_rooms = process.env.NSFW_ROOMS_ALLOWED.split(',') 
  console.log(nsfw_allowed_rooms)
else
  nsfw_allowed_rooms = []


# Configures the plugin
module.exports = (robot) ->
    robot.respond /hook me up|nsfw/i, (msg) ->
      if not (msg.envelope.room in nsfw_allowed_rooms)
        msg.send("NSFW is not allowed in this room.")
        return
      msg.http('http://titsnarse.co.uk/random_json.php')
        .get() (error, response, body) ->
          msg.send 'http://titsnarse.co.uk'+JSON.parse(body).src