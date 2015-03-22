fs    = require 'fs'
Dopna = require './jsonToDopna'
exec  = require('child_process').exec

module.exports = (data, next) ->

  projectName = data.name

  pathToJSON = projectName + '/' + projectName + '.json'
  fs.writeFileSync pathToJSON, data.project

  project = JSON.parse data.project

  fileName = projectName + '/' + projectName + '.dopna'

  Dopna project, fileName

  leftOutput  = projectName + '/' + projectName + '.L.wav'
  rightOutput = projectName + '/' + projectName + '.R.wav'

  bash = './dopnaToWav ' + fileName + ' ' + leftOutput + ' ' + rightOutput
  exec bash, (error, stdout) =>
    console.log stdout
    next?()