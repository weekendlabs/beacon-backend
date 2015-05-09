AWS  = require 'aws-sdk'
P = require 'bluebird'

launchInstance = (minInstances, maxInstances) ->
  new P (resolve, reject) ->
    ec2 = new AWS.EC2()
    #creation of security group
    securityGroupName = "customsecuritygroup#{Math.floor(Math.random()*10000)}"
    securityGroupId = ''
    createSecurityGroupParams =
      Description: 'my custom security group'
      GroupName: securityGroupName

    ec2.createSecurityGroup createSecurityGroupParams, (err, data) ->
      if(err)
        console.log("error:"+err)
        res.send('error:'+err)
      else
        console.log("created security group -- "+JSON.stringify(data))
        securityGroupId = data.GroupId

        #adding rules to security group
        addRulesParams =
          CidrIp: '0.0.0.0/0'
          GroupId: securityGroupId
          GroupName: securityGroupName
          IpProtocol: '-1'
          FromPort: -1
          ToPort : -1

        ec2.authorizeSecurityGroupIngress addRulesParams, (err, data) ->
          if(err)
            console.log("error:"+err)
            return
          else
            console.log("added rules --"+JSON.stringify(data))
            securityGroupIdArray = []
            securityGroupIdArray.push(securityGroupId)

            #creating ec2 instance
            createInstanceParams =
              ImageId: 'ami-dbe2d2eb'
              InstanceType: 't2.micro'
              MinCount: minInstances
              MaxCount: maxInstances
              SecurityGroupIds: securityGroupIdArray
              KeyName: 'mynewkeypair'

            ec2.runInstances createInstanceParams, (err,data) ->
              if(err)
                console.log("error:"+err)
                return
              else
                instances = []
                console.log("Instances created --")
                console.log(JSON.stringify(data))

                data.Instances.forEach((instance) ->
                  console.log("Created Instance with id: "+ instance.InstanceId)
                  instances.push(instance.InstanceId)
                )

                waitForParams =
                  InstanceIds: instances

                ec2.waitFor 'instanceRunning', waitForParams, (err, data) ->
                  if(err)
                    console.log("error:"+err)
                    res.send('error:'+err)
                  else
                    console.log("data:"+JSON.stringify(data))
                    publicDnsName = data.Reservations[0].Instances[0].PublicDnsName + ":8080"
                    resolve(publicDnsName)


module.exports =
  launchInstance: launchInstance
