mongoose = require 'mongoose'

module.exports = (router, AppModel) ->

  router.get('/', (req, res) ->
    console.log 'getting apps...'
    AppModel.find (err, apps) ->
      if(err)
        console.log(err)
        res.status(500).end()
      console.log(apps)
      res.json(apps)
  )
