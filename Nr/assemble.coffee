_ = require 'lodash'
Nt = require '../Nt/noitech'
voiceProfiles = require '../voiceProfiles'
{zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require '../functionsOfConvenience'

gen = Nt.generate
eff = Nt.effect

module.exports = (project) ->
  voices = _.clone project.piece.voices, true
  for voice in voices
    voice.score = _.map voice.score, (beat, beatIndex) ->
      pathToFile = project.title + '/'
      pathToFile += voice.name + zeroPadder(beatIndex, 10) + '.wav'
      thisBeat = Nt.open pathToFile
      thisBeatL = thisBeat[0]
      thisBeatR = thisBeat[1]
      [thisBeatL, thisBeatR]

  performanceLength = 0
  momentsInTime = []
  beatLength = parseInt project.piece.beatLength
  for beat in project.piece.time.rate
    beatLength = (beatLength * parseFloat beat) // 1
    momentsInTime.push performanceLength
    performanceLength += beatLength

  DurationsOfEachVoicesLastNote = _.map voices, (voice) ->
    left = voice.score[voice.score.length - 1][0].length
    right = voice.score[voice.score.length - 1][1].length
    if left > right
      return left
    else
      return right

  longestLastNote = _.max DurationsOfEachVoicesLastNote

  performanceLength += longestLastNote

  performanceL = gen.silence sustain: performanceLength
  performanceR = gen.silence sustain: performanceLength

  for voice in voices
    voice.score = _.zip momentsInTime, voice.score

  for voice in voices
    console.log 'assembling ', voice.name
    for beat in voice.score
      if beat[1]?
        performanceL = Nt.mix beat[1][0], performanceL, beat[0]
        performanceR = Nt.mix beat[1][1], performanceR, beat[0]

  pathToPiece = project.title + '/' + 'piece.wav'

  Nt.buildFile pathToPiece, [performanceL, performanceR]
