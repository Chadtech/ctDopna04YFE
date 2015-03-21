float sine (int sustain, float frequency, short * audio ){

  double pi = 3.14159;
  int maxAmplitude = 32767;

  frequency /= 44100;

  short sample;

  int sampleIndex = 0;
  while (sampleIndex < sustain){



    sample = maxAmplitude * sin(pi * frequency * sampleIndex * 2);
    // *(audio + outputIndex) = sample;
    audio[ sampleIndex ] = sample;

    //std::cout << sample << "\n";

    sampleIndex++;
  }
  return sampleIndex;
}