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

module.exports = (router, appModel) ->
  router.post('/:id', (req, res) ->
    containerName = "node#{(new Date()).valueOf()}"
    console.log("container Name:"+containerName)
    # request
    #   .post('ec2-52-24-94-142.us-west-2.compute.amazonaws.com:10000/containers/create')
    #   .send({"ImageName":'node', "BucketName":'custombucket1418', "FileName":'tmp1431023187887.tar',"ContainerName":containerName})
    #   .set('Content-Type','application/json')
    #   .end (err,res1) ->
    #     if(err)
    #       console.log("Error in call to agent:"+err)
    #     else
    #       console.log("success:"+JSON.stringify(res1))
    #       res.status(res1.status).end()

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
            socketIOClient = require('socket.io-client')("#{publicDnsName}")
            socketIOClient.on 'connect', ->
              console.log("socket io client connected to server")
            socketIOClient.on 'stats', (data) ->
              console.log(JSON.stringify(data))
              globalStream = (K.stream (emitter) ->
                emitter.emit(JSON.stringify(data))
              ) unless globalStream

            socketClientCreated = true
          #call to agent
          request
            .post(publicDnsName+"/containers/create")
            .send({"ImageName":appConfig.clusters[0].name, "BucketName":bucket, "FileName":fileName})
            .set('Content-Type','application/json')
            .end (err,res) ->
              if(err)
                console.log("Error in call to agent:"+err)
              else
                console.log("success in creating container and container id:"+JSON.stringify(res))
                individualStreams.push(globalStream.filter (stream) ->
                  stream.id == res.body.containerId
                )

        .catch ->
          console.log("failed to launch ec2 instance")
    )
  )
