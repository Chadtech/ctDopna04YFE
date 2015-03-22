fs    = require 'fs'
Dopna = require './jsonToDopna'
exec  = require('child_process').exec

module.exports = (data, next) ->

  projectName = data.name

  pathToJSON = projectName + '/' + projectName + '.json'
  fs.writeFileSync pathToJSON, data.project

  project = JSON.parse data.project

  fileName = projectName + '/' + projectName + '.dopna'

  # Write a dopna file to disk
  Dopna project, fileName

  leftOutput  = projectName + '/' + projectName + '.L.wav'
  rightOutput = projectName + '/' + projectName + '.R.wav'


  # Convert the dopna file to a wav file
  bash = './dopnaToWav ' + fileName + ' ' + leftOutput + ' ' + rightOutput
  exec bash, (error, stdout) =>
    console.log stdout
    next?()