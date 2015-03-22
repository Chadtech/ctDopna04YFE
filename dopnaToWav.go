package main

import (
    //"bufio"
    // "fmt"
    // "io"
    // "io/ioutil"
    "strconv"
    "os"
    "math"
)

func check(e error){
  if e != nil {
    panic(e)
  }
}


// Function to generate a sine wave
func sine( sustain int, frequency float64) []int {

  output := make([]int, sustain)

  frequency /= 44100

  maxAmplitude := 32767

  for index := 0; index < sustain; index++ {

    sample := float64(maxAmplitude) * math.Sin(math.Pi * frequency * float64(index))

    output[index] = int(sample * 0.25)
  }

  return output
}



//  Function to quickly volume ramp the beginning
//  and end of a audio buffer
func ramp( audio []int ) []int {

  var rampDuration float32
  if len(audio) > 60 {
    rampDuration = 60
  } else {
    rampDuration = float32(len(audio))
  }

 for sampleIndex := 0; sampleIndex < int(rampDuration); sampleIndex++ {
    audio[ sampleIndex ] = int(float32(sampleIndex) / rampDuration)
 }
  
 for sampleIndex := 0; sampleIndex < int(rampDuration); sampleIndex++ {
    audio[ len(audio) - 1 - sampleIndex ] = int(float32(sampleIndex) / rampDuration)
 }

 return audio
}



// A function to change the volume of an audio buffer 
func volume( audio []int, volume float32 ) []int {

  for sampleIndex := 0; sampleIndex < len(audio); sampleIndex++ {
    audio[ sampleIndex ] = int(float32(audio[ sampleIndex ]) * volume)
  }

  return audio
}



//  A function to pad the beginning of an audio buffer with
//  silence
func delayBy( audio []int, delay int) []int {
  output := make([]int, delay + len(audio))

  for delayIndex := 0; delayIndex < delay; delayIndex++ {
    output[ delayIndex] = 0
  }

  for sampleIndex := 0; sampleIndex < len(audio); sampleIndex++ {
    output[ sampleIndex ] = audio[ sampleIndex ]
  }

  return output
}



// A function to write an audio buffer to a 
// single channel wav file
func writeWAV( saveFileName string, audio []int) {

  savedFile, err := os.Create(saveFileName)
  check(err)

  wavHeader := make([]byte, 44)

  wavHeader[0] = 82
  wavHeader[1] = 73
  wavHeader[2] = 70
  wavHeader[3] = 70

  wavHeader[4] = 36
  wavHeader[5] = 8
  wavHeader[6] = 0
  wavHeader[7] = 0

  wavHeader[8]  = 87
  wavHeader[9]  = 65
  wavHeader[10] = 86
  wavHeader[11] = 69

  wavHeader[12] = 102
  wavHeader[13] = 109
  wavHeader[14] = 116
  wavHeader[15] = 32
 
  wavHeader[16] = 16
  wavHeader[17] = 0
  wavHeader[18] = 0
  wavHeader[19] = 0

  wavHeader[20] = 1
  wavHeader[21] = 0
  wavHeader[22] = 1
  wavHeader[23] = 0

  wavHeader[24] = 172
  wavHeader[25] = 68
  wavHeader[26] = 0
  wavHeader[27] = 0

  wavHeader[28] = 172
  wavHeader[29] = 68
  wavHeader[30] = 0
  wavHeader[31] = 0

  wavHeader[32] = 4
  wavHeader[33] = 0
  wavHeader[34] = 16
  wavHeader[35] = 0

  wavHeader[36] = 100
  wavHeader[37] = 97
  wavHeader[38] = 116
  wavHeader[39] = 97

  wavHeader[40] = byte(len(audio) % 256)
  wavHeader[41] = byte(len(audio) / 256)
  wavHeader[42] = byte(len(audio) / 4096)
  wavHeader[43] = byte(len(audio) / 65536)

  wavData := make([]byte, (len(audio)) * 2)

  for audioIndex := 0; audioIndex < len(audio); audioIndex++ {

    wavData[ (audioIndex * 2) + 1 ] = byte(audio[audioIndex] / 256)
    wavData[ audioIndex * 2 ] = byte(audio[audioIndex] % 256)
  }

  savedFile.Write(wavHeader)
  savedFile.Write(wavData)

  savedFile.Close()

}




func main() {


  // Get the arguments, which are the names
  // of the files we are opening and saving
  dopnaFileName := os.Args[1]
  saveFileNameL := os.Args[2]
  saveFileNameR := os.Args[3]

  // Open up the Dopna file
  dopnaFile, err := os.Open(dopnaFileName)
  check(err)
  dopnaFile.Seek(8, 0)



  // Get the length of the musical scale
  // which is by default 7 intervals long
  scaleLengthByte := make([]byte, 1)
  dopnaFile.Read(scaleLengthByte)

  scaleLength := int(scaleLengthByte[0])

  var scale = make([]float32, scaleLength)
  for scaleIndex := 0; scaleIndex < scaleLength; scaleIndex++ {
    thisIntervalByte := make([]byte, 8)
    dopnaFile.Read(thisIntervalByte)

    thisInterval, err := strconv.ParseFloat(string(thisIntervalByte), 32)
    check(err)
    
    scale[scaleIndex] = float32(thisInterval)
  }



  // Read the information regarding
  // the voices in the ensemble
  ensembleSizeByte := make([]byte, 2)
  dopnaFile.Read(ensembleSizeByte)

  ensembleSize := int(ensembleSizeByte[0]) * 256
  ensembleSize += int(ensembleSizeByte[1])

  var ensembleXPositions = make([]int, ensembleSize)
  var ensembleYPositions = make([]int, ensembleSize)
  var ensembleTypes      = make([]string, ensembleSize)
  var ensembleConvolves  = make([]string, ensembleSize)

  for ensembleIndex := 0; ensembleIndex < ensembleSize; ensembleIndex++ {

    typeByte := make([]byte, 4)
    dopnaFile.Read(typeByte)
    ensembleTypes[ ensembleIndex ] = string(typeByte)

    xPosByte := make([]byte, 2)
    dopnaFile.Read(xPosByte)
    ensembleXPositions[ ensembleIndex ] = int(xPosByte[0]) * 256
    ensembleXPositions[ ensembleIndex ] += int(xPosByte[1])

    yPosByte := make([]byte, 2)
    dopnaFile.Read(yPosByte)
    ensembleYPositions[ ensembleIndex ] = int(yPosByte[0]) * 256
    ensembleYPositions[ ensembleIndex ] = int(yPosByte[1])

    convolveByte := make([]byte, 12)
    dopnaFile.Read(convolveByte)
    ensembleConvolves[ensembleIndex] = string(convolveByte)

  }



  // Get the dimensions, meaning, get all the dimensions
  // that a note possesses (typically things like volume
  // tone, sustain)
  numberOfDimensionsByte := make([]byte, 1)
  dopnaFile.Read(numberOfDimensionsByte)
  numberOfDimensions := int(numberOfDimensionsByte[0])

  dimensions := make([]string, numberOfDimensions)

  for dimensionIndex := 0; dimensionIndex < numberOfDimensions; dimensionIndex++ {
    dimensionByte := make([]byte, 12)
    dopnaFile.Read(dimensionByte)
    dimensions[ dimensionIndex ] = string(dimensionByte)
  }




  // Get the duration of the piece in beats and then collect 
  // the duration in samples of each beat
  pieceDurationByte := make([]byte, 2)
  dopnaFile.Read(pieceDurationByte)

  pieceDurationInBeats := int(pieceDurationByte[0]) * 256
  pieceDurationInBeats += int(pieceDurationByte[1])

  beatTimes := make([]int, pieceDurationInBeats)

  for beatIndex := 0; beatIndex < pieceDurationInBeats; beatIndex++ {
    thisBeatDuration := make([]byte, 2)
    dopnaFile.Read(thisBeatDuration)
    beatTimes[ beatIndex ] = int(thisBeatDuration[0]) * 256
    beatTimes[ beatIndex ] += int(thisBeatDuration[1])
  }




  // Read the data for every note, which is an array
  // of values, with each indice corresponding to a dimension
  score := make([][][]float32, ensembleSize)
  for ensembleIndex := 0; ensembleIndex < ensembleSize; ensembleIndex++ {

    score[ensembleIndex] = make([][]float32, pieceDurationInBeats)
    for beatIndex := 0; beatIndex < pieceDurationInBeats; beatIndex++ {

      existsOrNotByte := make([]byte, 1)
      dopnaFile.Read(existsOrNotByte)
      score[ ensembleIndex ][ beatIndex ] = make([]float32, numberOfDimensions + 1)
      score[ ensembleIndex ][ beatIndex ][0] = float32(existsOrNotByte[0])
      for dimensionIndex := 0; dimensionIndex < numberOfDimensions; dimensionIndex++ {
        
        thisDimension := make([]byte, 8)
        dopnaFile.Read(thisDimension)

        thisDimensionAsFloat, err := strconv.ParseFloat(string(thisDimension), 32)
        check(err)

        score[ ensembleIndex ][ beatIndex ][ dimensionIndex + 1] = float32(thisDimensionAsFloat)
      }
    }
  }



  // Figure out the duration of the piece in samples
  // by getting the sum of durations of each beat
  var pieceDurationInSamples int64 = 0
  for timeIndex := 0; timeIndex < pieceDurationInBeats; timeIndex++ {
    pieceDurationInSamples += int64(beatTimes[ timeIndex ])
  }



  // Create an audio buffer for the left and right channels
  pieceL := make([]int, pieceDurationInSamples)
  pieceR := make([]int, pieceDurationInSamples)

  for pieceIndex := 0; int64(pieceIndex) < pieceDurationInSamples; pieceIndex++ {
    pieceL[ pieceIndex ] = 0
    pieceR[ pieceIndex ] = 0
  }



  // Figure out what the index is for each dimension
  var indexOfSustain int
  var indexOfFrequency int
  var indexOfAmplitude int

  for dimensionIndex := 0; dimensionIndex < numberOfDimensions; dimensionIndex++ {
    
    if dimensions[ dimensionIndex ] == "00000sustain" {
      indexOfSustain = dimensionIndex + 1
    }

    if dimensions[ dimensionIndex ] == "00000000tone" {
      indexOfFrequency = dimensionIndex + 1
    }

    if dimensions[ dimensionIndex ] == "000amplitude" {
      indexOfAmplitude = dimensionIndex + 1
    }
  }



  // Read through the entire score, generate an audio buffer
  // from that note, and add that audio buffer to the output
  // audio buffer
  for ensembleIndex := 0; ensembleIndex < ensembleSize; ensembleIndex++ {
    


      // Get the name for the convolve file
      // (a wav file)
      // 
      // Convolving is a technique to simulate how the note would sound
      // in a particular room, or from a particular amplifier
      seekRealChar := true
      convolveNameStartAt := 0
      for seekRealChar {
        if ensembleConvolves[ ensembleIndex ][ convolveNameStartAt ] != 48 {
          seekRealChar = false
        }
        convolveNameStartAt++
      }

      ensembleConvolves[ ensembleIndex ] = ensembleConvolves[ ensembleIndex][ (convolveNameStartAt - 1) : 12 ]




      //

      // OPEN CONVOLVE FILE HERE ---- WIP

      //




      // Figure out from what direction, this voice
      // is coming from
      var direction float64 = math.Atan2(
        float64(ensembleXPositions[ ensembleIndex ]), 
        float64(ensembleYPositions[ ensembleIndex ]))
      direction /= math.Pi



      // Figure out how far away it is, and calculate
      // the duration it would take the sound to reach
      // the listener from that distance (in meters)
      var distance float64 
      distance = math.Pow(float64(ensembleXPositions[ ensembleIndex ]), 2)
      distance += math.Pow(float64(ensembleYPositions[ ensembleIndex ]), 2)
      distance = math.Sqrt(distance)
      var delay int = int((distance / 340) * 44100 )



    // Check for the type of this voice, and generate the 
    // Notes according to that voice
    if ensembleTypes[ ensembleIndex ] == "sine"{

      var timeAtThisNote int64 = 0

      for pieceIndex := 0; pieceIndex < pieceDurationInBeats; pieceIndex++ {
        if score[ ensembleIndex ][ pieceIndex ][0] == 1 {

          sustain := int(score[ ensembleIndex ][ pieceIndex ][ indexOfSustain ])
          frequency := score[ ensembleIndex ][ pieceIndex ][ indexOfFrequency ]
          amplitude := score[ ensembleIndex ][ pieceIndex ][ indexOfAmplitude ]

          thisNote := sine(sustain, float64(frequency) )
          thisNote = ramp( thisNote )
          thisNote = volume( thisNote, float32(amplitude) )
          thisNote = delayBy( thisNote, delay )

          for sampleIndex := 0; sampleIndex < len(thisNote); sampleIndex++ {
            pieceR[ int64(sampleIndex) + timeAtThisNote ] += thisNote[ sampleIndex ]
            pieceL[ int64(sampleIndex) + timeAtThisNote ] += thisNote[ sampleIndex ]
          }

        }

        timeAtThisNote += int64(beatTimes[ pieceIndex ])

      }
    }
  }



  // write the output audio buffers to disk as wavs
  writeWAV( saveFileNameL, pieceL)
  writeWAV( saveFileNameR, pieceR)

  // fmt.Println("DANK MEME")
}




