fs = require 'fs'
Nt = require './Nt/build/release/NtCpp'
Dopna = require './jsonToDopna'

module.exports = (data) ->
  projectName = data.name

  pathToJSON = projectName + '/' + projectName + '.json'
  fs.writeFileSync pathToJSON, data.project

  project = JSON.parse data.project

  Dopna project

  Nt.dopna 'firs2.dopna'

  # start = Date.now()
  # Nt.saw 'DOPESAWDOPE.wav', 800, 8, 88200
  # end = Date.now()

  # console.log 'DUR : ', end - start