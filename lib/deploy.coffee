fetchAndPackage = require './fetch-package'
AWS = require 'aws-sdk'
ec2Utility = require './ec2-utility'
s3Utility = require './s3-utility'
P = require 'bluebird'
request = require 'superagent'
R = require 'ramda'
path = require 'path'
K = require 'kefir'

#global variables
socketClientCreated = false
globalStream = null
individualStreams = []



module.exports = (router, appModel, io) ->
  router.post('/:id', (req, res) ->
    containerName = "node#{(new Date()).valueOf()}"
    #get the config from mongodb
    appId = req.params.id
    appModel.findOne({_id:appId}, (err, app) ->
      if(err)
        console.log(err)
        res.status(500).end()
      console.log(app)

      #get the github url from config and pull the code, do npm install and tar it
      appConfig = JSON.parse(app.config)
      console.log(appConfig)
      fetchAndPackage(appConfig.clusters[0].github.url,appConfig.clusters[0].github.token).then (archivePath) ->
        #launch aws instance
        #AWS.config.update({accessKeyId:'AKIAIAAZ7VPUJCPVXWFQ', secretAccessKey:'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', region:'us-west-2'})
        AWS.config.update({accessKeyId:appConfig.aws.accessKey, secretAccessKey:appConfig.aws.secretKey, region:'us-west-2'})
        #pushing tar file to s3
        bucket = ''
        fileName = R.last(archivePath.split(path.sep))
        s3Utility.pushFile(archivePath).then (bucketName) ->
          bucket = bucketName
        ec2Utility.launchInstance(1,1)
        .then (publicDnsName) ->
          console.log("ec2 instance launched")
          #creating socket io client for monitoring
          if(socketClientCreated == false)
            console.log("entered the socket client loop")
            socketIOClient = require('socket.io-client')("http://#{publicDnsName}")
            socketIOClient.on 'connect', ->
              console.log("socket io client connected to server")
            socketIOClient.on 'stat', (data) ->
              io.sockets.emit('stat', data)
            soketIOClient.on 'container-event', (data) ->
              io.sockets.emit('container-event', data)
            socketClientCreated = true
            console.log("exiting the socket client loop")
          #call to agent
          request
            .post(publicDnsName+"/containers/create")
            .send({"ImageName":appConfig.clusters[0].name, "BucketName":bucket, "FileName":fileName})
            .set('Content-Type','application/json')
            .end (err,res1) ->
              if(err)
                console.log("Error in call to agent:"+err)
                res.status(500).end()
              else
                console.log("success in creating container and container id:"+JSON.stringify(res))
                res.status(200).end()

        # .catch ->
        #   console.log("failed to launch ec2 instance")
    )
  )
