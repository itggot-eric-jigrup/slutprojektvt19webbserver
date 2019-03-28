require 'sinatra'
require 'slim'
require 'byebug'
db = [
    {
        id: 1,
        name: "Olof Kallesson"
    },
    {
        id: 2,
        name: "Josef Josefsson"
    }
]


get('/contact') do
    personel = db # Read all personel from database
    # Send that data to a template
    # render template as HTML
    # return rendered HTML
    return slim(:contacts, locals:{#locals gör en ny variabel som kan anropas.
        people: personel,
        test: "omg"
    } 
    )
end

get('/about') do
    return slim :about
end

post('/send') do
    byebug
end