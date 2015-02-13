int convolve(
  float factor, 

  short * audio, 
  int audioLength,

  float * convolveSeed,
  int convolveLength,

  short * output
  ){


  short thisSample;
  int convolveIndex;
  int audioIndex = 0;
  while (audioIndex < audioLength){

    convolveIndex = 0;
    while (convolveIndex < convolveLength){

      thisSample = audio[ audioIndex ];
      thisSample *= convolveSeed[ convolveIndex ];
      thisSample *= factor;

      //std::cout << "A " << audio[ audioIndex ] << " " << convolveSeed[ convolveIndex ] << " " << thisSample << "\n";

      output[ audioIndex + convolveIndex ] += thisSample;

      
      convolveIndex++;
    }
    audioIndex++;
  }

  return audioIndex;
}