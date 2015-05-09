express = require 'express'
bodyParser = require 'body-parser'
mongoose = require 'mongoose'
cors = require 'cors'

app = express()
app.use bodyParser.json()
app.use cors()

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
