#include <nan.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>

// For sine function
#include <math.h>

#include "./generate/sine.h"
#include "./generate/saw.h"

#include "./wavWrite.h"

using namespace v8;
using v8::String;

NAN_METHOD(returnDopna){
  NanScope();

  v8::String::Utf8Value param1(args[0]->ToString());
  std::string fileName0 = std::string(*param1);
  const char * fileName = fileName0.c_str();

  std::ifstream dopnaFile;
  dopnaFile.open(fileName, std::ifstream::in);

  dopnaFile.seekg(0, dopnaFile.end);
  //int length = dopnaFile.tellg();
  dopnaFile.seekg(0, dopnaFile.beg);

  char header [8];
  int placeholderIndex = 0;
  int datumIndex = 0;
  while (datumIndex < 8){
    int thisHeaderItem = dopnaFile.get();
    header[datumIndex] = thisHeaderItem;
    datumIndex++;
  }

  int scaleLength = dopnaFile.get();

  // Get the scale, first as strings, then converted
  // to floats.
  float scale [scaleLength];
  placeholderIndex = 0;
  while (placeholderIndex < scaleLength){
    datumIndex = 0;
    char intervalAsChar [9];
    while (datumIndex < 8){
      char thisChar = (char) dopnaFile.get();
      intervalAsChar[datumIndex] = thisChar;
      datumIndex++;
    }
    intervalAsChar[datumIndex] = '\0';
    scale[placeholderIndex] = atof(intervalAsChar);
    placeholderIndex++;
  }


  // Get the ensemble, and save the voice types
  // and the voice positions in their respective
  // arrays
  int ensembleSize0 = dopnaFile.get();
  int ensembleSize1 = dopnaFile.get();
  int ensembleSize = (ensembleSize0 * 256) + ensembleSize1;

  short ensemblesPositions [ensembleSize][2];
  char ensembleTypes [ensembleSize][5];
  placeholderIndex = 0;
  while (placeholderIndex < ensembleSize){    
    int xPos0;
    int xPos1;
    short xPos;
    
    int yPos0;
    int yPos1;
    short yPos;

    datumIndex = 0;
    while (datumIndex < 4){
      ensembleTypes[placeholderIndex][datumIndex] = (char) dopnaFile.get();
      datumIndex++;
    }
    ensembleTypes[placeholderIndex][4] = '\0';

    xPos0 = dopnaFile.get();
    xPos1 = dopnaFile.get();
    xPos = (xPos0 * 256) + xPos1;
    if (xPos < 0){
      xPos += 32768;
      xPos *= -1;
    }

    yPos0 = dopnaFile.get();
    yPos1 = dopnaFile.get();
    yPos = (yPos0 * 256) + (yPos1);
    if (yPos < 0){
      yPos += 32768;
      yPos *= -1;
    }
    ensemblesPositions[placeholderIndex][0] = xPos;
    ensemblesPositions[placeholderIndex][1] = yPos;

    placeholderIndex++;
  }

  // Get Dimensions
  int numberOfDimensions = dopnaFile.get();
  char dimensions [numberOfDimensions][13];

  placeholderIndex = 0;
  while (placeholderIndex < numberOfDimensions){
    datumIndex = 0;
    while (datumIndex < 12){
      dimensions[placeholderIndex][datumIndex] = (char) dopnaFile.get();
      datumIndex++;
    }
    dimensions[placeholderIndex][12] = '\0';
    placeholderIndex++;
  }

  // Get Left and Right Convolve
  char leftConvolveData [13];
  char rightConvolveData [13];
  datumIndex = 0;
  while (datumIndex < 12){
    leftConvolveData[datumIndex] = dopnaFile.get();
    datumIndex++;
  }
  leftConvolveData[12] = '\0';
  datumIndex = 0;
  while (datumIndex < 12){
    rightConvolveData[datumIndex] = dopnaFile.get();
    datumIndex++;
  }
  rightConvolveData[12] = '\0';
  bool seekRealChar = true;
  int leftConvolveNameLength;
  datumIndex = 0;
  while (seekRealChar){
    if (leftConvolveData[datumIndex] != '0'){
      seekRealChar = false;
      leftConvolveNameLength = 12 - datumIndex;
    }
    datumIndex++;
  }
  seekRealChar = true;
  int rightConvolveNameLength;
  datumIndex = 0;
  while (seekRealChar){
    if (rightConvolveData[datumIndex] != '0'){
      seekRealChar = false;
      rightConvolveNameLength = 12 - datumIndex;
    }
    datumIndex++;
  }
  char leftConvolveName [leftConvolveNameLength + 1];
  char rightConvolveName [rightConvolveNameLength + 1];
  datumIndex = 0;
  int nameStartingAt = 12 - leftConvolveNameLength;
  while (datumIndex < leftConvolveNameLength){
    leftConvolveName[datumIndex] = leftConvolveData[nameStartingAt + datumIndex];
    datumIndex++;
  }
  leftConvolveName[leftConvolveNameLength] = '\0';
  datumIndex = 0;
  nameStartingAt = 12 - rightConvolveNameLength;
  while (datumIndex < rightConvolveNameLength){
    rightConvolveName[datumIndex] = rightConvolveData[nameStartingAt + datumIndex];
    datumIndex++;
  }
  rightConvolveName[rightConvolveNameLength] = '\0';



  std::ifstream leftConvolveFile;
  leftConvolveFile.open(leftConvolveName, std::ifstream::in);

  leftConvolveFile.seekg(0, leftConvolveFile.end);
  int lengthL = leftConvolveFile.tellg();
  leftConvolveFile.seekg(0, leftConvolveFile.beg);

  int dataL [lengthL];

  datumIndex = 0;
  while (datumIndex < lengthL){
    dataL[datumIndex] = leftConvolveFile.get();
    datumIndex++;
  }

  datumIndex = 44;
  int audioDataLengthL = (lengthL - 44) / 2;
  short leftConvolve [audioDataLengthL];
  int audioDatumIndex = 0;
  int thisSampleDatum [2];

  while (datumIndex < lengthL){
    if ((datumIndex % 2) == 0){
      thisSampleDatum[0] = dataL[datumIndex];
    }
    else{
      thisSampleDatum[1] = dataL[datumIndex];
      short sample = thisSampleDatum[1] * 256;
      sample += thisSampleDatum[0];
      leftConvolve[audioDatumIndex] = 0;
      leftConvolve[audioDatumIndex] = sample;
      audioDatumIndex++;
    }
    datumIndex++;
  }
  leftConvolveFile.close();

  std::ifstream rightConvolveFile;
  rightConvolveFile.open(rightConvolveName, std::ifstream::in);

  rightConvolveFile.seekg(0, rightConvolveFile.end);
  int lengthR = rightConvolveFile.tellg();
  rightConvolveFile.seekg(0, rightConvolveFile.beg);

  int dataR [lengthR];

  datumIndex = 0;
  while (datumIndex < lengthR){
    dataR[datumIndex] = rightConvolveFile.get();
    datumIndex++;
  }

  datumIndex = 44;
  int audioDataLengthR = (lengthR - 44) / 2;
  short rightConvolve [audioDataLengthR];
  audioDatumIndex = 0;

  while (datumIndex < lengthR){
    if ((datumIndex % 2) == 0){
      thisSampleDatum[0] = dataR[datumIndex];
    }
    else{
      thisSampleDatum[1] = dataR[datumIndex];
      short sample = thisSampleDatum[1] * 256;
      sample += thisSampleDatum[0];
      rightConvolve[audioDatumIndex] = sample;
      audioDatumIndex++;
    }
    datumIndex++;
  }
  rightConvolveFile.close();

  // writeWAVData( "REBATHROOML.wav", leftConvolve, audioDataLengthL * 2, 44100, 1);
  // writeWAVData( "REBATHROOMR.wav", rightConvolve, audioDataLengthR * 2, 44100, 1);

  int pieceDuration0 = dopnaFile.get();
  int pieceDuration1 = dopnaFile.get();

  int pieceDurationInBeats = pieceDuration0 * 256;
  pieceDurationInBeats += pieceDuration1;

  int timesData [pieceDurationInBeats * 2];
  int times [pieceDurationInBeats];

  int thisBeatTempo [2];

  datumIndex = 0;
  while (datumIndex < pieceDurationInBeats){
    thisBeatTempo[0] = dopnaFile.get();
    thisBeatTempo[1] = dopnaFile.get();
    int thisBeatDuration = thisBeatTempo[0] * 256;
    thisBeatDuration += thisBeatTempo[1];
    times[datumIndex] = thisBeatDuration;
    datumIndex++;
  }



  //NanReturnValue(ntVersion1);
  NanReturnUndefined();
}

void Init(Handle<Object> exports){
  exports->Set(NanNew("dopna"),
    NanNew<FunctionTemplate>(returnDopna)->GetFunction());
}


NODE_MODULE(NtCpp, Init);

  // Local<Array> output = NanNew<Array>(sustain);

  // int sampleIndex = 0;
  // while (sampleIndex < sustain){
  //   short sample = audio[sampleIndex];
  //   output->Set(sampleIndex, NanNew(sample));
  //   sampleIndex++;
  // }

  // NanReturnValue(output);

// NAN_METHOD(sineRead){
//   NanScope();

//   v8::String::Utf8Value param1(args[0]->ToString());
//   std::string fileName0 = std::string(*param1);
//   const char * fileName = fileName0.c_str();

//   double frequency = args[1]->NumberValue();
//   frequency /= 44100;

//   int sustain = args[2]->Uint32Value();

//   short * audio = new short[sustain];
//   int confirmation = sineGenerate1(frequency, sustain, audio);

//   Local<Array> output = NanNew<Array>(sustain);

//   int sampleIndex = 0;
//   while (sampleIndex < sustain){
//     short sample = audio[sampleIndex];
//     output->Set(sampleIndex, NanNew(sample));
//     sampleIndex++;
//   }

//   NanReturnValue(output);

// }
