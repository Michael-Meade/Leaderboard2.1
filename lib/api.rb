require "sqlite3"
require_relative 'leaderboard'
require_relative 'ssh'
require 'json'
class GetScoresApi
    def get_scores_api
        begin
            user_db = SQLite3::Database.new "users.db"
            lb = {}
            count = 0
            user_db.execute("select team_name, score from Users order by score desc").each do |row|
                if count.to_i <= 10
                    lb[count.to_i] = [row[0], row[1]]
                    count += 1
                end
            end
        return lb.to_json
        rescue => e
            Alerts.new(e, "\\lib\\api.rb - GetScoresApi.new.get_scores_api").check_status
        end
    end
end
class CronApi < SSH
    def get_cron_status
        ssh = SSH.new
        output = ssh.run_command("service cron status")
        p output
        if output.include?("active (running)")
            return {
                "status": true
            }.to_json
        else
            return {
                "status": false
            }.to_json
        end
    end
    def start_cron
        ssh = SSH.new
        output = ssh.run_command("service cron start")
    end
    def stop_cron
        ssh = SSH.new
        output = ssh.run_command("service cron stop")
    end
end