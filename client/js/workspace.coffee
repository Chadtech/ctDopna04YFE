React  = require 'react'
_      = require 'lodash'
$      = require 'jquery'


{p, input, div} = React.DOM


PORT = 1776


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
    score:      @props.project.parts[0].score
    time:       @props.project.parts[0].time
    ensemble:   @props.project.ensemble

    currentDimension: 0
    currentBar:       0
    currentPart:      0
    barLength:        '8'
    subLength:        '4'
    indicesOrTempi:   true


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


  noteUpdate: (event) ->
    voiceIndex       = event.target.getAttribute 'data-voice'
    noteIndex        = event.target.getAttribute 'data-note'
    newValue         = event.target.value
    currentDimension = @state.dimensions[@state.currentDimension]

    @state.score[voiceIndex][noteIndex][currentDimension] = newValue
    @setState score: @state.score


  changeBarLength: (event) ->
    @setState barLength: event.target.value


  changeSubLength: (event) ->
    @setState subLength: event.target.value


  indicesTempiSwap: ->
    @setState indicesOrTempi: not @state.indicesOrTempi


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
    rate


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


  init: ->

    destinationURL = 'http://localhost:'
    destinationURL += PORT
    destinationURL += '/api/init/'

    submission = 
      projectName: @state.project.name
      project:     JSON.stringify @state.project, null, 2

    $.post destinationURL, submission
      .done (data) =>
        console.log data.message


  render: ->
    div {},


      # Options


      div {className: 'row'},
        div {className: 'column'},

          p
            className: 'point'
            'options'

        div {className: 'column'},

          input
            className: 'submit'
            type:      'submit'
            value:     'init'
            onClick:   @init
        
        div {className: 'column'},
          
          input
            className: 'submit'
            type:      'submit'
            value:     'update'
            onClick:   @update

        div {className: 'column'},
          
          input
            className: 'submit'
            type:      'submit'
            value:     'play'

      div {className: 'row'},
        div {className: 'column'}
        div {className: 'column half'},
          
          p
            className: 'point'
            'part'

        div {className: 'column half'},

          input
            className: 'input half'
            value:     @state.currentPart

        div {className: 'column half'},

          p
            className: 'point'
            'bar is'

        div {className: 'column half'},

          input
            className: 'input half'
            value:     @state.barLength
            onChange:  @changeBarLength

        div {className: 'column half'},
          
          p
            className: 'point'
            'sub is'

        div {className: 'column half'},

          input
            className: 'input half'
            value:     @state.subLength
            onChange:  @changeSubLength

        div {className: 'column'},

          input
            className: 'submit'
            type:      'submit'
            value:     'indices/tempi'
            onClick:   @indicesTempiSwap


      # Dimensions


      div {className: 'row'},
        div {className: 'column'},

          p
            className: 'point'
            'dimensions'

        _.map @state.dimensions, (dimension, dimensionIndex) =>

          div {className: 'column'},

            input
              className:    'submit'
              type:         'submit'
              value:        dimension
              'data-index': dimensionIndex
              onClick:      @changeCurrentDimension


      div {className: 'row'},
        div {className: 'column'},
          
          p
            className: 'point'
            @state.dimensions[@state.currentDimension]

        _.map @state.ensemble, (voice, voiceIndex) =>
          div {className: 'column half'},

            p
              className: 'point'
              voice.name


      _.map @state.score[0], (note, noteIndex) =>
        div {className: 'row'},
          div {className: 'column half'},

            p
              className: 'point'
              @productOfAllPriorTempi noteIndex

          div {className: 'column half'},
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
            div {className: 'column half'},

              input
                className:    'input half' + @barHighLight(noteIndex)
                value:        voice[noteIndex][@state.dimensions[@state.currentDimension]]
                'data-note':  noteIndex
                'data-voice': voiceIndex
                onChange:     @noteUpdate

          div {className: 'column quarter'},

            input
              className:    'submit quarter good'
              type:         'submit'
              value:        'v'
              'data-index': noteIndex
              onClick:      @addNoteAt

          div {className: 'column quarter'},

            input
              className:    'submit quarter danger'
              type:         'submit'
              value:        'x'
              'data-index': noteIndex
              onClick:      @removeNoteAt


module.exports = WorkSpace