React  = require 'react'
_      = require 'lodash'
$      = require 'jquery'

# DOM Elements
{p, div, input} = React.DOM

PORT = 1776

NewPiece = React.createClass
  getInitialState: ->
    name:          ''

    scale:         ['1.0', '1.125', '1.25', '1.33333', '1.5', '1.66667', '1.875']
    scaleState:    'xx'
    scaleClass:    'submit half'

    ensemble:      [{name: '', type: '', xPos: '', yPos: ''}]
    ensembleState: 'xx'
    ensembleClass: 'submit half'

    dimensions:    ['sustain', 'amplitude', 'tone', 'tonic']
    dimensionState:'xx'
    dimensionClass:'submit half'

    leftConvolvement:   ''
    rightConvolvement:  ''

    beatLength: ''


  changeScaleItem: (event) ->
    intervalIndex = event.getAttribute 'data-index'
    @state.scale[intervalIndex] = event.target.value
    @setState scale: @state.scale


  addScaleItem: ->
    @state.scale.push ''
    @setState scale: @state.scale


  destroyScale: ->
    if @state.scaleState is 'xx'
      @setState scaleState: 'x'
      @setState scaleClass: 'submit half critical'
    else
      @setState scaleState: 'xx'
      @setState scaleClass: 'submit half'
      @setState scale:      []


  changeVoiceName: (event) ->
    voiceIndex = event.target.getAttribute 'data-index'
    @state.ensemble[voiceIndex].name = event.target.value
    @setState ensemble: @state.ensemble


  changeVoiceType: (event) ->
    voiceIndex = event.target.getAttribute 'data-index'
    @state.ensemble[voiceIndex].type = event.target.value
    @setState ensemble: @state.ensemble


  changeVoiceXPos: (event) ->
    voiceIndex = event.target.getAttribute 'data-index'
    @state.ensemble[voiceIndex].xPos = event.target.value
    @setState ensemble: @state.ensemble


  changeVoiceYPos: (event) ->
    voiceIndex = event.target.getAttribute 'data-index'
    @state.ensemble[voiceIndex].yPos = event.target.value
    @setState ensemble: @state.ensemble


  addEnsembleItem: ->
    voiceTemplate =
      name: ''
      type: ''
      xPos: ''
      yPos: ''
    @state.ensemble.push voiceTemplate
    @setState ensemble: @state.ensemble


  destroyEnsemble: (event) ->
    if @state.ensembleState is 'xx'
      @setState ensembleState: 'x'
      @setState ensembleClass: 'submit half critical'
    else
      @setState ensembleState: 'xx'
      @setState ensembleClass: 'submit half'
      @setState ensemble:      []


  changeDimensionName: (event) ->
    dimensionIndex = event.target.getAttribute 'data-index'
    @state.dimensions[dimensionIndex] = event.target.value
    @setState dimensions: @state.dimensions


  addDimension: ->
    @state.dimensions.push ''
    @setState dimensions: @state.dimensions


  changeLeftConvolvement: (event) ->
    @setState leftConvolvement: event.target.value


  changeRightConvolvement: (event) ->
    @setState rightConvolvement: event.target.value


  changeName: (event) ->
    @setState name: event.target.value


  changeBeatLength: (event) ->
    @setState beatLength: event.target.value

  createNewProject: ->
    firstPart = 
      time: [1]
      score: _.map @state.ensemble, (voice) => 
        singleNote = {}
        for dimension in @state.dimensions
          singleNote[dimension] = ''
        [singleNote]

    project = 
      name:               @state.name
      scale:              @state.scale
      ensemble:           @state.ensemble
      dimensions:         @state.dimensions
      leftConvolvement:   @state.leftConvolvement
      rightConvolvement:  @state.rightConvolvement
      beatLength:         @state.beatLength
      parts:              [firstPart]

    destinationURL = 'http://localhost:'
    destinationURL += PORT
    destinationURL += '/api/create'

    projectJSON = JSON.stringify project, null, 2
    projectJSON = project: projectJSON
    $.post destinationURL, projectJSON
      .done (data) =>
        if data.message is 'worked'
          @props.updateState true, project
        console.log data.message

  render: ->
    div {className: 'column super'},
      div {className: 'container'},
        div {className: 'row'},
          div {className: 'column'},
        
            input
              className:  'submit'
              type:       'submit'
              value:      'New'
              onClick:    @createNewProject

          div {className: 'column oneAndHalf'},

            input
              className:    'input double'
              placeholder:  '<name>'
              value:        @state.name
              onChange:     @changeName

        div {className: 'row'},


          # Scale 
          

          div {className: 'column'},
            div {className: 'container'},
              
              div {className: 'row'},
                div {className: 'column half'},

                  p
                    className: 'point'
                    'scale'

              _.map @state.scale, (interval, intervalIndex) =>
                div {className: 'row'},
                  div {className: 'column quarter'},
                    p
                      className: 'point'
                      intervalIndex

                  div {className: 'column threeQuarters'},
                    input
                      className:   'input threeQuarters'
                      placeholder: '1.0'
                      value:        interval
                      'data-index': intervalIndex
                      onChange:     @changeScaleItem

              div {className: 'row'},
                div {className: 'column half'},
                  input
                    className: 'submit half'
                    type:      'submit'
                    value:     '+'
                    onClick:   @addScaleItem

                div {className: 'column half'},
                  input
                    className: @state.scaleClass
                    type:      'submit'
                    value:     @state.scaleState
                    onClick:   @destroyScale


          # Voices
          

          div {className: 'column double'},
            div {className: 'container'},
              
              div {className: 'row'},
                div {className: 'column double'},

                  p
                    className: 'point'
                    'ensemble'

              div {className :'row'},
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
                    'x pos'

                div {className: 'column half'},
                  
                  p
                    className: 'point'
                    'y pos'

              _.map @state.ensemble, (voice, voiceIndex) =>
                div {className: 'row'},
                  div {className: 'column half'},
                    input
                      className:    'input half'
                      value:        @state.ensemble[voiceIndex].name
                      'data-index': voiceIndex
                      onChange:     @changeVoiceName

                  div {className: 'column half'},
                    input
                      className:    'input half'
                      value:        @state.ensemble[voiceIndex].type
                      'data-index': voiceIndex
                      onChange:     @changeVoiceType

                  div {className: 'column half'},
                    input 
                      className:    'input half'
                      value:        @state.ensemble[voiceIndex].xPos
                      'data-index': voiceIndex
                      onChange:     @changeVoiceXPos

                  div {className: 'column half'},
                    input 
                      className:    'input half'
                      value:        @state.ensemble[voiceIndex].yPos
                      'data-index': voiceIndex
                      onChange:     @changeVoiceYPos

              div {className: 'row'},
                div {className: 'column half'},

                  input
                    className: 'submit half'
                    type:      'submit'
                    value:     '+'
                    onClick:   @addEnsembleItem

                div {className: 'column half'},

                  input
                    className: @state.ensembleClass
                    type:      'submit'
                    value:     @state.ensembleState
                    onClick:   @destroyEnsemble


          # Dimensions
          

          div {className: 'column'},
            div {className: 'container'},
              
              div {className: 'row'},
                div {className: 'column'},

                  p
                    className: 'point'
                    'dimensions'

              _.map @state.dimensions, (dimension, dimensionIndex) =>
                div {className: 'row'},
                  div {className: 'column'},

                    input
                      className:    'input'
                      value:        @state.dimensions[dimensionIndex]
                      'data-index': dimensionIndex
                      onChange:     @changeDimensionName

              div {className: 'row'},
                div {className: 'column half'},

                  input
                    className: 'submit half'
                    type:      'submit'
                    value:     '+'
                    onClick:   @addDimension

                div {className: 'column half'},

                  input
                    className: @state.dimensionClass
                    type:      'submit'
                    value:     @state.dimensionState
                    onClick:   @destroyDimensions


          # Convolvement
          

          div {className: 'column double'},
            div {className: 'container'},
              
              div {className: 'row'},
                div {className: 'column double'},

                  p
                    className: 'point'
                    'convolvement'

              div {className: 'row'},
                div {className: 'column double'},

                  input
                    className:    'input double'
                    placeholder:  '<left convolvement>'
                    value:        @state.leftConvolvement
                    onChange:    @changeLeftConvolvement

              div {className: 'row'},
                div {className: 'column double'},

                  input
                    className:    'input double'
                    placeholder:  '<right convolvement>'
                    value:        @state.rightConvolvement
                    onChange:     @changeRightConvolvement


            # Beat Length
            
                
            div {className: 'row'},
              div {className: 'column double'},

                p
                  className: 'point'
                  'beat length'

            div {className: 'row'},
              div {className: 'column double'},

                input
                  className:    'input double'
                  placeholder:  '<duration in samples>'
                  value:        @state.beatLength
                  onChange:    @changeBeatLength                  

module.exports = NewPiece