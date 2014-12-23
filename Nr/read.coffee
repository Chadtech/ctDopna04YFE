_ = require 'lodash'
Nt = require '../Nt/noitech'
voiceProfiles = require '../voiceProfiles'
{zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require '../functionsOfConvenience'

gen = Nt.generate
eff = Nt.effect

module.exports = (project) ->
  dimensionIndexDictionary = 
    dimensionToIndex project.dimensions

  # Convert tone dimension of each beat to frequency 
  project.piece.voices = 
    _.map project.piece.voices, (voice, voiceIndex) ->
      voice.score = 
        _.map voice.score, (beat, beatIndex) ->
          if beat?['tone']
            convertedTone = 
              scaleSystemToFrequencies project.piece.scale,
                project.piece.tonic
                beat['tone']
            beat['tone'] = convertedTone
          beat
      voice

  # Convert all dimension values to numbers
  project.piece.voices =
    _.map project.piece.voices, (voice, voiceIndex) ->
      voice.score =
        _.map voice.score, (beat, beatIndex) ->
          _.mapValues beat, (value) ->
            parseFloat value
      voice

  project