require_relative 'Client.rb'

def validate_token(accessToken)
	valid = false
	client = create_client()
	stmt = client.prepare("SELECT COUNT(id) as count FROM User WHERE accessToken = ?")
	results = stmt.execute(accessToken)
	if (results.first['count'] == 1)
		valid = true
	end
	valid
end

def get_user(email)
	user = nil
        # connect to the MySQL server
        client = create_client()
	stmt = client.prepare("SELECT * FROM User WHERE email = ?")
	results = stmt.execute(email)
	if (results.count == 1)
		user = results.first
	end
	user
end

def create_user(params)
	user = nil
	client = create_client()

	#check if email already exists
	count = client.prepare("SELECT COUNT(id) as count FROM User WHERE email = ?")
	count = count.execute(params['email'])
	if (count.first['count'] != 0)
		return "User already exists!"
	end

	stmt = client.prepare("INSERT INTO User (name, password, email, calPerDay, isActive, preferences, diet, accessToken) VALUES
				(?, ?, ?, ?, 1, ?, ?, ?)")
	calPerDay = (params['calPerDay'] == nil) ? 0 : params['calPerDay']
	preferences = (params['preferences'] == 'cheapest') ? 'cheapest' : 'lowcal'
	accessToken = (0...8).map { (65 + rand(26)).chr }.join
	results = stmt.execute(params['name'], params['password'], params['email'], calPerDay, preferences, params['diet'], accessToken)
	
	#retrieve inserted user
	id = client.query("SELECT last_insert_id()")
	id = id.first['last_insert_id()']
	results = client.query("SELECT * FROM User WHERE id = '#{id}'")
	results.first
end

def update_user(params)
	user = nil
	client = create_client()

	#check if email already exists
        count = client.prepare("SELECT COUNT(id) as count FROM User WHERE email = ?")
        count = count.execute(params['email'])
        if (count.first['count'] == 0)
                return "User does not exist!"
        end

	stmt = client.prepare("UPDATE User
				SET name = ?, password = ?, calPerDay = ?, preferences = ?, diet = ?
                        	WHERE email = ?")
        results = stmt.execute(params['name'], params['password'], params['calPerDay'], params['preferences'], params['diet'], params['email'])
        
	#retrieve updated user
        results = client.query("SELECT * FROM User WHERE email = '#{params['email']}'")
        results.first
end

def get_user_by_token(accessToken)
	client = create_client()
	stmt = client.prepare("SELECT * FROM User WHERE accessToken = ?")
	user = stmt.execute(accessToken)
	user.first
end
