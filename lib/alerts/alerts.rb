require 'json'
require 'discordrb'
require_relative '../utils'
class Alerts
	def initialize(error, type)
		@error = error
		@type  = type
	end
	def error
		@error
	end
	def type
		@type
	end
	def check_status
		# type is like cron, or the script that its beign used with
		# this makes sure that alerts is set to true
		if Utils.read_confg("alerts")
			# alerts is set in config
			bot = Discordrb::Commands::CommandBot.new token: Utils.discord_config("token").to_s, client_id: Utils.discord_config("channel_id").to_s , prefix: '.'
			bot.send_message("674737776092250133", "**#{type}**\n\n\n" + error.to_s)
		end
	end
end
