AWS = require 'aws-sdk'


module.exports = (router, appModel) ->
  router.get '/', (req, res) ->
    res.send("deploy")
