require 'open3'
require "colorize"
def self.run_command(command)
	# this method runs the command that is inputed
	begin
		stdout, stderr, status = Open3.capture3(command)
	rescue
		return false
	end
end
namespace :install do
	# This namespace is used to install all the packages and gems that is needed for
	# the Player server to work.
	desc "Installs apache2"
	task :apache2 do
		# checking to see if apache2 is installed.
		checking_apache = run_command("apache2 -v")
		puts "Checking to see if apache2 is installed..."  
		p checking_apache
		if checking_apache == false
			# apache2 needs to be installed
			puts "Apache2 is not installed, but we are installing it.".red
			puts "Updating the system..."
			run_command("sudo apt-get update")
			puts "Installing apache2..."
			run_command("sudo apt-get --assume-yes install apache2")
			# Making sure that apache2 is installed.
			check_again = run_command("apache2 -v")
			if check_again.to_s.include?("Server built:")
				puts "Apache2 is now installed!\n\n\n".green
			else
				puts "Apache2 is not installed.\n\n\n"
			end
		elsif checking_apache.join.include?("Server built:")
			puts "APACHE IS INSTALLED."
		end
	end
	desc "Install gems"
	task :gems do
		[ "net-ssh", "random_password",  ]
	end
end
namespace :Ip do
end
namespace :cron do
	desc "Runs the script that gives the users their points."
	task :run do
		sh "ruby crontab.rb"
	end
	desc "Create a cronjob that is used for scoring."
	task :install do
		# get the current directory..
		current_directory = File.expand_path File.dirname(__FILE__)
		stdout = run_command("crontab -l")
		dir_count = 0
		stdout.to_s.split.each do |l|
			# it assumes that there should only be
			# one crontab in the file with this directory inside it.
			# it will remove any others so there is only one
			# gets the amount of times that the directory is inside the crontab
			if l.include?(current_directory)
				dir_count += 1
			end
		end
		if dir_count.to_i !=  0
			puts "Please edit crontabs and remove any other crons that have the same directory".red
		else
			run_command("(crontab -l 2>/dev/null || true; echo '*/5 * * * * cd #{current_directory} && ruby crontab.rb')  | crontab -")
			puts "Installed the scoring cron job..."
		end               
	end
end



### Rake tasks for git commit and deploy
###
##use it if you want commit only -no pushing
desc "Task description"
task :commit, :message  do |t, args|
  message = args.message
  if message==nil
    message = "Source updated at #{Time.now}."
  end
  system "git add ."
  system "git commit -a -m \"#{message}\""
end


##it will push to remote repo after commititng if any change exists
##if no change for commit, no commit will happen
##use it always
desc "commit with stagging all changes"
task :deploy, :message do |t, args|
  
  Rake::Task[:commit].invoke(args.message) 
  puts "pushing to remote:"
  system "git remote -v"
  Rake::Task[:push].execute 

  
end

#push only
desc "push to remotes"
task :push do
  system "git push -u origin master"
end



# 

