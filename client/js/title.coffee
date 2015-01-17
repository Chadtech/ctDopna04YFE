React  = require 'react'
_      = require 'lodash'
$      = require 'jquery'

# DOM Elements
{p, div, input} = React.DOM

Title = React.createClass
  render: ->
    div {className: 'column'},
      div {className: 'container'},
        div {className: 'row'},
          div {className: 'column'},

            p
              className: 'point'
              'CtDOPNA04YFE'

module.exports = Title