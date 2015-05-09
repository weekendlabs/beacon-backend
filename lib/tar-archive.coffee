# Package in tar and return
P = require 'bluebird'
R = require 'ramda'
tar = require 'tar'
path = require 'path'
fstream = require 'fstream'
fs = require 'fs'

module.exports = (repoPath) ->
  new P (resolve, reject) ->
    # Get the path's last component to name the tar file
    archiveName = "#{R.last(repoPath.split(path.sep))}.tar"
    dirDest = fs.createWriteStream(archiveName)

    packer =
      tar.Pack(noProprietary: true)
      .on 'error', (err) -> console.log 'archiving error'
      .on 'end', ->
        console.log 'tar archiving completed...'
        resolve("#{process.cwd()}/#{archiveName}")

    fstream
      .Reader(path: repoPath, type: "Directory")
      .on 'error', -> console.log 'archiving stream read error'
      .pipe packer
      .pipe dirDest
