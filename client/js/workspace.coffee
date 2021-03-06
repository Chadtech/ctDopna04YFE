React  = require 'react'
_      = require 'lodash'
$      = require 'jquery'


AudioContext = window.audioContext or window.webkitAudioContext
audioContext = new AudioContext


{p, input, div}     = React.DOM
PORT                = 1776
numberOfDisplayBars = 6


zeroPadder = (number, numberOfZerosToFill) ->
  numberAsString = number + ''
  while numberAsString.length < numberOfZerosToFill
    numberAsString = '0' + numberAsString
  numberAsString


formatNoteIndex = (noteIndex, barLength) ->
  if barLength isnt ''
    numberInBar = noteIndex % parseInt barLength
    numberOfBar = noteIndex // parseInt barLength
  else
    numberInBar = 'X'
    numberOfBar = 'X'

  formattedNoteIndex = '.' + numberInBar
  formattedNoteIndex = zeroPadder(numberOfBar, 5) + formattedNoteIndex
  formattedNoteIndex



WorkSpace = React.createClass


  getInitialState: ->
    project:    @props.project

    dimensions: @props.project.dimensions
    score:      @props.project.score
    time:       @props.project.time
    ensemble:   @props.project.ensemble

    currentDimension: 0
    currentBar:       0
    barLength:        '8'
    subLength:        '4'
    indicesOrTempi:   true
    beatsOrDurations: false
    copyFrom:         ''
    copyTo:           ''
    copyLength:       ''
    playFrom:         ''
    playTo:           ''

    serverCom: 'submit good'



  changeCurrentDimension: (event) ->
    @setState currentDimension: event.target.getAttribute 'data-index'


  addNoteAt: (event) ->
    spotToAddTo = event.target.getAttribute 'data-index'
    spotToAddTo++
    emptyNote = {}

    for dimension in @state.dimensions
      emptyNote[dimension] = ''

    for voice in @state.score
      voice.splice spotToAddTo, 0, _.clone emptyNote, true

    @state.time.splice spotToAddTo, 0, '1'

    @setState score: @state.score
    @setState time: @state.time


  removeNoteAt: (event) ->
    spotToRemoveFrom = event.target.getAttribute 'data-index'

    for voice in @state.score
      voice.splice spotToRemoveFrom, 1

    @state.time.splice spotToRemoveFrom, 1

    @setState score: @state.score
    @setState time: @state.time


  barHighLight: (beatIndex) ->
    barModulus = beatIndex % (parseInt @state.barLength)
    subModulus = barModulus % (parseInt @state.subLength)
    barModulusIsZero = barModulus is 0
    subModulusIsZero = subModulus is 0
    if barModulusIsZero or subModulusIsZero
      if barModulusIsZero
        ' verySpecial'
      else
        ' special'
    else
      ''


  sliceOfScore: ->
    @state.score[0].slice @state.currentBar * @state.barLength,
      (@state.currentBar + numberOfDisplayBars) * @state.barLength


  noteUpdate: (event) ->
    voiceIndex       = event.target.getAttribute 'data-voice'
    noteIndex        = event.target.getAttribute 'data-note'
    newValue         = event.target.value
    currentDimension = @state.dimensions[@state.currentDimension]

    @state.score[voiceIndex][noteIndex][currentDimension] = newValue
    @setState score: @state.score

  handleProjectName: (event) ->
    @state.project.name = event.target.value
    @setState project: @state.project

  changeBarLength: (event) ->
    @setState barLength: event.target.value


  changeSubLength: (event) ->
    @setState subLength: event.target.value


  indicesTempiSwap: ->
    @setState indicesOrTempi: not @state.indicesOrTempi

  beatsDurationsSwap: ->
    @setState beatsOrDurations: not @state.beatsOrDurations


  changeTime: (event) ->
    timeIndex = event.target.getAttribute 'data-index'
    @state.time[timeIndex] = event.target.value
    @setState time: @state.time


  productOfAllPriorTempi: (timeLimit) ->
    rate = 1
    timeIndex = 0
    while timeIndex <= timeLimit
      rate *= parseFloat @state.time[timeIndex]
      timeIndex++
    (rate + '').substring(0, 7)


  currentBarChange: (event) ->
    @setState currentBar: event.target.value


  copyFromChange: (event) ->
    @setState copyFrom: event.target.value


  copyToChange: (event) ->
    @setState copyTo: event.target.value


  copyLengthChange: (event) ->
    @setState copyLength: event.target.value


  playFromChange: (evnet) ->
    @setState playFrom: event.target.value


  playToChange: (event) ->
    @setState playTo: event.target.value

  copyBars: (event) ->
    from        = parseInt @state.copyFrom
    to          = parseInt @state.copyTo
    copyLength  = parseInt @state.copyLength

    for voiceIndex in [0.. @state.score.length - 1]
      copiedChunk = _.cloneDeep(@state.score[ voiceIndex ].slice from, from + copyLength)
      for noteIndex in [0.. copiedChunk.length - 1]
        @state.score[ voiceIndex ].splice (to + noteIndex), 0, copiedChunk[ noteIndex ]
      @setState score: @state.score

    for noteIndex in [0.. copiedChunk.length - 1]
      @state.time.splice (to + noteIndex), 0, @state.time[ from + noteIndex ]
    @setState time: @state.time


  addOneCurrentBar: ->
    @setState currentBar: (@state.currentBar + 1)


  subtractOneCurrentBar: ->
    if @state.currentBar isnt 0
      @setState currentBar: (@state.currentBar - 1)


  update: ->

    destinationURL = 'http://localhost:'
    destinationURL += PORT
    destinationURL += '/api/update/'

    submission = 
      projectName: @state.project.name
      project:     JSON.stringify @state.project, null, 2

    $.post destinationURL, submission
      .done (data) =>
        console.log data.message


  build: ->

    @setState serverCom: 'submit danger'

    destinationURL = 'http://localhost:'
    destinationURL += PORT
    destinationURL += '/api/build/'

    submission = 
      projectName: @state.project.name
      project:     JSON.stringify @state.project, null, 2

    $.post destinationURL, submission
      .done (data) =>
        console.log data.message
        if data.message is 'worked'
          @setState serverCom: 'submit good'


  play: ->

    @setState serverCom: 'submit danger'

    destinationURL = 'http://localhost:'
    destinationURL += PORT
    destinationURL += '/api/play/'

    beatTimeAtStartOfPiece = @state.project.beatLength
    if (parseInt @state.playFrom) > 0
      beatTimeAtStartOfPiece = _.reduce (@state.project.time.slice 0, (parseInt @state.playFrom)), (finalTempo, thisTempo) ->
        thisTempo   = parseInt thisTempo
        finalTempo  = parseInt finalTempo
        finalTempo * thisTempo
      beatTimeAtStartOfPiece *= parseInt project.beatLength
      beatTimeAtStartOfPiece = beatTimeAtStartOfPiece // 1
      beatTimeAtStartOfPiece += ''

    playPiece = _.cloneDeep @state.project
    playPiece.beatLength = beatTimeAtStartOfPiece
    playPiece.score = _.map playPiece.score, (voice) =>
      voice.slice @state.playFrom, @state.playTo

    playPiece.time = playPiece.time.slice @state.playFrom, @state.playTo

    submission = 
      projectName: @state.project.name + '_PIECE'
      project:     JSON.stringify playPiece, null, 2

    $.post destinationURL, submission
      .done (data) =>
        numberOfSamples = data.audioData[0].length
        audioBuffer     = audioContext.createBuffer 2, numberOfSamples, 44100

        for channel in ([0,1])
          audioBufferData = audioBuffer.getChannelData channel
          sampleIndex = 0
          while sampleIndex < numberOfSamples
            audioBufferData[ sampleIndex ] = data.audioData[ channel ][ sampleIndex ] / 32767
            sampleIndex++

        source        = audioContext.createBufferSource()
        source.buffer = audioBuffer
        
        source.connect audioContext.destination
        source.start()

        @setState serverCom: 'submit current', =>
          setTimeout =>
            @setState serverCom: 'submit good'
          , numberOfSamples // 44



  render: ->


    div null,


      # Options


      div className: 'row',
        div className: 'column',

          p
            className: 'point'
            'options'

        div className: 'column',

          input
            className: 'submit'
            type:      'submit'
            value:     'build'
            onClick:   @build

        div className: 'column',

          input
            className: @state.serverCom
            value:     ''

        div className: 'column',

          input
            className: 'input'
            value:     @state.project.name
            onChange:  @handleProjectName

      # Play

      div className: 'row',
        div className: 'column',

          input
            className: 'submit'
            type:      'submit'
            value:     'play'
            onClick:   @play


        div className: 'column half',

          p 
            className: 'point'
            'from'

        div className: 'column half',

          input
            className:    'input half'
            value:        @state.playFrom
            onChange:     @playFromChange

        div className: 'column half',

          p
            className: 'point'
            'to'

        div className: 'column half',

          input
            className: 'input half'
            value:     @state.playTo
            onChange:  @playToChange


      # Copy


      div className: 'row',
        div className: 'column',

          input
            className: 'submit'
            type:      'submit'
            value:     'copy'
            onClick:   @copyBars


        div className: 'column half',

          p 
            className: 'point'
            'from'

        div className: 'column half',

          input
            className:    'input half'
            value:        @state.copyFrom
            onChange:     @copyFromChange

        div className: 'column half',

          p
            className: 'point'
            'to'

        div className: 'column half',

          input
            className: 'input half'
            value:     @state.copyTo
            onChange:  @copyToChange

        div className: 'column half',

          p
            className: 'point'
            'of len'

        div className: 'column half',

          input
            className: 'input half'
            value:     @state.copyLength
            onChange:  @copyLengthChange


      # Display 


      div className: 'row',
        div className: 'column',

          p
            className: 'point'
            'display'


        div className: 'column half',

          p
            className: 'point'
            'bar is'

        div className: 'column half',

          input
            className: 'input half'
            value:     @state.barLength
            onChange:  @changeBarLength

        div className: 'column half',
          
          p
            className: 'point'
            'sub is'

        div className: 'column half',

          input
            className: 'input half'
            value:     @state.subLength
            onChange:  @changeSubLength

        div className: 'column',

          input
            className: 'submit'
            type:      'submit'
            value:     'bars/tempi'
            onClick:   @indicesTempiSwap

        div className: 'column',

          input
            className: 'submit'
            type:      'submit'
            value:     'times/beats'
            onClick:   @beatsDurationsSwap


      div className: 'row',
        div className: 'column'
        div className: 'column',

          p
            className: 'point'
            'display bar'

        div className: 'column half',

          input
            className: 'submit half'
            type:      'submit'
            value:     '<'
            onClick:   @subtractOneCurrentBar

        div className: 'column',

          input
            className: 'input'
            value:     @state.currentBar
            onChange:  @currentBarChange

        div className: 'column half',

          input
            className: 'submit half'
            type:      'submit'
            value:     '>'
            onClick:   @addOneCurrentBar


      # Dimensions


      div className: 'row',
        div className: 'column',

          p
            className: 'point'
            'dimensions'

        _.map @state.dimensions, (dimension, dimensionIndex) =>

          div className: 'column',

            input
              className:    'submit'
              type:         'submit'
              value:        dimension
              'data-index': dimensionIndex
              onClick:      @changeCurrentDimension


      div className: 'row',
        div className: 'column',
          
          p
            className: 'point'
            @state.dimensions[@state.currentDimension]

        _.map @state.ensemble, (voice, voiceIndex) =>
          div className: 'column half',

            p
              className: 'point'
              voice.name


      _.map  @sliceOfScore(), (note, noteIndex) =>
        noteIndex += (@state.barLength * @state.currentBar)

        div className: 'row',
          div className: 'column half',

            if @state.beatsOrDurations
              p 
                className: 'point'
                noteIndex

            else
              p
                className: 'point'
                @productOfAllPriorTempi noteIndex

          div className: 'column half',
            if @state.indicesOrTempi

              p
                className: 'point'
                formatNoteIndex noteIndex, @state.barLength

            else

              input
                className:    'input half'
                value:        @state.time[noteIndex]
                'data-index': noteIndex
                onChange:     @changeTime


          _.map @state.score, (voice, voiceIndex) =>
            div className: 'column half',

              input
                className:    'input half' + @barHighLight(noteIndex)
                value:        voice[noteIndex][@state.dimensions[@state.currentDimension]]
                'data-note':  noteIndex
                'data-voice': voiceIndex
                onChange:     @noteUpdate

          div className: 'column quarter',

            input
              className:    'submit quarter good'
              type:         'submit'
              value:        'v'
              'data-index': noteIndex
              onClick:      @addNoteAt

          div className: 'column quarter',

            input
              className:    'submit quarter danger'
              type:         'submit'
              value:        'x'
              'data-index': noteIndex
              onClick:      @removeNoteAt


module.exports = WorkSpace