React = require 'react'
_ = require 'lodash'

{div, input, p} = React.DOM

getRowsAndColumns = (voices, dimension) ->
  _.zip _.map voices, (voice, voiceIndex) ->
    _.map voice.score, (note) ->
      note?[dimension]

expressRowIndex = (rowIndex, barLength, subLength, subModulus) =>
  rowIndexExpression = (rowIndex // barLength) + ''
  while rowIndexExpression.length < 5
    rowIndexExpression = '0' + rowIndexExpression
  rowIndexExpression += '.' + (rowIndex % barLength)
  rowIndexExpression

unshiftNoteIndex = (rowsAndColumns, barLength, subLength) ->
  noteIndex = 0
  while noteIndex < rowsAndColumns.length
    rowsAndColumns[noteIndex].unshift noteIndex
    noteIndex++
  rowsAndColumns

DimensionClass = React.createClass
  getInitialState: ->
    removeValues = []
    removeClasses = []
    beatIndex = 0
    while beatIndex < @props.voices[0].score.length
      if (beatIndex % @props.barLength) is 0
        removeValues.push 'xx'
        removeClasses.push 'submit half'
      beatIndex++

    removeState =
      removeValues: removeValues
      removeClasses: removeClasses

    removeState

  noteChange: (event) ->
    voiceIndex = event.target.getAttribute 'data-voice'
    noteIndex = event.target.getAttribute 'data-note'
    value = event.target.value
    @props.onNoteChange voiceIndex, noteIndex, value, @props.dimensionKey

  appendBar: ->
    @props.onAppendBar()
    @state.removeValues.push 'xx'
    @state.removeClasses.push 'submit half'
    @setState removeValues: @state.removeValues
    @setState removeClasses: @state.removeClasses

  insertBar: (event) ->
    noteIndex = event.target.getAttribute 'data-note'
    @state.removeValues.splice noteIndex, 0, 'xx'
    @state.removeClasses.splice noteIndex, 0, 'submit half'
    @setState removeValues: @state.removeValues
    @setState removeClasses: @state.removeClasses
    @props.onInsertBar noteIndex

  removeBar: (event) ->
    noteIndex = event.target.getAttribute 'data-note'
    if @state.removeValues[noteIndex // @props.barLength] is 'xx'
      @state.removeValues[noteIndex // @props.barLength] = 'x'
      @state.removeClasses[noteIndex // @props.barLength] = 'submit half critical'
      @setState removeValues: @state.removeValues
      @setState removeClasses: @state.removeClasses
    else
      @state.removeValues.splice (noteIndex // @props.barLength), 1
      @state.removeClasses.splice (noteIndex // @props.barLength), 1
      @setState removeValues: @state.removeValues
      @setState removeClasses: @state.removeClasses
      @props.onRemoveBar (noteIndex - 1)

  displayBarChangeHandle: (event) ->
    newDisplayBar = event.target.value
    @props.onDisplayBarChange newDisplayBar

  addOneDisplayBar: (event) ->
    @props.onDisplayBarChange @props.displayBar + 1

  subtractOneDisplayBar: (event) ->
    if @props.displayBar > 0
      @props.onDisplayBarChange @props.displayBar - 1

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column'},
          p
            className: 'point'
            @props.pageName

        div {className: 'column half'},
          input
            className: 'submit half'
            onClick:   @subtractOneDisplayBar
            type:      'submit'
            value:     '<'

        div {className: 'column half'},
          input
            className: 'input half'
            onChange:  @displayBarChangeHandle
            value:     @props.displayBar

        div {className: 'column half'},
          input
            className: 'submit half'
            onClick:   @addOneDisplayBar
            type:      'submit'
            value:     '>'

      div {className: 'row'},
        div {className: 'column half'},
          p {className: 'point'},
            ''

        _.map (_.pluck @props.voices, 'name'), (name) ->
          div {className: 'column half'},
            p
              className: 'point'
              name

      _.map (getRowsAndColumns @props.voices, @props.dimensionKey), (row, rowIndex) =>
        afterFirstBarToDisplay = (@props.displayBar * @props.barLength) <= rowIndex
        beforeLastBarToDisplay = rowIndex < ((@props.displayBar + 6) * @props.barLength)
        if afterFirstBarToDisplay and beforeLastBarToDisplay
          inputClassName = 'input half'
          if (rowIndex % @props.barLength) is 0
            inputClassName += ' verySpecial'
          else 
            barLength = parseInt @props.barLength
            subLength = parseInt @props.subLength
            subModulus = parseInt @props.subModulus
            if (((rowIndex % barLength) + subModulus) % subLength) is 0
              inputClassName += ' special'
          div {className: 'row'},
            div {className: 'column half'},

              p
                className: 'point'
                expressRowIndex rowIndex, 
                  @props.barLength
                  @props.subLength
                  @props.subModulus
            
            _.map row, (cell, cellIndex) =>
              div {className: 'column half'},
                input
                  className:    inputClassName
                  onChange:     @noteChange
                  value:        cell ? ''
                  'data-voice': cellIndex
                  'data-note':  rowIndex

            if (rowIndex % @props.barLength) is 0
              div {className: 'column half'},
                input
                  className:   'submit half'
                  onClick:     @insertBar
                  type:        'submit'
                  value:       '+ bar'
                  'data-note': rowIndex

            if (rowIndex % @props.barLength) is 1
              div {className: 'column half'},
                input
                  className:   @state.removeClasses[rowIndex // @props.barLength]
                  onClick:     @removeBar
                  type:        'submit'
                  'data-note': rowIndex 
                  value:       @state.removeValues[rowIndex // @props.barLength]

      div {className: 'row'},
        div {className: 'column half'},
          input
            className: 'submit half'
            type:      'submit'
            value:     '+ bar'
            onClick:   @appendBar

Dimension = React.createFactory DimensionClass

module.exports = Dimension