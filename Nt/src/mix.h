int mix(

  short * output,
  int duration,

  short * audio0,
  float audio0Volume,

  short * audio1,
  float audio1Volume

  ){

  short audio0Sample;
  short audio1Sample;

  int sampleIndex = 0;
  while (sampleIndex < duration){
    audio0Sample = audio0[ sampleIndex ];
    audio0Sample *= audio0Volume;

    audio1Sample = audio1[ sampleIndex ];
    audio1Sample *= audio1Volume; 


    //std::cout << audio0Sample << " " << audio1Sample << "\n";
    output[ sampleIndex ] = audio0Sample + audio1Sample;

    sampleIndex++;
  }

  return sampleIndex;
}