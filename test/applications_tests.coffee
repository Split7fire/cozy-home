should = require('should')
client = require('./client')
app = require('../server')


email = "test@test.com"
password = "password"


## Helpers

responseTest = null
bodyTest = null

storeResponse = (error, response, body, done) ->
    responseTest = null
    bodyTest = null
    if error
        console.log error
        false.should.be.ok()
    else
        responseTest = response
        bodyTest = body
    done()

handleResponse = (error, response, body, done) ->
    if error
        console.log error
        false.should.be.ok()
    done()


# Initializers 

clearDb = (callback) ->

    destroyApplications = ->
        Application.destroyAll (error) ->
             if error
                 console.log error.stack
                 console.log "Cleaning Applications failed."
                 callback()
             else
                 console.log "All applications are removed."
                 callback()

    destroyUsers = ->
        User.destroyAll (error) ->
            if error
                 console.log error.stack
                 console.log "Cleaning Users failed."
                 callback()
            else
                 destroyApplications()
            
    destroyUsers()


initDb = (callback) ->

    createUser = ->
        bcrypt = require('bcrypt')
        salt = bcrypt.genSaltSync(10)
        hash = bcrypt.hashSync(password, salt)

        user = new User
            email: email
            owner: true
            password: hash
            activated: true

        user.save (error) ->
            callback(error)

    createApp = ->
        app = new Application
            name: "Noty plus"
            state: "installed"
            index: 0
            slug: "noty-plus"

        app.save (error) ->
            createUser()
            
    createApp()

before (done) ->
    clearDb ->
        initDb done

before (done) ->
    client.post "login", password: password, (error, response, body) ->
        done()

describe "GET api/applications/", ->

    describe "GET /api/applications Get all applications", ->
        it "When I send a request to retrieve all notes", (done) ->
            client.get "api/applications", (error, response, body) ->
                storeResponse error, response, body, done

        it "Then I got expected application in a list", ->
            responseTest.statusCode.should.equal 200
            should.exist bodyTest
            bodyTest = JSON.parse bodyTest
            should.exist bodyTest.rows
            bodyTest.rows.length.should.equal 1
            bodyTest.rows[0].name.should.equal "Noty plus"
