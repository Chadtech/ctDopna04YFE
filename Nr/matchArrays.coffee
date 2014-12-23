_ = require 'lodash'

module.exports = (arr1, arr2) ->
  _.reduce(
    _.map arr1, (value, key) ->
      value is arr2[key]
    (sum, equality) ->
      sum and equality
  )