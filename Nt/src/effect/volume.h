int volume( float factor, int audioLength, short * audio){

  int outputIndex = 0;
  while (outputIndex < audioLength){
    audio[ outputIndex ] *= factor;
    outputIndex++;
  }

  return outputIndex;

}