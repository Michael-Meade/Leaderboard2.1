require 'httparty'

a =HTTParty.get("http://127.0.0.1/api/cron_status", {
    "headers": { "User-Agent": "01aeaff0db7c95c38d866c1f9a1a212a19f8783a" }}).response.body
puts a