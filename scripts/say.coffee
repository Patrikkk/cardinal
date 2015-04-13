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
	robot.read /say (.*) (.*)/i, (msg) ->
	room = msg.match[1].trim()
	message = msg.match[2].trim()
	robot.messageRoom room, message