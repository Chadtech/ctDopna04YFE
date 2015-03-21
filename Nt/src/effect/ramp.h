int ramp(int sustain, short * audio){
  
  int rampDuration;
  if (sustain > 60){
    rampDuration = 60; 
  }
  else{
    rampDuration = sustain;
  }

  int datumIndex = 0;
  while (datumIndex < rampDuration){
    short thisSample = audio[datumIndex];
    float fade = datumIndex;
    fade /= rampDuration;

    audio[datumIndex] = (short)(thisSample * fade);
    datumIndex++;
  }

  datumIndex = 0;
  while (datumIndex < rampDuration){
    short thisSample = audio[sustain - 1 - datumIndex];
    float fade = datumIndex;
    fade /= rampDuration;

    audio[sustain - 1 - datumIndex] = (short)(thisSample * fade);
    datumIndex++;
  }

  return datumIndex;
}