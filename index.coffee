express = require 'express'
bodyParser = require 'body-parser'
mongoose = require 'mongoose'
cors = require 'cors'

app = express()
app.use bodyParser.json()
app.use cors()
socketIOClient = require('socket.io-client')('http://ec2-52-24-94-142.us-west-2.compute.amazonaws.com:10000')
socketIOClient.on 'connect', ->
  console.log("socket io client connected to server")

socketIOClient.on 'stats', (data) ->
  console.log(JSON.stringify(data))

appModel = require './dbmodels/app'

appRouter = express.Router()
require('./lib/app')(appRouter, appModel)

deployRouter = express.Router()
require('./lib/deploy')(deployRouter, appModel)

mongoose.connect 'mongodb://localhost/beacon', ->
  mongoose.connection.open 'once', ->
    app.use '/apps', appRouter
    app.use '/deploy', deployRouter
    app.listen 3000, -> console.log 'server started'

app.get('/first', (req, res) ->
  res.send("hello")
)
