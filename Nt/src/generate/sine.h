int sine (double frequency, const int sustain, short * audio){

  double pi = 3.14159;
  int maxAmplitude = 32767;

  int outputIndex = 0;
  while (outputIndex < sustain){
    short sample = maxAmplitude * sin(pi * frequency * outputIndex * 2);
    *(audio + outputIndex) = sample;
    outputIndex++;
  }

  return outputIndex; 
}