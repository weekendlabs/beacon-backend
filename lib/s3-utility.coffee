AWS = require 'aws-sdk'
fs = require 'fs'
path = require 'path'
R = require 'ramda'
P = require 'bluebird'

pushFile = (fileName) ->
  new P (resolve, reject) ->
    s3 = new AWS.S3()
    bucketName = "custombucket#{Math.floor(Math.random()*10000)}"
    createBucketParams =
      Bucket: bucketName
      ACL: 'public-read'
      CreateBucketConfiguration:
        LocationConstraint: 'us-west-2'

    s3.createBucket createBucketParams, (err,data) ->
      if(err)
        console.log("error in creating bucket"+err)
      else
        console.log(JSON.stringify(data))
        fileBuffer = fs.readFileSync(fileName)
        putObjectParams =
          ACL: 'public-read'
          Bucket: bucketName
          Key: R.last(fileName.split(path.sep))
          Body: fileBuffer
          ContentType: 'application/x-tar'
        s3.putObject putObjectParams, (err, res) ->
          if(err)
            console.log("error in creating bucket"+err)
          else
            console.log(JSON.stringify(res))
            resolve(bucketName)


module.exports =
  pushFile: pushFile
