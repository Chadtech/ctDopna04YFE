React = require 'react'
_ = require 'lodash'

{div, input, p} = React.DOM

PropertiesClass = React.createClass

  getInitialState: ->
    dimensionClasses = []
    for dimension in @props.dimensions
      dimensionClasses.push 'submit'

    initialStates =
      newDimensionsName: ''
      deleteScaleClass: 'submit half'
      deleteScaleValue: 'xx'
      dimensionClasses: dimensionClasses

    initialStates

  newDimensionsNameHandle: (event) ->
    newDimensionsName = event.target.value
    @setState newDimensionsName: newDimensionsName

  beatLengthChangeHandle: (event) ->
    newBeatLength = event.target.value
    @props.onBeatLengthChange newBeatLength

  scaleAdd: ->
    @props.onScaleAdd()

  scaleDestroy: ->
    if @state.deleteScaleValue is 'xx'
      @setState deleteScaleValue: 'x'
      @setState deleteScaleClass: 'submit half critical'
    else
      @props.onScaleDestroy()
      @setState deleteScaleValue: 'xx'
      @setState deleteScaleClass: 'submit half'

  noteChangeHandle: (event) ->
    stepIndex = parseInt event.target.getAttribute 'data-index'
    newStep = event.target.value
    @props.onStepChange stepIndex, newStep

  tonicChangeHandle: (event) ->
    newTonic = event.target.value
    @props.onTonicChange newTonic

  barLengthChangeHandle: (event) ->
    newBarLength = event.target.value
    @props.onBarLengthChange newBarLength

  subLengthChangeHandle: (event) ->
    newSubLength = event.target.value
    @props.onSubLengthChange newSubLength

  subModulusChangeHandle: (event) ->
    newSubModulus = event.target.value
    @props.onSubModulusChange newSubModulus

  destroyDimension: (event) ->
    dimensionIndex = event.target.getAttribute 'data-index'
    dimensionName = event.target.value
    if @state.dimensionClasses[dimensionIndex] is 'submit critical'
      @props.onDimensionDestroy dimensionName
      @state.dimensionClasses.splice dimensionIndex, 1
      @setState dimensionClasses: @state.dimensionClasses
    else
      @state.dimensionClasses[dimensionIndex] = 'submit critical'
      @setState dimensionClasses: @state.dimensionClasses

  dimensionAdd: ->
    @props.onDimensionAdd @state.newDimensionsName
    @setState newDimensionsName: ''
    @state.dimensionClasses.push 'submit'
    @setState dimensionClasses: @state.dimensionClasses

  rightConvolvementChange: (event) ->
    newRightConvolvement = event.target.value
    @props.onRightConvolveChange newRightConvolvement

  leftConvolvementChange: (event) ->
    newLeftConvolvement = event.target.value
    @props.onLeftConvolveChange newLeftConvolvement

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},

            'properties'

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},

            'beat length'

        div {className: 'column'},
          input
            className: 'input'
            value:     @props.beatLength
            onChange:  @beatLengthChangeHandle

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},

            'scale'

        _.map @props.scale, (step, stepIndex) =>
          div {className: 'column half'},
            input
              className:    'input half'
              onChange:     @noteChangeHandle
              value:        @props.scale[stepIndex]
              'data-index': stepIndex

        div {className: 'column half'},
          input
            className: 'submit half'
            type:      'submit'
            onClick:   @scaleAdd
            value:     '+'

        div {className: 'column half'},
          input
            className:  @state.deleteScaleClass
            type:       'submit'
            onClick:    @scaleDestroy
            value:      @state.deleteScaleValue

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},

            'remove'

        _.map @props.dimensions, (dimension, dimensionIndex) =>
          div {className: 'column'},
            input
              className:    @state.dimensionClasses[dimensionIndex]
              onClick:      @destroyDimension
              type:         'submit'
              value:        dimension
              'data-index': dimensionIndex

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},

            'add'

        div {className: 'column oneAndHalf'},
          input
            className:   'input oneAndHalf'
            onChange:    @newDimensionsNameHandle
            value:       @state.newDimensionsName
            placeholder: '<dimension name>'

        div {className: 'column half'},
          input
            className: 'submit half'
            type:      'submit'
            value:     '+'
            onClick:    @dimensionAdd

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},

            'tonic'

        div {className: 'column'},
          input
            className: 'input'
            onChange:  @tonicChangeHandle
            value:     @props.tonic

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},

            'bar length'

        div {className: 'column'},
          input
            className: 'input'
            onChange:  @barLengthChangeHandle
            value:     @props.barLength

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},

            'sub length'

        div {className: 'column'},
          input
            className: 'input'
            onChange:  @subLengthChangeHandle
            value:     @props.subLength

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},

            'sub modulus'

        div {className: 'column'},
          input
            className: 'input'
            onChange:  @subModulusChangeHandle
            value:     @props.subModulus

      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},

            'convolvement'

        div {className: 'column oneAndHalf'},
          input
            className: 'input oneAndHalf'
            placeholder: '<left channel name>'
            onChange:  @leftConvolvementChange
            value:     @props.leftConvolvementSeed

        div {className: 'column oneAndHalf'},
          input
            className: 'input oneAndHalf'
            placeholder: '<right channel name>'
            onChange:  @rightConvolvementChange
            value:     @props.rightConvolvementSeed

Properties = React.createFactory PropertiesClass

module.exports = Properties