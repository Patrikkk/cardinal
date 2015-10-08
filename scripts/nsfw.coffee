# Configures the plugin
module.exports = (robot) ->
  # waits for the string "hubot nsfw" or "hubot hook me up" to occur
    robot.respond /nsfw/i, (msg) ->
      # Configures the url of a remote server
      msg.http('http://titsnarse.co.uk/random_json.php')
        # and makes an http get call
        .get() (error, response, body) ->
          # passes back the image source
          msg.send 'http://titsnarse.co.uk'+JSON.parse(body).src