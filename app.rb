require 'sinatra'
require 'slim'
require 'byebug'
require 'SQLite3'
require 'bcrypt'

enable :sessions

    get('/') do

        slim(:index)
    end

    get('/login') do
        slim(:login)
    end

    post('/login') do
        username = login_user(params)  
        if username != false
            session[:username] = username
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
