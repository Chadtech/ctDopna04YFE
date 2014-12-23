_ = require 'lodash'

module.exports = (current, prior) ->
  ###
  differences = _.clone current, true
  differences.piece.voices = 
    _.map differences.piece.voices, (voice, voiceIndex) ->
      voice.score = _.map voice.score, (beat, beatIndex) ->
        beat =
          current: beat
          prior: prior.piece.voices[voiceIndex].score[beatIndex]
        beat
      voice
  ###

  differences = _.clone prior, true
  differences.piece.voices =
    _.map differences.piece.voices, (voice, voiceIndex) ->
      voice.score = _.map voice.score, (beat, beatIndex) ->
        beat =
          current: current.piece.voices[voiceIndex].score[beatIndex]
          prior: beat
        beat
      voice


  differences.piece.voices = 
    _.map differences.piece.voices, (voice, voiceIndex) ->
      voice.score = _.map voice.score, (beat, beatIndex) ->
        if _.isEqual beat.current, beat.prior
          beat = 'same'
        beat
      voice

  for voice in differences.piece.voices
    for beat in voice.score
      if beat isnt 'same'
        return differences

  null