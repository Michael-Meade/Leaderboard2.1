require_relative 'lib/leaderboard'
require 'httparty'
begin
	response  = HTTParty.gets("http://IP/index.txt")
	team_name = response.parsed_response.to_s.strip
	if response.code.to_s == "403"
		# if cant access to scoring file
		# will send message in discord channel that
		# will alert admin of errors, if its enabled in the configs
		Alerts.new("403 error with scoring file.", "cron.rb").check_status
	else
		# everything goes right and the users get their pooints.
		DB.add_points(team_name)
	end
rescue => e
	# alert the asdmin that there was a error with scoring.
	# sends alert in discord channels
	Alerts.new(e, "cron.rb").check_status
end

