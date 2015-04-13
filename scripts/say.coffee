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
        robot.respond /say (.+) (.+)/i, (msg) ->
            robot.messageRoom msg.match[1], msg.match[2]