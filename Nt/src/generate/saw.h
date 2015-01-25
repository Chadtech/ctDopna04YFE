int saw ( float frequency, 
          const int sustain, 
          const int harmonicCount, 
          short * audio){

  float pi = 3.14159;
  int maxAmplitude = 32767;

  int volumeNumerator = 2 * harmonicCount;
  int volumeDenominator = harmonicCount - 1;
  volumeDenominator = pow(volumeDenominator, 2);
  volumeDenominator++;
  volumeDenominator = pow(volumeDenominator, 0.5);
  volumeDenominator *= pi;

  float volumeAdjust = volumeNumerator;
  volumeAdjust /= volumeDenominator;
  volumeAdjust = 1 - volumeAdjust;

  int harmonic = 1;
  while (harmonic < harmonicCount){
    int outputIndex = 0;
    while (outputIndex < sustain){
      short sample = maxAmplitude; 
      if((harmonic % 2) == 1){
        sample *= -1;
      }
      sample /= harmonic;
      float sineArgument = outputIndex * pi * 2;
      sineArgument *= harmonic; 
      sineArgument *= frequency;
      sample *= sin(sineArgument);
      sample *= volumeAdjust;
      *(audio + outputIndex) += sample;
      outputIndex++;
    }
    harmonic++;
  }
  return 1; 
}