express = require 'express'
bodyParser = require 'body-parser'
mongoose = require 'mongoose'
cors = require 'cors'


app = express()
app.use bodyParser.json()
app.use cors()

server = require('http').Server(app)
io = require('socket.io')(server)
publicDnsName = 'http://ec2-52-24-83-183.us-west-2.compute.amazonaws.com:11000'
socketIOClient = require('socket.io-client')(publicDnsName)
socketIOClient.on 'connect', ->
  console.log("socket io client connected to server")

socketIOClient.on 'stat', (data) ->
  console.log(JSON.stringify(data))
  io.sockets.emit('stat', data)
socketIOClient.on 'container-event', (data) ->
  console.log(JSON.stringify(data))
  io.sockets.emit('container-event', data)

appModel = require './dbmodels/app'

appRouter = express.Router()
require('./lib/app')(appRouter, appModel)

deployRouter = express.Router()
require('./lib/deploy')(deployRouter, appModel,io)

mongoose.connect 'mongodb://localhost/beacon', ->
  mongoose.connection.open 'once', ->
    app.use '/apps', appRouter
    app.use '/deploy', deployRouter
    server.listen 3000, -> console.log 'server started'

app.get('/first', (req, res) ->
  res.send("hello")
)
