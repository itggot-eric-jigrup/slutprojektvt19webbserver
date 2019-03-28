require 'sinatra'
require 'slim'
require 'byebug'
require 'SQLite3'
require 'bcrypt'

enable :sessions

    get('/') do
        slim(:index)
    end