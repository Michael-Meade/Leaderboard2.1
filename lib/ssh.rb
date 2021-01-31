require 'json'
require 'net/ssh'
require_relative 'db'
require_relative 'leaderboard'
class SSH
    def initialize
        # :keys => json["ssh-file"]        
        json  = JSON.parse(File.read("config.json").to_s)
        @ssh  = Net::SSH.start(json["ssh-ip"], 'root', :keys => json["ssh-file"],  :password => json["ssh-pass"], :port => "22")
    end
    def ssh_login
        @ssh
    end
    def run_command(cmd)
        ssh_login.exec!(cmd)
    end
end

class Users
    def initialize(team_name, team_pass)
        @team_name = team_name
        @team_pass = team_pass 
        run!
    end
    def team_name
        @team_name
    end
    def team_pass
        @team_pass
    end
    def run!
        # this will create a group named 'moose' on the gameplay server
        # if it doesnt exist.
        check_group

        # now we gotta check to see if the username is valid on the gameplay server.
        # if the teamname is not a user on the gameplay server. it will return true.
        if check_teamname
            # Username does not exist, so we now have to set up the
            # user on the game server.
            add_user

        end
    end
    def add_user
        begin
            ssh = SSH.new
            # creates user and adds password. 
            ssh.run_command("useradd #{team_name} -g moose -p x ")
            ssh.run_command("cp -rv /root/.ssh/ /home/#{team_name}")
            ssh.run_command("chmod g-w /home/#{team_name}")
            ssh.run_command("chmod 700 /home/#{team_name}/.ssh")
            ssh.run_command("chmod 600 /home/#{team_name}/.ssh/authorized_keys")
            ssh.run_command("echo '#{team_name}:#{team_pass}' | chpasswd")
            ssh.run_command("sed -i '/^AllowUsers/ s/$/ '#{team_name}'/' /etc/ssh/sshd_config")
        rescue => e
            Alerts.check_status(e, "\\lib\\ssh.rb - Users.new(team_name, team_pass).add_user")
        end
    end
    def check_group
        # Check to see if the gameplay server, has a group named moose. 
        # Runs the command 'cat /etc/group | grep "moose"' to check.
        # If it returns nil or empty then it will create a new
        # group with the name 'moose'
        begin
            ssh = SSH.new
            group_create = ssh.run_command("cat /etc/group | grep 'moose'").strip
            if !(group_create.include?("moose"))
                ssh.run_command("groupadd moose")
            end
        rescue => e
            Alerts.check_status(e, "\\lib\\ssh.rb - Users.new(team_name, team_pass).check_group")
        end
    end
    def check_teamname
        # Will check to see if the user name exists on the gameplay server.
        # used after the scoreboard server checks to see if the user name is valid.
        # returns true if not a username already
        begin
            ssh = SSH.new
            tn_check = ssh.run_command("awk -F: '{ print $1}' /etc/passwd")
            if !tn_check.include?(team_name)
                return true
            end
        rescue => e
            Alerts.check_status(e, "\\lib\\ssh.rb - Users.new(team_name, team_pass).check_teamname")
        end
    end
end



#SSH.new.run_command("ls")