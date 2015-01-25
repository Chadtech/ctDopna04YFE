#include <nan.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

// For sine function
#include <math.h>

#include "./generate/sine.h"
#include "./generate/saw.h"

#include "./wavWrite.h"

using namespace v8;
using v8::String;

NAN_METHOD(version){
  NanScope();
  const char * ntVersion0 = "ntv1bcpp";
  Local <String> ntVersion1 = NanNew<String>(ntVersion0);
  NanReturnValue(ntVersion1);
}

NAN_METHOD(saw){
  NanScope();

  v8::String::Utf8Value param1(args[0]->ToString());
  std::string fileName0 = std::string(*param1);
  const char * fileName = fileName0.c_str();

  double frequency = args[1]->NumberValue();
  frequency /= 44100;
  int harmonicCount = args[2]->Uint32Value();
  int sustain = args[3]->Uint32Value();

  short * audio = new short[sustain];
  int confirmation = saw(frequency, sustain, harmonicCount, audio);

  writeWAVData( fileName, audio, sustain * 2, 44100, 1 );
  // NanReturnValue(NanNew<Number>(confirmation));
  NanReturnUndefined();

  // Local<Array> output = NanNew<Array>(sustain);

  // int sampleIndex = 0;
  // while (sampleIndex < sustain){
  //   short sample = audio[sampleIndex];
  //   output->Set(sampleIndex, NanNew(sample));
  //   sampleIndex++;
  // }

  // NanReturnValue(output);
}

// Arguments are:
// filename frequency duration
NAN_METHOD(sine){
  NanScope();

  v8::String::Utf8Value param1(args[0]->ToString());
  std::string fileName0 = std::string(*param1);
  const char * fileName = fileName0.c_str();

  double frequency = args[1]->NumberValue();
  frequency /= 44100;

  int sustain = args[2]->Uint32Value();

  short * audio = new short[sustain];
  int confirmation = sine(frequency, sustain, audio);

  //writeWAVData( fileName, audio, sustain * 2, 44100, 1 );
  NanReturnValue(NanNew<Number>(confirmation));
  //NanReturnUndefined();
}

NAN_METHOD(sineWrite){
  NanScope();

  v8::String::Utf8Value param1(args[0]->ToString());
  std::string fileName0 = std::string(*param1);
  const char * fileName = fileName0.c_str();

  double frequency = args[1]->NumberValue();
  frequency /= 44100;

  int sustain = args[2]->Uint32Value();

  short * audio = new short[sustain];
  int confirmation = sine(frequency, sustain, audio);

  writeWAVData( fileName, audio, sustain * 2, 44100, 1 );

  NanReturnUndefined();
}

NAN_METHOD(sineRead){
  NanScope();

  v8::String::Utf8Value param1(args[0]->ToString());
  std::string fileName0 = std::string(*param1);
  const char * fileName = fileName0.c_str();

  std::ifstream wav;
  wav.open(fileName, std::ifstream::in);

  wav.seekg(0, wav.end);
  int length = wav.tellg();
  wav.seekg(0, wav.beg);

  int data [length];

  int datumIndex = 0;
  while (datumIndex < length){
    data[datumIndex] = wav.get();
    datumIndex++;
  }

  int numberOfChannels = data[22];

  datumIndex = 44;
  int audioDataLength = (length - 44) / 2;
  int audioData [audioDataLength];
  int audioDatumIndex = 0;
  int thisSampleDatum [2];

  while (datumIndex < length){
    if ((datumIndex % 2) == 0){
      thisSampleDatum[0] = data[datumIndex];
    }
    else{
      thisSampleDatum[1] = data[datumIndex];
      short sample = thisSampleDatum[1] * 256;
      sample += thisSampleDatum[0];
      audioData[audioDatumIndex] = sample;
      audioDatumIndex++;
    }
    datumIndex++;
  }

  wav.close();

  NanReturnUndefined();

}

void Init(Handle<Object> exports){
  exports->Set(NanNew("version"),
    NanNew<FunctionTemplate>(version)->GetFunction());

  exports->Set(NanNew("sineRead"),
    NanNew<FunctionTemplate>(sineRead)->GetFunction());

  exports->Set(NanNew("sineWrite"),
    NanNew<FunctionTemplate>(sineWrite)->GetFunction());

  exports->Set(NanNew("sine"),
    NanNew<FunctionTemplate>(sine)->GetFunction());

  exports->Set(NanNew("saw"),
    NanNew<FunctionTemplate>(saw)->GetFunction());
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
