fs    = require 'fs'
Nt    = require './Nt/build/release/NtCpp'
Dopna = require './jsonToDopna'

module.exports = (data) ->

  projectName = data.name

  pathToJSON = projectName + '/' + projectName + '.json'
  fs.writeFileSync pathToJSON, data.project

  project = JSON.parse data.project

  fileName = projectName + '/' + projectName + '.dopna'

  Dopna project, fileName

  saveFileNameL = projectName + 'L/' + projectName + '.wav'
  saveFileNameR = projectName + 'R/' + projectName + '.wav'
  
  Nt.dopna fileName, saveFileNameL, saveFileNameR

