require 'sinatra'
require 'json'
require_relative 'Users.rb'
require_relative 'Stocks_controller.rb'

get '/users/:email' do
	return_msg = {}
	if (params.key?("email") && params.key?("accessToken"))
		if (!validate_token(params['accessToken']))
	                return_msg[:status] = 'invalid access token'
	                return return_msg.to_json
	        end
		result = get_user(params['email'])
		if (result == nil)
			return_msg[:status] = 'invalid user'
		else
			return_msg[:status] = 'success'
			return_msg[:user] = result.to_s
		end
	else
		return_msg[:status] = 'required parameters - email, accessToken - not provided'
	end
	return_msg.to_json
end

post '/users' do
	return_msg = {}
	if (params.key?("name") && params.key?("email") && params.key?("password"))
		result = create_user(params)
		if (result.class == Hash)
	                return_msg[:user] = result
		else
			return_msg[:status] = result
		end
	else
		return_msg[:status] = 'required parameters - name, email, password - not provided'
	end
	return_msg.to_json
end

put '/users/:email' do
	return_msg = {}
	if (!params.key?("accessToken") || params['accessToken'] == '')
		return_msg[:status] = 'Access token is not provided'
		return return_msg.to_json
	end
	if (!validate_token(params['accessToken']))
		return_msg[:status] = 'invalid access token'
		return return_msg.to_json
	end
	if (params.key?("email"))
		result = update_user(params)
		if (result.class == Hash)
			return_msg[:user] = result
		else
			return_msg[:status] = result
		end
	else
		return_msg[:status] = 'required parameters - email - not provided'
	end
	return_msg.to_json
end

get '/stocks' do
	return_msg = {}
	if (!params.key?("accessToken") || params['accessToken'] == '')
                return_msg[:status] = 'Access token is not provided'
                return return_msg.to_json
        end
        if (!validate_token(params['accessToken']))
                return_msg[:status] = 'invalid access token'
                return return_msg.to_json
        end
	return_msg[:stocks] = get_stocks(params)
	return_msg.to_json
end

get '/stocks/:symbol' do
	return_msg = {}
	if (!params.key?("accessToken") || params['accessToken'] == '')
                return_msg[:status] = 'Access token is not provided'
                return return_msg.to_json
        end
        if (!validate_token(params['accessToken']))
                return_msg[:status] = 'invalid access token'
                return return_msg.to_json
        end
	results = get_individual_stock(params['symbol'])
	if (results.class == Hash)
		return_msg[:stocks] = results
	else
		return_msg[:status] = results
	end
	return_msg.to_json
end
