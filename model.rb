module MyModule
    # Connects all functions to database
    #
    def connect
        db = SQLite3::Database.new("db/users.db")
        db.results_as_hash = true
        return db
    end

    # Attempts to login a user
    #
    #@param [Hash] params form data
    #@option params [String] name The username
    #@option params [String] password The password
    #
    #@return [Hash]
    #   * :error [Boolean] if credentials do not match user
    #   * :message [String] the error message if error occured
    #   * :id [Integer] The ID of the user
    def login_user(params)
        username = params["name"]
        pswrd = params["password"]

        db = connect()
        val = validate_user(params)
        if val == true
            result = db.execute("SELECT id, password FROM Users WHERE name = ?", username).first
            
            password = result["password"]
            if BCrypt::Password.new(password) == pswrd
                return {
                    error: false,
                    id:result["id"]  
                }
            else
                return {
                    error: true,
                    message: "Wrong password"
                }
            end
        else 
            return {
                error: true,
                message: "no such user user"
            }
        end
    end

    # Checks user information
    #
    #@param [Hash] params form data
    #@option params [String] name The username
    #@option params [String] password The password
    #
    #@return [Boolean] whether the credentials match the user
    def validate_user(params)
        username = params["name"]
        db = connect()
        result = db.execute("SELECT name FROM Users WHERE name = ?",username)
        if result == []
            return false
        else
            return true
        end
    end

    # Attempts to create new user
    #
    #@param [Hash] params form data
    #@option params [String] name The username
    #@option params [String] password The password
    #
    #@return [Hash]
    #   * :error [Boolean] whether an error occured
    #   * :messsage [String] the error message if an error occured
    def register_user(params)
        val = validate_new_user(params)
        if val == true
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
        else
            return {
                error: true,
                message: "not enough letter in name or password"
            }
        end
    end

    # Checks user information
    #
    #@param [Hash] params form data
    #@option params [String] name The username
    #@option params [String] password The password
    #
    #@return [Boolean] if password or name length less than 1
    def validate_new_user(params)
        name = params["name"]
        pass = params["password"]
        if name.length > 1 && pass.length > 1
            return true
        else
            return false
        end
    end

    # Attempts to create a new product redirect '/create'
    #
    #@param [Hash] params and userid form data
    #@option params [String] titel The titel
    #@option params [String] description The description
    #@option params [String] price The price
    #@option params [File] img The image
    def skapa_produkt(params, userid)
        titel = params["titel"]
        description = params["description"]
        price = params["price"]
        image = params["img"]
        if image == nil
            return {
                error: true,
                message: "no img"
            }
        else
            type = image["type"].split("/")[-1]
            new_name = SecureRandom.uuid + "." + type
            db = connect()
            val = validate_create(params)
            if val == true
                FileUtils.cp(image["tempfile"].path, 'public/uploads/' + new_name)

                db.execute("INSERT INTO Product (titel,description,price,userid,img) VALUES (?,?,?,?,?)",titel,description,price,userid,new_name)
            else 
                return {
                    error: true,
                    message: "something empty"
                }
            end
        end
    end

    # Checks product information
    #
    #@param [Hash] params form data
    #@option params [String] titel The titel
    #@option params [String] description The description
    #@option params [String] price The price
    #@option params [File] img The image
    #
    #@return [Hash]
    #   * :error [Boolean] whether any params was empty
    def validate_create(params)
        if params.values.any? {|elem| elem.length < 1} == true
            return false
        else 
            return true
        end
    end

    # Fetches first 5 rows in product database
    #
    def get_products()
        db = connect()
        result = db.execute("SELECT id, titel, description, price, userid, img FROM Product LIMIT 5")
    end

    # Adds product selected to users cart database and uppdates amount if product previously had been added
    #
    def add_cart(params, userid)
        id = params["product_id"]
        db = connect()
        
        result = db.execute("SELECT * FROM ProduCart WHERE user_id = ? AND product_id = ?",userid, id)
        if result.length > 0
            db.execute("UPDATE ProduCart SET antal = antal + 1 WHERE user_id = ? AND product_id = ?",userid,id)
        else
            db.execute("INSERT INTO ProduCart (product_id,user_id,antal) VALUES (?,?,?)",id,userid, 1)
        end
    end

    # Creates visible cart personal to user by selecting product information and cart information
    #
    def get_cart(userid)
        db = connect()
        result = db.execute("SELECT Product.id, Product.titel, Product.description, Product.price, Product.userid, Product.img, ProduCart.antal, ProduCart.product_id FROM Product INNER JOIN ProduCart ON Product.id = ProduCart.product_id WHERE user_id =?",userid)
    end

    # Removes selected product from cart
    #
    def remove(params, userid)
        id = params["product_id"]
        db = connect()
        result = db.execute("DELETE FROM ProduCart WHERE product_id = ? AND user_id = ?",id,userid)
    end
end