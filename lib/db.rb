require "sqlite3"
require 'random_password'
require_relative 'leaderboard'
require 'net/ssh'
require 'json'
class DB
	def user_signup(team_name, irn)
		user_db = SQLite3::Database.new "users.db"
		# this method should house ALL the things used when the user signs up
		c = Check.new(team_name)
        p c.check_username
		# checks if check is set as true
		if c.check_username.nil?
                u = DBUsers.new(team_name, irn)
                # creates password & saves into db
                u.add_to_db
                user_db.execute( "select * from users where team_name='#{team_name}'" ) do |row|
                    @team_pass = row[3]
                end
                # logs into the game server and creates an the account on the machine
                Users.new(team_name, @team_pass).run!
                # Now we have to create the output 
                # file. This is sent to the end user at the very end.
                # The file has their team_name and thier randomly assigned password,
                # It does not have the IP of the gameplay server. You have to give it to the users
                # yourself. This is done to limit the exposure of the gameplay server. 
                u.create_ouput
        else
            return false
		end	
	end
end
class Check < DB
	User_db = SQLite3::Database.new "users.db"
	def initialize(team_name)
		@team_name = team_name
	end
	def User_db
		@user_db
	end
	def team_name
		@team_name
	end
	def check_username
		begin
			User_db.execute("select team_name, irn from users where team_name='#{team_name}'" ) do |row|
			# row[0] => team_name
                if row.to_a.nil?
                    puts "t"
                    # does not exist
                    return true
                else
                    # does exist
                    return false
    	        end
            end
	    rescue => e
	        Alerts.new(e, "\\lib\\db.rb - check_username(team_name)").check_status
	    end
	end     
end
class Points < DB
	def initialize(team_name)
		@team_name = team_name
	end
	def team_name
		@team_name
	end
	def add_points
		# if the user finds a correct flag.
        # this method will give the team their points
        user_db = SQLite3::Database.new "users.db"
        begin
            check = Check.new(team_name).check_username
            # checking to make sure the team name exists
            if check.to_s == false.to_s
                # it does exist.
                user_db.execute("UPDATE Users SET score = score + 50 WHERE team_name = '#{team_name.strip}'")
                # updated users score.
                user_db.close
            end
        rescue => e
            Alerts.new(e, "\\lib\\db.rb - Points.new(team_name)").check_status
        end
    end
end
class DBUsers < DB
	def initialize(team_name, irn)
		@team_name = team_name
		@irn = irn
	end
	def irn
		@irn
	end
	def team_name
		@team_name
	end
	def add_to_db
		# checks to make sure the name doesnt exist. If it returns nil 
        # then we know that it doesnt exist.
        # everyone starts with a score of 0
        begin
        	user_db = SQLite3::Database.new "users.db"
            random_password = RandomPassword.new(length: 10, digits: 4, symbols: 4)
            pass = random_password.generate
            user_db.execute("INSERT INTO Users (team_name, irn, score, password) 
            VALUES (?, ?, ?, ?)", [team_name, irn, "0", pass])
        rescue => e
            Alerts.new(e, "\\lib\\db.rb - DBUsers.new(team_name, irn).add_to_db").check_status
            return false
        end
	end
	def create_ouput
		# create an file that the user downloads
        # file contains account information ( to login, etc )
        begin
        	user_db = SQLite3::Database.new "users.db"
            f = File.open("output/#{team_name}.txt", "w")
            user_db.execute( "select * from users where team_name='#{team_name}'" ) do |row|
                f.write("Team Name: #{row[0]}\n IRN: #{row[1]}\n pass: #{row[3]}")
            end
            f.close
        rescue => e
            Alerts.new(e, "\\lib\\db.rb - DBUsers.new(team_name, irn).create_ouput").check_status
        end
	end
end
class LeaderBoard
    def get_scores
        begin
            user_db = SQLite3::Database.new "users.db"
            # create a hash of all the rows and scores.
            user_db.execute("select team_name, score from Users order by score desc")
        rescue => e
            Alerts.new(e, "\\lib\\db.rb - LeaderBoard.new.get_scores").check_status
        end
    end
end