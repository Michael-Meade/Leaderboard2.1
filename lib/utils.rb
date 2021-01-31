require 'json'
require 'net/ssh'
require 'json'
require 'digest/sha1'
require 'open3'

class Utils
	def self.discord_config(value)
		read = JSON.parse(File.read("discord.json"))[value]
	end
	def self.read_confg(value)
		read = JSON.parse(File.read("config.json"))[value]
	end
	def self.signup_switch
		read = JSON.parse(File.read("config.json"))["signup"]
		return true if read == "true"
	end
	def self.commands(command)
		stdout, stderr, status = Open3.capture3(command).to_a
	end
	def self.sha1_api_key
		Digest::SHA1.hexdigest(JSON.parse(File.read("config.json"))["api-key"].to_s)
	end
	def self.remove_user_ssh(team_name)
		read = File.read("/etc/ssh/sshd_config")
		File.readlines("/etc/ssh/sshd_config").each do |line|
			if line.match("AllowUsers")
				@new_line = line.gsub(team_name, " ")
			end
		end
		changed = read.gsub(@new_line, @new_line.strip + " " + team_name.strip + "\n")
		f = File.open("/etc/ssh/sshd_config", "w")
		f.write(changed)
		f.close
	end
	def self.add_user_ssh(team_name)
		read = File.read("/etc/ssh/sshd_config")
		File.readlines("/etc/ssh/sshd_config").each do |line|
			if line.match("AllowUsers")
				 @new_line = "AllowUsers" + line.split("AllowUsers").join
			end
		end
		# adds the team_name to the AllowedUsers
		changed = read.gsub(@new_line, @new_line.strip + " " + team_name.strip + "\n")
		f = File.open("/etc/ssh/sshd_config", "w")
		f.write(changed)
		f.close
	end
	def self.troll_alias(command)
		Net::SSH.start(Utils.read_confg("ssh-ip").to_s, 'root', :password => Utils.read_confg("ssh-pass").to_s) do |ssh|
			# creates alias on the system.
			# Ex: command = /a='ls'
			ssh.exec!(%Q(echo "alias #{command}" >> .bashrc; source .bashrc))
		end
	end
	def self.cron_status
		Net::SSH.start(Utils.read_confg("ssh-ip").to_s, 'root', :password => Utils.read_confg("ssh-pass").to_s) do |ssh|
			# creates user and adds password. 
			output = ssh.exec!("service cron status")
			if !output.include?("cron is not running")
				return {
					"status": true
				}
			else
				return {
					"status": false
				}
			end
		end
	end
	def self.cron_stop
		Net::SSH.start(Utils.read_confg("ssh-ip").to_s, 'root', :password => Utils.read_confg("ssh-pass").to_s4e) do |ssh|
			# creates user and adds password. 
			output = ssh.exec!("sudo service cron stop")
		end
	end
	def self.ssh(command, arg=nil)
		# sshs into ctf server & runs commands
		# used to make game fair
		Net::SSH.start(Utils.read_confg("ssh-ip").to_s, 'root', :password => "") do |ssh|
			# creates user and adds password. 
			output = ssh.exec!(command)
			return output if !arg.nil?
		end
	end
end
