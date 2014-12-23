_ = require 'lodash'
Nt = require '../Nt/noitech'
difference = require './getDifferences'
getRemainder = require './remainder'
voiceProfiles = require '../voiceProfiles'
{zeroPadder, scaleSystemToFrequencies, dimensionToIndex} = require '../functionsOfConvenience'

gen = Nt.generate
eff = Nt.effect

module.exports = (current, prior) ->
  priorTimesEqual = _.reduce(
    _.map prior.piece.time.rate, (time, timeIndex) ->
      time is current.piece.time.rate[timeIndex]
    (sum, equality) ->
      sum and equality
  )

  dontReconstructIf = [
    _.isEqual current.pages, prior.pages
    _.isEqual (_.map current.piece.voices, (voice) -> voice.attributes),
      (_.map prior.piece.voices, (voice) -> voice.attributes)
    priorTimesEqual
    _.isEqual current.piece.scale, prior.piece.scale
    _.isEqual current.piece.tonic, prior.piece.tonic
    _.isEqual current.piece.beatLength, prior.piece.beatLength
  ]

  reconstruct = not _.reduce dontReconstructIf, (sum, condition) ->
    sum and condition

  if reconstruct
    return msg: 'reconstruct'
  else
    differences = difference current, prior
    remainder = getRemainder current, prior
    reply =
      msg: 'differences'
      difference: differences
      remainder: remainder
    return reply


