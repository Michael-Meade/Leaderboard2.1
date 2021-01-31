require_relative 'lib/leaderboard'
require 'sinatra'
require 'json'
require 'shotgun'
enable :logging
 set :bind, '127.0.0.1'
set :port, 80
#ruby server.rb -p $PORT -o $IP
logger = Logger.new("app.log")

configure do
    use Rack::CommonLogger, logger
end



post '/signup' do
    begin
        team_name = params[:t_name]
        real_name = params[:irn]
        # making sure team_name AND real_name is not empty
        if team_name.empty? || real_name.empty? || team_name.include?("/") || team_name.include?("\\")
            "Error: real_name or team_name already exists in the database.\n Dont use \ or /"
        else
           DB.new.user_signup(team_name, real_name)
           send_file "output/#{team_name}.txt", :filename => "#{team_name}.txt", :type => 'Application/octet-stream'        
        end
        # it wont redirect bc the send_file method ends it with a halt statment . which stops it from redirecting
        #redirect 'leaderboard'
    rescue => e
        Alerts.new(e, "/signup").check_status
    end
end


get '/' do
    # if signups are enabled redirect to the signup page
    # if signups are disabled redirect ot the leaderboard.
    read = JSON.parse(File.read("config.json"))["signup"]
    if read == "true"
        redirect 'signup'
    elsif read == "false"
        redirect "leaderboard"
    end
end
get '/signup' do
    # if its set to true it will redirect to signup
    # if it set to false it will redirect to lb
    if  Utils.signup_switch
        erb :'signup'
    else
        redirect 'leaderboard'
    end
    
end
get '/leaderboard' do
    # creates the leadboard page.
    @r = LeaderBoard.new.get_scores
    erb :'leaderboard'
end
# API STUFF
get '/api/clean_cron' do
    # removes crontabs
    begin
        if request.user_agent == Utils.sha1_api_key
            Utils.ssh("crontab -r")
        end
    rescue => e
        Alerts.new(e, "/api/clean_cron").check_status
    end
end
get '/api/deny_login/:team_name' do
    begin
        Utils.remove_user_ssh(params['team_name'])
    rescue => e
        Alerts.new(e, "/api/deny_login").check_status
    end
end
get '/api/cron_status' do
    begin
        if request.user_agent.to_s == Utils.sha1_api_key.to_s
            @json = CronApi.new.get_cron_status
        end
    rescue => e
        Alerts.new(e, "/api/cron_status").check_status
    end
@json
end
get '/api/cron_start' do 
    begin
        if request.user_agent.to_s == Utils.sha1_api_key.to_s
            @json = CronApi.new.start_cron
        end
    rescue
        Alerts.new(e, "/api/cron_start").check_status
    end
end
get '/api/troll_alias/:command' do
        Utils.troll_alias(params['command'])
end
get '/api/cron_stop'  do
    # stops cron
    begin
        if request.user_agent.to_s == Utils.sha1_api_key.to_s
            CronApi.new.stop_cron
        end
    rescue => e
        Alerts.new(e, "/api/cron_stop").check_status
    end
end
get '/api/lb' do 
    # get the lb for discord
    lb = GetScoresApi.new.get_scores_api
    lb
end
get '/api/enable_signup' do
    # This enables signup. This will cause the index page to be redirected
    # to the signup page.
    read = JSON.parse(File.read("config.json"))["signup"]
    if read == "false"
        read = JSON.parse(File.read("config.json"))
        read["signup"] = "true"
        File.open("config.json", "w") { |file| file.write(read.to_json) }
    end
end
get '/api/signup_status' do
      read = JSON.parse(File.read("config.json"))["signup"]
    "#{read}"
end
get  '/api/disable_signup' do
    # disables signup. This will cause the index page to be redirected
    # to leaderboard page.
    read = JSON.parse(File.read("config.json"))["signup"]
    if read == "true"
        read = JSON.parse(File.read("config.json"))
        # changes signup to disabled in the config file
        read["signup"] = "false"
        File.open("config.json", "w") { |file| file.write(read.to_json) }
    end
end

