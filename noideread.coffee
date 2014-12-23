fs = require 'fs'
_ = require 'lodash'
Nt = require './Nt/noitech'
voiceProfiles = require './voiceProfiles'
{zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require './functionsOfConvenience'
{assemble, read, subtract, add, write, compare} = require './Nr'

gen = Nt.generate
eff = Nt.effect
speedOfSound = 0.0078

assembleAll = (project) ->
  console.log 'reading'
  project = read project
  console.log 'writing all'
  write.all project
  console.log 'assembling'
  assemble project

module.exports = 
  assembleAll: assembleAll

  handleLatest: (project) ->
    pathToPrior = project.title + '/' + project.title + '.json'
    prior = JSON.parse fs.readFileSync pathToPrior, 'utf8'

    assessment = compare project, prior

    if assessment.msg is 'reconstruct'
        console.log 'RECONSTRUCT'
        assembleAll project
        pieceLoaded = Nt.open project.title + '/piece.wav'
        pieceLoaded = _.map pieceLoaded, (channel) ->
          Nt.convertToFloat channel
        return pieceLoaded
    else
      noDifference = assessment.difference is null
      noRemainder = assessment.remainder is null
      if noRemainder and noDifference
        console.log 'IDENTICAL'
        pieceLoaded = Nt.open project.title + '/piece.wav'
        pieceLoaded = _.map pieceLoaded, (channel) ->
          Nt.convertToFloat channel
        return pieceLoaded
      else
        console.log 'NOT IDENTICAL'
        pathOfAltered = project.title + '/piece.wav'

        unless noDifference
          console.log 'PUSHING CHANGES'
          priorsToRemove = _.clone assessment.difference, true
          priorsToRemove.piece.voices = 
            _.map priorsToRemove.piece.voices, (voice, voiceIndex) ->
              voice.score = _.map voice.score, (beat, beatIndex) ->
                unless beat is 'same'
                  beat = beat.prior
                beat
              voice

          Nt.buildFile pathOfAltered, subtract.these priorsToRemove

          currentsToAdd = _.clone assessment.difference, true
          currentsToAdd.piece.voices = 
            _.map currentsToAdd.piece.voices, (voice, voiceIndex) ->
              voice.score = _.map voice.score, (beat, beatIndex) ->
                unless beat is 'same'
                  beat = beat.current
                beat
              voice

          Nt.buildFile pathOfAltered, add.these currentsToAdd

        unless noRemainder
          console.log 'ADDING REMAINDER'

          piece = Nt.open project.title + '/piece.wav'
          assembleAll assessment.remainder
          additions = Nt.open project.title + '/piece.wav'

          piece = _.map piece, (channel, channelIndex) =>
            channel = Nt.mix channel, additions[channelIndex]

          Nt.buildFile project.title + '/piece.wav', piece

        pieceLoaded = Nt.open project.title + '/piece.wav'
        pieceLoaded = _.map pieceLoaded, (channel) ->
          Nt.convertToFloat channel
        return pieceLoaded