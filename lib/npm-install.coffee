# Do npm install and return
P = require 'bluebird'
{exec} = require 'child_process'

module.exports = (repoPath) ->
  console.log "running npm install in folder #{repoPath}"

  new P (resolve, reject) ->
    child = exec('npm install', {cwd: repoPath})

    child.on 'error', (err) ->
      console.log "npm install error: #{err}"

    child.on 'exit', (code) ->
      console.log "npm install exited with code: #{code}"
      resolve(repoPath)
