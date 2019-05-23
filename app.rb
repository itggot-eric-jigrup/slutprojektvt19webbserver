require 'sinatra'
require 'slim'
require 'byebug'
require 'SQLite3'
require 'bcrypt'
require 'securerandom'
require_relative './model.rb'

enable :sessions

include MyModule #Wat dis?

configure do
    # Setts secure routs not able to just surf into
    #
    set :secure, ["/home", "/create", "/profil", "/korg"]
end

before do 
    if settings.secure.any? { |elem| request.path.start_with?(elem)}
        if session[:id]
        else
            redirect('/login')
        end
    end
end

helpers do
    def geterror
        error = session[:message]
        session[:error] = false
        return error
    end
end

# Display Landing Page
#
get('/') do
    slim(:index)
end

# Display a login form
#
get('/login') do
    slim(:login)
end

# Attempt login and updates session
#
# @param [String] name, The username
# @param [String] password, The password
#
# @see Model#login_user
post('/login') do
    result = login_user(params)
    name = params["name"]  
    if result[:error] == false
        session[:id] = result[:id]
        session[:name] = name
        redirect('/home')
    else 
        session[:error] = true
        session[:message] = result[:message] 
        redirect('/login')
    end
end

# Display a register form
#
get('/registrering') do
    slim(:registrering)
end

# Attempts register and updates session
#
# @param [String] name, The username
# @param [String] password, The password
#
# @see Model#register_user
post('/registrering') do
    register = register_user(params)
    
    if register[:error] == false
        session[:id] = register[:data]
        redirect('/')
    else
        session[:error] = register[:message]
        redirect('/registrering')
    end
end

# Display home product page with 5 products
#
# @see Model#get_products
get('/home') do
    products = get_products()
    slim(:home, locals:{
        products: products
    })
end

# Display create page
#
get('/create') do
    slim(:create)
end

# Attempts Create new product and redirect to home
#
# @param [String] titel, The title of the product
# @param [String] description, The description of the product
# @param [String] price, The product price numeric
# @param [File] img, The image file 
#
# @see Model#skapa_produkt
post('/create') do
    skapa = skapa_produkt(params, session[:id])
    if session[:error] = false
        redirect('/home')
    else
        session[:error] = true
        session[:error] = skapa[:message]
        redirect('/create')
    end
end

# Display profil page
#
get('/profil') do
    slim(:profil)
end

# Adds product to cart
#
# @param [String] :product_id, The ID of the product
#
# @see Model#add_cart
post('/add_to_cart/:product_id') do
    add = add_cart(params, session[:id])
    redirect('/home')
end

# Display korg
#
# @see Model#get_cart
get('/korg') do
    cart = get_cart(session[:id])
    slim(:korg, locals:{
        cart: cart
    })
end

# Removes product from cart and redirects to '/korg'
#
# @param [String] product_id, The products id
#
# @see Model#remove
post('/Cart/Remove/:product_id') do
    remove = remove(params, session[:id])
    redirect('/korg')
end