React  = require 'react'
_      = require 'lodash'
$      = require 'jquery'

{p, input, div} = React.DOM

WorkSpace = React.createClass
  getInitialState: ->
    project: @props.project

    dimensions: @props.project.dimensions
    score: @props.project.parts[0].score
    time:  @props.project.parts[0].time

    currentDimension: 0
    currentBar:       0
    currentPart:      0
    barLength:        8
    subLength:        4


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

    @setState score: @state.score


  removeNoteAt: (event) ->
    spotToRemoveFrom = event.target.getAttribute 'data-index'

    for voice in @state.score
      voice.splice spotToRemoveFrom, 1


  barHighLight: (beatIndex) ->
    barModulus = beatIndex % @state.barLength
    subModulus = beatIndex % @state.subLength
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
            value:     'build'
        
        div {className: 'column'},
          
          input
            className: 'submit'
            type:      'submit'
            value:     'save'

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

        div {className: 'column half'},

          p
            className: 'point'
            'bar is'

        div {className: 'column half'},

          input
            className: 'input half'

        div {className: 'column half'},
          
          p
            className: 'point'
            'sub is'

        div {className: 'column half'},

          input
            className: 'input half'



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
          div {className: 'column'},

            p
              className: 'point'
              noteIndex

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