_ = require 'lodash'

module.exports = (current, prior) ->
  remainder = _.clone current, true
  remainder.piece.voices = 
    _.map remainder.piece.voices, (voice, voiceIndex) ->
      voice.score = _.map voice.score, (beat, beatIndex) ->
        if beatIndex < prior.piece.voices[voiceIndex].score.length
          return {}
        else
          return beat
      voice

  for voice in remainder.piece.voices
    for beat in voice.score
      if not _.isEqual beat, {}
        return remainder

  null