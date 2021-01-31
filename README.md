# The Scoreboard Server

The purpose of the scoreboard server is to handle the creation of user accounts, display the leaderboard and rewards players points.

## Files
### cron.rb
  - Scrapes the playing server's index.html file and if the team name exists it will reward them 50 points. Ran by the cronjob minute.<br>
  
### Scoreboard.rb
  - The acutally web app thats purpose is to run scoreboard and allow users to sign up.
  - It's a good idea to use the <a href="https://www.digitalocean.com/community/tutorials/how-to-install-and-use-screen-on-an-ubuntu-cloud-server">screen command</a>. So that if something happens, the web server will always be up.<br>
  
  
### rakefile.rb
  - To install crontab, use ```rake cron:install```

### run_me.sh
  - run this file to install ruby and the other deps. 
  - this script will also run the bundler.rb file, in which will install the needed gems, create the database and create the cronjob that is used for scoring.
  
### config.json
  - the config file. This holds the api key and also the settings<br>
  - if the user wants to use the alert feature, edit the alert file in lib\alerts with your discord api key.
  - The api key job is to authentication the requests by the discord bot. It would be dangerous to allow anyone to use some of the api features like disable & enable signup, clear cron, and the other api methods. The bot uses a discord bot to control that setting. If the user wanted to they could use a discord bot that when a certain command is sent, it will request the method on the scoring server and do what ever the task funtion was. The api key should look like this: 0c76e5b4-dc74-4b75-9987-e91c529d3aae. The api key should be the same on the scoring server and locally stored where ever the discord bot is running. Before sending the request, the discord bot will read its locally stored config file and sha1 the value. On the Scoring server, before the request is executed the server reads the locally stored config file and sha1 the api key. The script then reads the useragent and if it matches with the api key that the sha1 hashed valued that the requst did then it will do the function. 
  
### Start the scoring.
- Add the following command to your crontab file. <br>
```*/1 * * * * /bin/bash -l -c 'cd /root/BlueVsBlue/test && ruby cron.rb'```


## Terms
### Player Server
  The player server is the environment where the players will compete. The only requirment for the player server is to have a web server that is accessable. The playing server must be accessable by password authentication, This is because a ruby gem is used to SSH into the player sever and add the users. The user needs to change the IP and password of this setting in the: 

### Scoring Server
  The scoring Server purpose is to host the signup, leaderboard and the cron job that gives the players their points
  
### Scoring file
   The scoring file is the file in which the cronjob stored on the  ```player server``` will read. This file should have the right permissions and be readable and editable by all users. The scoring file should also be accessable by the internet. This is th file that the player will enter their username in. The username has to be the exact same as the one they signed up, if it is not then they will not get any points.
