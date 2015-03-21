Nt    = require './build/Release/NtCpp'
oldNt = require './../NtYhS/generate'

dataSizeIteration = 0
while dataSizeIteration < 3

  duration = 88200 * (3 ** dataSizeIteration)

  generateAverage = 0
  writeAverage    = 0
  readAverage     = 0

  averagingIteration = 0
  while averagingIteration < 10

    sineGenerateStart = Date.now()
    Nt.sine 'dankSine0.wav', 666.667, duration
    sineGenerateTime = Date.now() - sineGenerateStart

    sineWriteStart = Date.now()
    Nt.sineWrite 'dankSine1.wav', 666.667, duration
    sineWriteTime = Date.now() - sineWriteStart

    sineReadStart = Date.now()
    Nt.sineRead 'dankSine1.wav'
    sineReadTime = Date.now() - sineReadStart

    generateAverage += sineGenerateTime
    writeAverage    += sineWriteTime
    readAverage     += sineReadTime

    averagingIteration++

  generateAverage /= 30
  writeAverage    /= 30
  readAverage     /= 30

  console.log '#############################'
  console.log 'TIMES FOR DURATION : ', duration
  console.log 'GENERATE : ', generateAverage
  console.log 'WRITE    : ', writeAverage - generateAverage
  console.log 'READ     : ', readAverage

  dataSizeIteration++

