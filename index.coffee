express = require 'express'
bodyParser = require 'body-parser'
mongoose = require 'mongoose'

app = express()
app.use bodyParser.json()

app.get('/first', (req, res) ->
  res.send("hello")
)

app.listen(3000, ->
  console.log "server started"
)
