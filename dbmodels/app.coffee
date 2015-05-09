mongoose = require 'mongoose'

AppSchema = mongoose.Schema({
  name: String,
  config: String
})

module.exports = mongoose.model('App', AppSchema)
