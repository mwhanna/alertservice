require_relative 'Client.rb'
require 'unirest'
require 'uri'
require 'ostruct'

def refresh_access_token()
	refresh_token = "Q-KbsATGy9XnD32KQYnKhwA0YjlIzKIt0"

	login_url = "https://login.questrade.com/oauth2/token?grant_type=refresh_token&refresh_token=#{refresh_token}"

	response = Unirest.get login_url,
	headers:{
		"Authorization" => "Bearer " + access_token,
		"Accept" => "application/json"
	}
	access_token = response.body['access_token']
	api_server = response.body['api_server']
end

def get_individual_stock(id)
	login_url = "https://login.questrade.com/oauth2/token?grant_type=refresh_token&refresh_token=#{refresh_token}"

	response = Unirest.get login_url,
	headers:{
	"Authorization" => "Bearer gY0JeRT5jTmsh9Ld5t3ez3DUrxWGp1wXcF9jsnhtvOpIsoXsyi",
	"Accept" => "application/json"
	}
	if (response.body['status'] == 404)
		return "Recipe ID not found"
	end
	response.body
end

def get_stocks(netChangeLastMin)

	mode = flat
	streak = 0
	counterStreak = 0
	currentCentChange = 0
	lastFiveMinsChange = Array.new
	trendLevel = 0
	trendStatus = "FLAT"
	lastFiveAvg = 0

	#Starting from rate of change 0 and time 0
	#Time 0:05
	while timeOfDay < 4pmEAST do
		currentCentChange += netChangeLastMin
		lastFiveAvg = lastFiveMinsChange.inject(:+).to_f
		streak += 1

		case mode
			when flat
						if netChangeLastMin >= 0.01 && currentCentChange > 0
							mode = positive
							trendStatus = "RISING SLOWLY"
						elsif netChangeLastMin <= 0.01  && currentCentChange < 0
							mode = negative
							trendStatus = "FALLING SLOWLY"
						end
						break
			when positive
					if netChangeLastMin <= 0.01
						if (counterStreak > 2)
							mode = negative
							trendStatus = "TURNING DOWNWARD"
							counterStreak = 0
							streak = 0
						else
							counterStreak += 1
						end
					elsif netChangeLastMin >= 0.01
						trendStatus = get_trend_level(lastFiveAvg)
					end
					break
			when negative
					if netChangeLastMin >= 0.01
						if counterStreak > 2
							mode = positive
							trendStatus = "TURNING UPWARD"
							counterStreak = 0
							streak = 0
						else
							counterStreak += 1
						end
					elsif netChangeLastMin <= 0.01
						trendStatus = get_trend_level(lastFiveAvg)
					end
					break
			end

		lastVal = lastFiveMinsChange[0]
		lastFiveMinsChange[0] = netChangeLastMin
		i = 1
		while i < 4 do
			temp = lastFiveMinsChange[i]
			lastFiveMinsChange[i] = lastVal
			lastVal = temp
			i += 1
		end
	end
end

def get_trend_level(fiveMinAvg)
	case fiveMinAvg
		when 9..200 then return "EXPLODING"
		when 6..8 then return "RISING FAST"
		when 3..5 then return "RISING"
		when 1..2 then return "RISING SLOWLY"
		when -1..-2 then return "FALLING SLOWLY"
		when -3..-5 then return "FALLING"
		when -6..-8 then return "FALLING HARD"
		when -9..-200 then return "PLUMMETING"
		else return "FLAT"
	end
end
