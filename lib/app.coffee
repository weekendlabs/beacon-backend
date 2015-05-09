mongoose = require 'mongoose'

module.exports = (router, appModel) ->

  router.get('/', (req, res) ->
    console.log 'getting apps...'
    appModel.find (err, apps) ->
      if(err)
        console.log(err)
        res.status(500).end()
      console.log(apps)
      res.json(apps)
  )

  router.get('/:id', (req, res) ->
    console.log 'getting app with a particular id...'
    id = req.params.id
    appModel.find {_id:id}, (err, apps) ->
      if(err)
        console.log(err)
        res.status(500).end()
      console.log(apps)
      res.json(apps)
  )

  router.post('/', (req, res) ->
    console.log('creating a new app')
    name = req.body.name
    newApp = new appModel({name: name, config: ''})

    newApp.save (err, app) ->
      if(err)
        console.log "error in creating new app:#{err}"
        res.status(500).end()
      else
        console.log "created new app successfully"
        res.json(app)
  )

  router.put('/:id', (req, res) ->
    id = req.params.id
    config = JSON.stringify req.body.config
    appModel.update {_id:id}, {config:config}, null, (err, app) ->
      if(err)
        console.log "error in creating new app:#{err}"
        res.status(500).end()
      else
        console.log "created new app successfully"
        res.json(app)
  )
