React  = require 'react'
_      = require 'lodash'
$      = require 'jquery'

# Pages here
NewPiece  = require './new'
OpenPiece = require './open'
Title     = require './title'
WorkSpace = require './workspace'

# DOM Elements
{p, div, input} = React.DOM

IndexClass = React.createClass
  getInitialState: ->
    projectSet:  false
    project: null


  updateState: (newState, project) ->
    @setState project: project, ->
      @setState projectSet: newState


  render: ->
    div {},
      div {className: 'spacer'}
      div {className: 'indent'},
        div {className: 'container'},
          div {className: 'row'},

            Title()

          if @state.projectSet
            WorkSpace 
              project:     @state.project
              currentPart: 0

          else
            div {},
              div {className: 'row'},

                OpenPiece updateState: @updateState

              div {className: 'row'},

                NewPiece updateState: @updateState



      div {className: 'spacer'}

IndexPage = React.createFactory IndexClass

ctdopnayfeIndex = new IndexPage

element = document.getElementById 'content'
React.render ctdopnayfeIndex, element