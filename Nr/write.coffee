_ = require 'lodash'
Nt = require '../Nt/noitech'
voiceProfiles = require '../voiceProfiles'
{zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require '../functionsOfConvenience'

gen = Nt.generate
eff = Nt.effect

one = (project, voice, beatIndex) ->
  beat = voice.score[beatIndex]
  thisNote = _.clone voiceProfiles[voice.attributes.type].defaultValues
  if beat['tone']?
    for key in _.keys beat
      if beat[key]?
        thisNote[key] = beat[key]

    # Voice profile should be cloned
    # and have its default values modified
    # on a note to note basis.
    
    thisNote = voiceProfiles[voice.attributes.type].generate thisNote

    pathToLeft = project.piece.convolveSeedLeft + '.wav'
    pathToRight = project.piece.convolveSeedRight + '.wav'

    thisNoteL = eff.convolve thisNote, 
      factor: 0.1
      seed: Nt.convertToFloat (Nt.open pathToLeft)[0]

    thisNoteR = eff.convolve thisNote, 
      factor: 0.1
      seed: Nt.convertToFloat (Nt.open pathToRight)[0]

    thisNote = eff.giveSpatiality thisNote, 
      xpos: parseFloat voice.attributes.xpos
      ypos: parseFloat voice.attributes.ypos
    thisNoteL = thisNote[0]
    thisNoteR = thisNote[1]
    thisNoteL = Nt.convertTo64Bit thisNoteL
    thisNoteR = Nt.convertTo64Bit thisNoteR
  else
    thisNoteL = []
    thisNoteR = []
  noteFileName = voice.name + zeroPadder(beatIndex, 10) + '.wav'
  pathToThisNote = './' + project.title + '/' + noteFileName
  Nt.buildFile pathToThisNote, [thisNoteL, thisNoteR]

module.exports =
  one: one

  all: (project) ->
    for voice in project.piece.voices
      for beatIndex in [0..(voice.score.length - 1)] by 1
        one project, voice, beatIndex