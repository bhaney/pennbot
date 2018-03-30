# Description:
#   Hubot script to show weather for some city
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_OWM_APIKEY: required, openweathermap API key
#   HUBOT_WEATHER_UNITS: optional, 'imperial' or 'metric'
#
# Commands:
#   hubot weather (in <city>) - Show today forecast for interested city. Defaults to Philadelphia.
#
# Author:
#   skibish

module.exports = (robot) ->
  robot.respond /weather(?: in (.*))?/i, (msg) ->
    APIKEY = process.env.HUBOT_OWM_APIKEY or null
    if APIKEY == null
      msg.send "HUBOT_OWM_APIKEY environment varibale is not provided for hubot-weather"
    units = {metric: "C", imperial: "F"}
    UNITS_ENV = process.env.HUBOT_WEATHER_UNITS
    unitsKey = if units[UNITS_ENV] then UNITS_ENV else "metric"
    location = msg.match[1] or= "Philadelphia"
    msg.http("http://api.openweathermap.org/data/2.5/weather?q=#{location}&units=#{unitsKey}&APPID=#{APIKEY}")
      .header('Accept', 'application/json')
      .get() (err, res, body) ->
        data = JSON.parse(body)
        if data.message
          msg.send "#{data.message}"
        else
          msg.send "Forecast for today in #{data.name}, #{data.sys.country}\n
                    Condition: #{data.weather[0].main}, #{data.weather[0].description}\n
                    Temperature: #{data.main.temp}°#{units[unitsKey]}\n
                    Temperature (low / high): #{data.main.temp_min}°#{units[unitsKey]} / #{data.main.temp_max}°#{units[unitsKey]}\n
                    Humidity: #{data.main.humidity}%\n\n
                    Last updated: #{new Date(data.dt * 1000)}"
