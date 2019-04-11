def connect
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true
    return db
end

def login_user(params)
    username = params["name"]
    pswrd = params["password"]

    db = connect()
    
    result = db.execute("SELECT id, password FROM Users WHERE name = ?", username).first
    #{"id" => 1, "password" = 23456768}
    password = result["password"]
    if BCrypt::Password.new(password) == pswrd
        return result["id"]
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

def skapa_produkt(params, userid)
    byebug
    titel = params["titel"]
    description = params["description"]
    price = params["price"]
    image = params["img"]
    new_name = SecureRandom.uuid + image[-4..-1]
    db = connect()
    FileUtils.cp(image["tempfile"].path, 'public/uploads/' + new_name)

    db.execute("INSERT INTO Product (titel,description,price,userid) VALUES (?,?,?,?,?)",titel,description,price,userid,new_name)
end