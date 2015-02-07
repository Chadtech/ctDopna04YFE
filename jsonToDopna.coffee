fs = require 'fs'
_  = require 'lodash'

module.exports = (dopnaAsJson, fileName) ->

  minimumZeros = (string, numberOfZeros) ->
    while string.length < numberOfZeros
      string = '0' + string
    string

  outputContent = []
  content = outputContent

  header = 'CtDopna0'
  header = _.map header, (char) ->
    char.charCodeAt()

  # content.push header

  for datum in header
    content.push datum

  content.push dopnaAsJson.scale.length
  # Convert each scale element into a string
  scale = _.map dopnaAsJson.scale, (interval) =>
    # All strings 8 characters long with zeros
    # filled in on the left side
    interval = minimumZeros interval + '', 8
    # Converted to hex
    _.map interval, (char) ->
      char.charCodeAt()
  # Converted to an array of hex values, from an array of arrays
  scale = _.reduce scale, (aggregate, interval) =>
    aggregate.concat interval

  # content.push scale

  console.log 'SCALE IS', scale

  for datum in scale
    content.push datum

  content.push dopnaAsJson.ensemble.length // 256
  content.push dopnaAsJson.ensemble.length

  console.log 'A.0.0'


  for voice in dopnaAsJson.ensemble
    type = minimumZeros voice.type, 4
    # content.push _.map (type.substring 0, 4), (char) ->
    #   char.charCodeAt()

    _.forEach (type.substring 0, 4), (char) ->
      content.push char.charCodeAt()

    xPos = parseInt voice.xPos
    yPos = parseInt voice.yPos

    if xPos < 0
      xPos = 32768 + Math.abs xPos
    if yPos < 0
      yPos = 32768 + Math.abs yPos

    content.push xPos // 256
    content.push xPos % 256
    content.push yPos // 256
    content.push yPos % 256

  console.log 'A.0.1'

  content.push dopnaAsJson.dimensions.length
  for dimension in dopnaAsJson.dimensions
    # content.push _.map (minimumZeros dimension, 12), (char) ->
    #   char.charCodeAt()

    _.forEach (minimumZeros dimension, 12), (char) ->
      content.push char.charCodeAt()

  # content.push _.map (minimumZeros dopnaAsJson.leftConvolvement, 12), (char) ->
  #   char.charCodeAt()
  # content.push _.map (minimumZeros dopnaAsJson.rightConvolvement, 12), (char) ->
  #   char.charCodeAt()

  _.forEach (minimumZeros dopnaAsJson.leftConvolvement, 12), (char) ->
    content.push char.charCodeAt()

  _.forEach (minimumZeros dopnaAsJson.rightConvolvement, 12), (char) ->
    content.push char.charCodeAt()

  # Needs to become dopnaAsJson.time.length as I change the json structure
  content.push (dopnaAsJson.parts[0].time.length // 256)
  content.push (dopnaAsJson.parts[0].time.length % 256)

  initialTime = parseInt dopnaAsJson.beatLength
  times = _.map dopnaAsJson.parts[0].time, (beat) =>
    initialTime *= parseFloat beat
    initialTime = initialTime // 1
    initialTime


  console.log 'A.0.2'

  # The push the duration of every beat
  for beat in times
    content.push beat // 256
    content.push beat % 256

  console.log 'A.0.3'

  # For every voice in the score
  for voice in dopnaAsJson.parts[0].score
    # The first note of the voice provides the initial default values
    # The default values are continuously updated as each note in the
    # score is iterated through
    defaultValues = _.clone voice[0], true

    for beat in voice
      exists = false

      for key in _.keys beat
        if beat[key] isnt ''
          defaultValues[key] = beat[key]
          exists = true

      if exists
        content.push 1
        for key in _.keys defaultValues
          if key is 'tone'
            toneInOctave  = parseInt defaultValues[key][defaultValues[key].length - 1]
            tone          = parseFloat dopnaAsJson.scale[ toneInOctave ]
            octaveOfTone  = parseInt (defaultValues[key].substring 0, defaultValues[key].length - 1)
            tonicAtOctave = (2 ** octaveOfTone) * defaultValues['tonic']
            frequency     = tone * tonicAtOctave
            thisDimension = _.map (minimumZeros frequency + '', 8), (char) ->
              char.charCodeAt()

            #content.push thisDimension

            for datum in thisDimension
              content.push datum

          else
            thisDimension = _.map (minimumZeros defaultValues[key], 8), (char) ->
              char.charCodeAt()

            #content.push thisDimension

            for datum in thisDimension
              content.push datum

      else
        content.push 0
        for key in _.keys defaultValues
          thisDimension = _.map (minimumZeros '', 8), (char) ->
            char.charCodeAt()

          #content.push thisDimension

          for datum in thisDimension
            content.push datum

  console.log 'A.0.4'

  # content = _.reduce content, (aggregate, chunk) =>
  #   aggregate.concat chunk

  console.log 'A.1'

  output = new Buffer(content)
  fs.writeFileSync fileName, output

