_ = require 'lodash'

module.exports = (dimensions) ->
  dimensions = _.map dimensions, (dimension) ->
    dimension
  theirIndex = _.map dimensions, (dimension, dimensionIndex) ->
    dimensionIndex
  
  _.zipObject dimensions, theirIndex