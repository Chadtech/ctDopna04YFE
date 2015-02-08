React  = require 'react'
_      = require 'lodash'
$      = require 'jquery'

# DOM Elements
{p, div, input} = React.DOM

PORT = 1776

OpenPiece = React.createClass


  getInitialState: ->
    openName: ''


  changeOpenName: (event) ->
    @setState openName: event.target.value


  openProject: ->

    destinationURL = 'http://localhost:'
    destinationURL += PORT 
    destinationURL += '/api/open/'

    submission =
      projectName: @state.openName

    $.post destinationURL, submission
      .done (data) =>
        if data.message is 'worked'
          @props.updateState true, JSON.parse data.project
        console.log data.message


  render: ->
    div {className: 'column triple'},
      div {className: 'container'},
        div {className: 'row'},
          div {className: 'column'},
        
            input
              className:  'submit'
              type:       'submit'
              value:      'Open'
              onClick:    @openProject

          div {className: 'column oneAndHalf'},

            input
              className:   'input double'
              placeholder: '<name>'
              value:       @state.openName
              onChange:    @changeOpenName
              

module.exports = OpenPiece