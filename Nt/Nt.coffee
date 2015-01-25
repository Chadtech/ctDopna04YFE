Nt = require './build/Release/NtCpp'
oldNt = require '../reallyOldNt/noitech'
gen = oldNt.generate

duration = 11025

start = Date.now()

Nt.saw 'dankSaw3.wav', 466.667, 8, duration

end = Date.now()

console.log 'Saw ', end - start

start = Date.now()

Nt.sine 'dankSine3.wav', 466.667, duration

end = Date.now()

console.log 'Sine ', end - start