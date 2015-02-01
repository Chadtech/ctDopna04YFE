float sine (int sustain, float frequency, short * audio ){

  double pi = 3.14159;
  int maxAmplitude = 32767;

  frequency /= 44100;

  int outputIndex = 0;
  while (outputIndex < sustain){
    short sample = maxAmplitude * sin(pi * frequency * outputIndex * 2);
    *(audio + outputIndex) = sample;
    outputIndex++;
  }

  return outputIndex; 
}