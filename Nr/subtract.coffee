_ = require 'lodash'
Nt = require '../Nt/noitech'
voiceProfiles = require '../voiceProfiles'
{zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require '../functionsOfConvenience'
fs = require 'fs'

gen = Nt.generate
eff = Nt.effect

one = (toRemove, removeFrom, removeWhere) ->
  noteNegative = eff.invert toRemove
  Nt.mix noteNegative, removeFrom, removeWhere

module.exports = 
  one: one

  these: (priorsToRemove) -> 
    piece = Nt.open priorsToRemove.title + '/piece.wav'
    pieceL = piece[0]
    pieceR = piece[1]

    performanceLength = 0
    momentsInTime = []
    beatLength = parseInt priorsToRemove.piece.beatLength
    for beat in priorsToRemove.piece.time.rate
      beatLength = (beatLength * parseFloat beat) // 1
      momentsInTime.push performanceLength
      performanceLength += beatLength

    for voice in priorsToRemove.piece.voices
      for beatIndex in [0..voice.score.length - 1] by 1
        if voice.score[beatIndex] isnt 'same'
          noteFileName = voice.name + zeroPadder(beatIndex, 10) + '.wav'
          noteFileName = priorsToRemove.title + '/' + noteFileName
          priorNote = 
            Nt.open noteFileName
          priorNoteL = priorNote[0]
          priorNoteR = priorNote[1]

          pieceL = one priorNoteL, pieceL, momentsInTime[beatIndex]
          pieceR = one priorNoteR, pieceR, momentsInTime[beatIndex]

    [pieceL, pieceR]