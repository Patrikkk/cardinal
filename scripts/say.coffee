 	# Description:
	# Make the bot talk
	#
	# Dependencies:
	# None
	#
	# Configuration:
	# None
	#
	# Commands:
	# say <room> <message>
	#
	# Author:
	# Patrikk
	
module.exports = (robot) ->
    robot.respond /ping$/i, (msg) ->
        msg.send "ping"