require 'sqlite3'
team_name = "poop"
User_db = SQLite3::Database.new "users.db"
User_db.execute( "select team_name, irn from users where team_name='#{team_name}'" ) do |row|
    p row
end