fs = require 'fs'

module.exports = (projectName, projectAsString) ->
  pathToJSON = projectName + '/' + projectName + '.json'
  fs.writeFileSync pathToJSON, projectAsString