package main

import (
    // "bufio"
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



func readWAV( openFileName string ) []int{

  readFile, err := os.Open( openFileName )
  check(err)

  readFile.Seek(40, 0)

  var sizeOfAudioBuffer int64 = 0
  durationByte := make([]byte, 4)

  readFile.Read( durationByte )

  sizeOfAudioBuffer += int64(durationByte[0])
  sizeOfAudioBuffer += 256 * int64(durationByte[1])
  sizeOfAudioBuffer += 65536 * int64(durationByte[2])
  sizeOfAudioBuffer += 16777216 * int64(durationByte[3])
  durationOfAudio := int64(sizeOfAudioBuffer / 2)

  output := make([]int, durationOfAudio )

  for datumIndex := int64(0); datumIndex < durationOfAudio; datumIndex++ {

    thisSampleByte := make([]byte, 2)
    readFile.Read( thisSampleByte )


    output[ datumIndex ] = 0
    output[ datumIndex ] += int(thisSampleByte[ 0 ])
    output[ datumIndex ] += int(thisSampleByte[ 1 ]) * 256

  }

  return output

}


func writeWAV( audio []int, fileName string) {
  
  savedFile, err := os.Create( fileName)
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

  wavHeader[24] = 68
  wavHeader[25] = 172
  wavHeader[26] = 0
  wavHeader[27] = 0

  wavHeader[28] = 68
  wavHeader[29] = 172
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

    wavData[  audioIndex * 2      ] = byte(audio[ audioIndex ] % 256)
    wavData[ (audioIndex * 2) + 1 ] = byte(audio[ audioIndex ] / 256)

  }

  savedFile.Write(wavHeader)
  savedFile.Write(wavData)

  savedFile.Close()

}


func getFraction ( fraction float64 ) []int {
  // check(err)

  multiplier := 1
  keepLooking := true

  for keepLooking {

    denominatorCandidate := float64(multiplier) * fraction

    distanceToWholeNumber := math.Abs(denominatorCandidate - math.Floor( denominatorCandidate + 0.00005))

    if distanceToWholeNumber < 0.00001 {
      keepLooking = false
    } else {
      multiplier++
    }

  }

  numerator := math.Floor((float64(multiplier) * fraction) + 0.5)
  denominator := multiplier

  output := make([]int, 2)

  output[0] = int(numerator)
  output[1] = int(denominator)

  return output

}


func multiplySpeed ( audio []int, factorIncrease int) []int {

  output := make([]int, len(audio) / factorIncrease )

  for outputIndex := 0; outputIndex < len(output); outputIndex++ {

    outputsSample := 0

    for factorIndex := 0; factorIndex < factorIncrease; factorIndex++ {

      signedAudio := 0
      signedAudio += audio[ (outputIndex * factorIncrease) + factorIndex ]

      if signedAudio > 32767 {
        signedAudio -= 65535
      }

      outputsSample += signedAudio / factorIncrease
    
    }

    output[ outputIndex ] = outputsSample

  }

  return output

} 



func divideSpeed ( audio []int, factorDecrease int) []int {

  output := make([]int, len(audio) * factorDecrease )

  for audioIndex := 0; audioIndex < (len(audio) - 1); audioIndex++ {

    signedAudio := 0
    signedAudio += audio[ audioIndex ]
    signedAudioNext := 0
    signedAudioNext += audio[ audioIndex + 1]

    if signedAudio > 32767 {
      signedAudio -= 65535
    }
    if signedAudioNext > 32767 {
      signedAudioNext -= 65535
    }

    differenceBetweenSamples := signedAudioNext - signedAudio
    singleInterval := differenceBetweenSamples / factorDecrease

    for factorIndex := 0; factorIndex < factorDecrease; factorIndex++ {

      output[ (audioIndex * factorDecrease) + factorIndex ] = signedAudio + (factorIndex * singleInterval)

    }

  }

  return output

} 



func changePitch ( audio []int, factor float64 ) []int {

  output := make( []int, len(audio) )
  
  for audioIndex := 0; audioIndex < len(audio); audioIndex++ {
    output[ audioIndex ] = 0
  }

  fraction := getFraction( factor )
  grainRate := 1523
  grainLength := 8192
  numberOfGrains := (len( audio ) / grainRate) - 5
  grains := make( [][]int, numberOfGrains )

  for grainIndex := 0; grainIndex < (numberOfGrains - 1); grainIndex++ {

    grains[ grainIndex ] = make([]int, grainLength)

    for sampleIndex := 0; sampleIndex < grainLength; grainIndex++ {

      grains[ grainIndex ][ sampleIndex ] = audio[ (grainIndex * grainLength) + sampleIndex ]

    }

  }



  audioIndexOfLastGrain := len( audio ) - ((numberOfGrains - 1) * grainRate)

  grains[ len(grains) - 1 ] = make( []int, len(audio) - audioIndexOfLastGrain )

  for sampleIndex := 0; sampleIndex < len( audio ); sampleIndex++ {

    grains[ len(grains) - 1 ][ sampleIndex ] = audio[ sampleIndex ]
  
  }



  pitchedGrains := make( [][]int, numberOfGrains )

  for grainIndex := 0; grainIndex < len(grains); grainIndex++ {

    thisGrain := grains[ grainIndex ]
    thisGrain = divideSpeed( thisGrain, fraction[1] )
    thisGrain = multiplySpeed (thisGrain, fraction[0] )

    pitchedGrains[ grainIndex ] = make( []int, len(thisGrain) )

    for pitchedGrainIndex := 0; pitchedGrainIndex < len(thisGrain); pitchedGrainIndex++ {

      pitchedGrains[ grainIndex ][ pitchedGrainIndex ] = thisGrain[ pitchedGrainIndex ]

    }

  }


  for grainIndex := 0; grainIndex < len( pitchedGrains ); grainIndex++ {

    for sampleIndex := 0; sampleIndex < len( pitchedGrains[grainIndex] ); sampleIndex++ {

      thisSample := 0
      thisSample += pitchedGrains[ grainIndex ][ sampleIndex ]

      if thisSample > 32767 {
        thisSample -= 65535
      }
      thisSample /= 5

      output[ (grainIndex * grainRate) + sampleIndex ] += thisSample

    }

  }

  return output

}

func main() {

  fileToOpen    := os.Args[1]
  factor, err := strconv.ParseFloat( os.Args[2], 64 )
  check(err)

  // fmt.Println( speedIncrease)

  audio := readWAV( fileToOpen )

  audio = changePitch( audio, factor)

  // audio = divideSpeed(audio, int(speedIncrease))
  // audio = multiplySpeed(audio, int(speedIncrease))

  writeWAV( audio, "increasedAudio.wav")

}



