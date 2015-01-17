React  = require 'react'
_      = require 'lodash'
$      = require 'jquery'

# Pages here
NewPiece  = require './new'
OpenPiece = require './open'
Title     = require './title'

# DOM Elements
{p, div, input} = React.DOM

IndexClass = React.createClass
  render: ->
    div {},
      div {className: 'spacer'}
      div {className: 'indent'},
        div {className: 'container'},
          div {className: 'row'},

            Title()
          
          div {className: 'row'},

            NewPiece()

            OpenPiece()

      div {className: 'spacer'}

IndexPage = React.createFactory IndexClass

ctdopnayfeIndex = new IndexPage

element = document.getElementById 'content'
React.render ctdopnayfeIndex, element