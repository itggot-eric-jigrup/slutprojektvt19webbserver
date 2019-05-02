require 'sinatra'
require 'slim'
require 'byebug'
require 'SQLite3'
require 'bcrypt'
require 'securerandom'
require_relative './model.rb'

enable :sessions

configure do
    set :secure, ["/home", "/create", "/profil"]
end

before do 
    if settings.secure.any? { |elem| request.path.start_with?(elem)}
        if session[:id]
        else
            redirect('/')
        end
    end
end

get('/') do

    slim(:index)
end

get('/login') do
    slim(:login)
end

post('/login') do
    id = login_user(params)
    name = params["name"]  
    if id != false
        session[:id] = id
        session[:name] = name
        redirect('/home')
    else 
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

get('/korg') do
    korg = get_korg()
    slim(:korg)
end

post('/add_to_cart/:product_id') do
    add = add_cart(params, session[:id])
    redirect('/home')
end
#post('/profil') do 