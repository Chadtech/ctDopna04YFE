React  = require 'react'
_      = require 'lodash'
$      = require 'jquery'

# DOM Elements
{p, div, input} = React.DOM

OpenPiece = React.createClass
  render: ->
    div {className: 'column triple'},
      div {className: 'container'},
        div {className: 'row'},
          div {className: 'column'},
        
            input
              className:  'submit'
              type:       'submit'
              value:      'Open'

        div {className: 'row'},

          div {className: 'column'},

            p
              className: 'point'
              'name'
          div {className: 'column'},

            input
              className: 'input'

module.exports = OpenPiece