int lopass(short * audio, int audioLength){

  short average;

  int datumIndex = 7;
  while (datumIndex < audioLength){
    average =  (audio[ datumIndex ] / 8);
    average += (audio[ datumIndex - 1 ] / 8);
    average += (audio[ datumIndex - 2 ] / 8);
    average += (audio[ datumIndex - 3 ] / 8);
    average += (audio[ datumIndex - 4 ] / 8);
    average += (audio[ datumIndex - 5 ] / 8);
    average += (audio[ datumIndex - 6 ] / 8);
    average += (audio[ datumIndex - 7 ] / 8);

    audio[ datumIndex ] = average;
    datumIndex++;
  }

  return datumIndex;

}