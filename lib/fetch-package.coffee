P = require 'bluebird'
rimraf = require 'rimraf'

NodeGit = require('nodegit')
{clone} = NodeGit.Clone;

npmInstall = require './npm-install'
tarArchive = require './tar-archive'

module.exports = (url, token) ->
  options =
    remoteCallbacks:
      certificateCheck: -> 1
      credentials: -> NodeGit.Cred.userpassPlaintextNew(token, '')

  dirName = "tmp#{(new Date()).valueOf()}"
  repoPath = "#{process.cwd()}/#{dirName}"

  clone(url, dirName, options)
  .then (repo) ->
    console.log('clone complete')
    npmInstall(repoPath)
  .then (repoPath) ->
    console.log 'npm install done..'
    tarArchive(repoPath)
  .then (archivePath) ->
    console.log 'tar archiving done..'
    console.log archivePath
    new P (resolve, reject) ->
      rimraf(repoPath, -> resolve(archivePath))
  .catch (err) -> console.log(err)
