module.exports = (scale, tonic, note) ->
  octave = note.substr 0, note.length - 1
  note = note.substr note.length - 1
  scaleIndex = parseInt note, scale.length
  octave = 2 ** parseInt octave

  tonic * scale[scaleIndex] * octave