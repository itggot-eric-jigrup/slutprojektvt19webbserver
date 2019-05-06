require 'sinatra'
require 'slim'
require 'byebug'
require 'SQLite3'
require 'bcrypt'
require 'securerandom'
require_relative './model.rb'

enable :sessions

configure do
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
get('/') do

    slim(:index)
end

get('/login') do
    slim(:login)
end

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

get('/registrering') do
    slim(:registrering)
end

post('/registrering') do
    register = register_user(params)
    
    if register[:error] == false
        session[:id] = register[:data]
        redirect('/')
    else
        session[:error] = register[:message]
        redirect('/')
    end
end

get('/home') do
    products = get_products()
    slim(:home, locals:{
        products: products
    })
end

get('/create') do
    slim(:create)
end

post('/create') do
    skapa = skapa_produkt(params, session[:id])

    redirect('/home')
end

get('/profil') do
    slim(:profil)
end

post('/add_to_cart/:product_id') do
    add = add_cart(params, session[:id])
    redirect('/home')
end

get('/korg') do
    cart = get_cart(session[:id])
    slim(:korg, locals:{
        cart: cart
    })
end

post('/Cart/Remove/:product_id') do
    remove = remove(params, session[:id])
    redirect('/korg')
end