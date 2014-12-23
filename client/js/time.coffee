React = require 'react'
_ = require 'lodash'

{div, input, p} = React.DOM

expressRowIndex = (rowIndex, barLength, subLength, subModulus) =>
  rowIndexExpression = (rowIndex // barLength) + ''
  while rowIndexExpression.length < 5
    rowIndexExpression = '0' + rowIndexExpression
  rowIndexExpression += '.' + (rowIndex % barLength)
  rowIndexExpression

productOfAllPriorRates = (thisRate, thisRateIndex, rates) ->
  output = 1
  while thisRateIndex >= 0
    output *= rates[thisRateIndex]
    thisRateIndex--
  output

TimeClass = React.createClass
  displayBarChangeHandle: (event) ->
    newDisplayBar = event.target.value
    @props.onDisplayBarChange newDisplayBar

  addOneDisplayBar: (event) ->
    @props.onDisplayBarChange @props.displayBar + 1

  subtractOneDisplayBar: (event) ->
    if @props.displayBar > 0
      @props.onDisplayBarChange @props.displayBar - 1

  tempoChangeHandle: (event) ->
    tempoIndex = event.target.getAttribute 'data-index'
    newValue = event.target.value
    @props.onTempoChange newValue, tempoIndex

  render: ->
    div {},
      div {className: 'row'},
        div {className: 'column'},
          p {className: 'point'},

            'time'

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
        div {className: 'column half'}

        div {className: 'column'},
          p
            className: 'point'

            'rel tempo'

        div {className: 'column'},
          p
            className: 'point'

            'abs tempo'

      _.map @props.time.rate, (rate, rateIndex) =>
        afterFirstBarToDisplay = (@props.displayBar * @props.barLength) <= rateIndex
        beforeLastBarToDisplay = rateIndex < ((@props.displayBar + 6) * @props.barLength)
        if afterFirstBarToDisplay and beforeLastBarToDisplay
          barLength = parseInt @props.barLength
          subLength = parseInt @props.subLength
          subModulus = parseInt @props.subModulus
          inputClassName = 'input'

          if (rateIndex % barLength) is 0
            inputClassName += ' verySpecial'
          else 
            if (((rateIndex % barLength) + subModulus) % subLength) is 0
              inputClassName += ' special'

          div {className: 'row'},
            div {className: 'column half'},
              p
                className: 'point'

                expressRowIndex rateIndex, 
                  barLength 
                  subLength 
                  subModulus

            div {className: 'column'},
              input
                className:    inputClassName
                onChange:     @tempoChangeHandle
                value:        rate
                'data-index': rateIndex

            div {className: 'column'},
              p
                className: 'point'
                ('' + productOfAllPriorRates rate, rateIndex, @props.time.rate).substring 0, 15

Time = React.createFactory TimeClass

module.exports = Time