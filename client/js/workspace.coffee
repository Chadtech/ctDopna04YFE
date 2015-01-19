React  = require 'react'
_      = require 'lodash'
$      = require 'jquery'

{p, input, div} = React.DOM

WorkSpace = React.createClass
  getInitialState: ->
    project: @props.project

    currentDimension: 0
    currentBar:       0
    currentPart:      0
    barLength:        8
    subLength:        4


  changeCurrentDimension: (event) ->
    @setState currentDimension: event.target.getAttribute 'data-index'


  # addNoteAt: (event) ->
  #   @state.project.parts


  # removeNoteAt: (event) ->
    


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

        _.map @state.project.dimensions, (dimension, dimensionIndex) =>

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
            @state.project.dimensions[@state.currentDimension]

        _.map @state.project.ensemble, (voice, voiceIndex) =>

          div {className: 'column half'},

            p
              className: 'point'
              voice.name


      _.map @state.project.parts[@state.currentPart].score[0], (note, noteIndex) =>
        div {className: 'row'},
          div {className: 'column'},

            p
              className: 'point'
              noteIndex

          _.map @state.project.parts[@state.currentPart].score, (voice, voiceIndex) =>
            div {className: 'column half'},

              input
                className: 'input half'
                value:     voice[noteIndex][@state.currentDimension]

          div {className: 'column half'},

            input
              className:    'submit half'
              type:         'submit'
              value:        'v'
              'data-index': noteIndex
              onClick:      @addNoteAt

          div {className: 'column half'},

            input
              className:    'submit half'
              type:         'submit'
              value:        'x'
              'data-index': noteIndex
              onClick:      @removeNoteAt


module.exports = WorkSpace