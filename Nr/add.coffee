_ = require 'lodash'
Nt = require '../Nt/noitech'
voiceProfiles = require '../voiceProfiles'
{zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require '../functionsOfConvenience'
write = require './write'
read = require './read'
fs = require 'fs'

gen = Nt.generate
eff = Nt.effect

one = (toAdd, addTo, addWhere) ->
  Nt.mix toAdd, addTo, addWhere

module.exports = 
  one: one

  these: (currentsToAdd) -> 
    piece = Nt.open currentsToAdd.title + '/piece.wav'
    pieceL = piece[0]
    pieceR = piece[1]

    performanceLength = 0
    momentsInTime = []
    beatLength = parseInt currentsToAdd.piece.beatLength
    for beat in currentsToAdd.piece.time.rate
      beatLength = (beatLength * parseFloat beat) // 1
      momentsInTime.push performanceLength
      performanceLength += beatLength

    currentsToAdd = read currentsToAdd

    for voice in currentsToAdd.piece.voices
      for beatIndex in [0..voice.score.length - 1] by 1
        if voice.score[beatIndex] isnt 'same'
          noteFileName = voice.name + zeroPadder(beatIndex, 10) + '.wav'
          noteFileName = currentsToAdd.title + '/' + noteFileName
          currentNote = write.one currentsToAdd, voice, beatIndex
          currentNote = Nt.open noteFileName

          currentNoteL = currentNote[0]
          currentNoteR = currentNote[1]

          pieceL = one currentNoteL, pieceL, momentsInTime[beatIndex]
          pieceR = one currentNoteR, pieceR, momentsInTime[beatIndex]

    [pieceL, pieceR]

