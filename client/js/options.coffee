React = require 'react'
_ = require 'lodash'

{div, input, p} = React.DOM

organizeTimeColumns = (time) ->
  _.zip time.samples, time.rate

expressRowIndex = (rowIndex, barLength, subLength, subModulus) =>
  rowIndexExpression = (rowIndex // barLength) + ''
  while rowIndexExpression.length < 5
    rowIndexExpression = '0' + rowIndexExpression
  rowIndexExpression += '.' + (rowIndex % barLength)
  rowIndexExpression

OptionsClass = React.createClass

  getInitialState: ->
    openFileName: ''
    insertAt: ''
    numberOfBars: ''
    fromBar: ''

  save: ->
    @props.save()

  open: ->
    @props.open @state.openFileName

  init: ->
    @props.init()

  numberOfBarsHandle: (event) ->
    @state.numberOfBars = event.target.value
    @setState numberOfBars: @state.numberOfBars

  fromBarHandle: (event) ->
    @state.fromBar = event.target.value
    @setState fromBar: @state.fromBar

  insertAtHandle: (event) ->
    @state.insertAt = event.target.value
    @setState insertAt: @state.insertAt

  copy: (event) ->
    @props.copy @state.insertAt, @state.numberOfBars, @state.fromBar

  openFileNameChangeHandle: (event) ->
    @state.openFileName = event.target.value
    @setState openFileName: @state.openFileName

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},
            'options'
            
      div {className: 'row'},
        div {className: 'column double'},
          input
            className:   'input double'
            value:       @state.openFileName
            onChange:    @openFileNameChangeHandle
            placeholder: '<piece name>'

        div {className: 'column'},
          input
            className: 'submit'
            type:      'submit'
            onClick:   @open
            value:     'open'

      div {className: 'row'},
        div {className: 'column'},
          input
            className: 'submit'
            type:      'submit'
            value:     'initialize'
            onClick:   @init

      div {className: 'row'},
        div {className: 'column'},
          input
            className: 'submit'
            type:      'submit'
            value:     'copy'
            onClick:   @copy

        div {className: 'column'},
          input
            className: 'input'
            placeholder: '<insert at>'
            value: @state.insertAt
            onChange: @insertAtHandle

        div {className: 'column'},
          input
            className: 'input'
            placeholder: '<# of bars>'
            value: @state.numberOfBars
            onChange: @numberOfBarsHandle

        div {className: 'column'},
          input
            className: 'input'
            placeholder: '<from bar>'
            value: @state.fromBar
            onChange: @fromBarHandle



Options = React.createFactory OptionsClass

module.exports = Options