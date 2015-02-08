int convolve(
  float factor, 

  short * audio, 
  int audioLength,

  short * convolveSeed,
  int convolveLength,

  short * output
  ){


  int outputLength = convolveLength + audioLength;

  int outputIndex = 0;
  while (outputIndex < outputLength){
    output[ outputIndex ] = 0;
    outputIndex++;
  }


  short thisSample;
  int convolveIndex;
  float audioPercent;
  float convolvePercent;
  float product;

  int audioIndex = 0;
  while (audioIndex < audioLength){

    convolveIndex = 0;
    while (convolveIndex < convolveLength){
    // while (convolveIndex < 3){

      // std::cout << "-------\n";
      // std::cout << "AUDIO AT " << audio[ audioIndex ] << "\n";
      // std::cout << "CONVOLVE AT " << convolveSeed[ convolveIndex ] << "\n";

      audioPercent    = ((float) audio[ audioIndex ]) / 32767;
      convolvePercent = ((float) convolveSeed[ convolveIndex ]) / 32767;

      // std::cout << "AUDIO PERCENT " << audioPercent << "\n";
      // std::cout << "CONVOLVE PERCENT " << convolvePercent << "\n";

      product = audioPercent * convolvePercent;

      // std::cout << "PRODUCT STAGE 0 " << product << "\n";

      product *= factor;

      // std::cout << "PRODUCT STAGE 1 " << product << "\n";

      thisSample = product * 32767;

      // std::cout << "THIS SAMPLE " << thisSample << "\n";

      output[ audioIndex + convolveIndex ] += thisSample;

      convolveIndex++;
    }
    audioIndex++;
  }

  return outputIndex;
}