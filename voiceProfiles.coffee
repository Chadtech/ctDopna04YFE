Nt = require './Nt/noitech'
gen = Nt.generate
eff = Nt.effect

module.exports = 
  sine:
    defaultValues:
      amplitude: 0.5
      sustain: 22050
      tone: 404

    generate: (note) ->
      expression = @defaultValues

      if note isnt undefined
        for key in Object.keys(note)
          if note[key] isnt undefined
            expression[key] = note[key]

      output = gen.sine expression
      output = eff.ramp output
      output

  saw:
    defaultValues:
      amplitude: 0.5
      sustain: 22050
      tone: 404
      harmonicCount: 8

    generate: (note) ->
      expression = @defaultValues

      if note isnt undefined
        for key in Object.keys(note)
          if note[key] isnt undefined
            expression[key] = note[key]

      output = gen.saw expression
      output = eff.ramp output
      output

  sineFade:
    defaultValues:
      amplitude: 0.5
      sustain: 22050
      tone: 404

    generate: (note) ->
      expression = @defaultValues

      if note isnt undefined
        for key in Object.keys(note)
          if note[key] isnt undefined
            expression[key] = note[key]

      output = gen.sine expression
      output = eff.ramp output
      output = eff.fadeOut output

      output

  sawFade:
    defaultValues:
      amplitude: 0.5
      sustain: 22050
      tone: 404
      harmonicCount: 8

    generate: (note) ->
      expression = @defaultValues

      if note isnt undefined
        for key in Object.keys(note)
          if note[key] isnt undefined
            expression[key] = note[key]

      output = gen.saw expression
      output = eff.ramp output
      output = eff.fadeOut output
      output = eff.fadeOut output

      output

  sample:
    defaultValues:
      amplitude: 0.5
      seed: 'luxPlate0'
      sustain: 1
      tone: 1

    generate: (note) ->
      expression = @defaultValues

      if note isnt undefined
        for key in Object.keys(note)
          if note[key] isnt undefined
            expression[key] = note[key]

      output = (Nt.open expression.seed + '.wav')[0]
      output = eff.convolve

