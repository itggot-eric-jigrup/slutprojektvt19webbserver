def connect
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true
    return db
end

def login_user(params)
    username = params["name"]
    pswrd = params["password"]

    db = connect()
    
    password = db.execute("SELECT password FROM Users WHERE name = ?", username)
    password = password.first["password"]
    if BCrypt::Password.new(password) == pswrd
        return username
    else
        return false
    end
end

def register_user(params)
    name = params["name"]
    password = BCrypt::Password.create(params["password"])

    db = connect()
    
    result = db.execute("SELECT id FROM Users WHERE name = ?",name)
    if result.length > 0
        return {
            error: true,
            message: "User already exists"
        }
    end

    db.execute("INSERT INTO Users (name,password) VALUES (?,?)",name,password)
    result = db.execute("SELECT id FROM Users WHERE name = ?",name)

    return {
        error: false,
        data: result.first.first
    }
    
end