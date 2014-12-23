React = require 'react'
_ = require 'lodash'

{div, input, p} = React.DOM

types = ['sine', 'saw']

VoicesClass = React.createClass

  getInitialState: ->
    removeValues = []
    removeClasses = []

    for voice in @props.voices
      removeValues.push 'xx'
      removeClasses.push 'submit half'

    outputStates =
      removeValues: removeValues
      removeClasses: removeClasses

    return outputStates

  typeChangeHandle: (event) ->
    voiceIndex = parseInt event.target.getAttribute 'data-index'
    type = event.target.value
    @props.onVoiceTypeChange voiceIndex, type

  nameChangleHandle: (event) ->
    voiceIndex = parseInt event.target.getAttribute 'data-index'
    name = event.target.value
    @props.onVoiceNameChange voiceIndex, name

  seedChangeHandle: (event) ->
    voiceIndex = parseInt event.target.getAttribute 'data-index'
    seed = event.target.value
    @props.onVoiceSeedChange voiceIndex, seed

  xposChangeHandle: (event) ->
    voiceIndex = parseInt event.target.getAttribute 'data-index'
    xpos = event.target.value
    @props.onVoiceXposChange voiceIndex, xpos

  yposChangeHandle: (event) ->
    voiceIndex = parseInt event.target.getAttribute 'data-index'
    ypos = event.target.value
    @props.onVoiceYposChange voiceIndex, ypos

  seedAdd: (event) ->
    voiceIndex = parseInt event.target.getAttribute 'data-index'
    @props.onSeedAdd voiceIndex

  voiceAdd: ->
    @props.onVoiceAdd()
    @state.removeValues.push 'xx'
    @state.removeClasses.push 'submit half'

    @setState removeValues: @state.removeValues
    @setState removeClasses: @state.removeClasses

  voiceDestroy: ->
    voiceIndex = parseInt event.target.getAttribute 'data-index'
    if @state.removeValues[voiceIndex] is 'xx'
      @state.removeValues[voiceIndex] = 'x'
      @setState removeValues: @state.removeValues
      @state.removeClasses[voiceIndex] = 'submit half critical'
      @setState removeClasses: @state.removeClasses
    else
      @state.removeClasses.splice voiceIndex, 1
      @state.removeValues.splice voiceIndex, 1
      @props.onVoiceDestroy voiceIndex

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column half'},
          p {className: 'point'},

            'voices'

      div {className: 'row'},
        div {className: 'column half'},
          p
            className: 'point'

            'name'

        div {className: 'column half'},
          p
            className: 'point'

            'type'

        div {className: 'column half'},
          p
            className: 'point'

            'seed'

        div {className: 'column half'},
          p
            className: 'point'

            'x pos'

        div {className: 'column half'},
          p
            className: 'point'

            'y pos'

        div {className: 'column half'},
          p
            className: 'point'
            
            'remove'

      _.map @props.voices, (voice, voiceIndex) =>
        div {className: 'row'},
          div {className: 'column half'},
            input
              className:    'input half'
              spellCheck:   'false'
              value:        voice.name
              onChange:     @nameChangleHandle
              'data-index': voiceIndex

          div {className: 'column half'},
            input
              className:    'input half'
              spellCheck:   'false'
              value:        voice.attributes.type
              onChange:     @typeChangeHandle
              'data-index': voiceIndex

          div {className: 'column half'},
            if voice.attributes.seed?
              input
                className:    'input half'
                spellCheck:   'false'
                placeholder:  '<file>'
                value:        voice.attributes.seed
                onChange:     @seedChangeHandle
                'data-index': voiceIndex
            else
              input
                className:    'submit half'
                value:        '+'
                type:         'submit'
                onClick:      @seedAdd
                'data-index': voiceIndex

          div {className: 'column half'},
            input
              className:    'input half'
              value:        voice.attributes.xpos
              onChange:     @xposChangeHandle
              'data-index': voiceIndex

          div {className: 'column half'},
            input
              className:    'input half'
              value:        voice.attributes.ypos
              onChange:     @yposChangeHandle
              'data-index': voiceIndex

          div {className: 'column half'},
            input
              className:      @state.removeClasses[voiceIndex]
              type:           'submit'
              value:          @state.removeValues[voiceIndex]
              onClick:        @voiceDestroy
              'data-index':   voiceIndex


      div {className: 'row'},
        div {className: 'column half'},
          input
            className: 'submit half'
            type:      'submit'
            onClick:   @voiceAdd
            value:     '+'



Voices = React.createFactory VoicesClass

module.exports = Voices