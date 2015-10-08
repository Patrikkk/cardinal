# Configures the plugin
if process.env.NSFW_ROOMS_ALLOWED
  nsfw_allowed_rooms = process.env.NSFW_ROOMS_ALLOWED.split(',') 
  console.log(nsfw_allowed_rooms)
else
  nsfw_allowed_rooms = []

module.exports = (robot) ->
  # waits for the string "hubot nsfw" or "hubot hook me up" to occur
  robot.respond /nsfw/i, (msg) ->
    if not (msg.envelope.room in furry_allowed_rooms)
      msg.send("Furry is not allowed in this room.")
      return
    tags = msg.match[1]
    # Configures the url of a remote server
    msg.http('http://titsnarse.co.uk/random_json.php')
      # and makes an http get call
      .get() (error, response, body) ->
        # passes back the image source
        msg.send 'http://titsnarse.co.uk'+JSON.parse(body).src