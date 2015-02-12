int fadeOut( int duration, short * audio){

  float fadeIncrement = 1;
  fadeIncrement /= duration;

  float sample;

  int sampleIndex = 0;
  while (sampleIndex < duration ){
    sample = audio[ sampleIndex ];
    sample *= (1.0 - (fadeIncrement * sampleIndex));

    audio[ sampleIndex ] = (short) sample;

    sampleIndex++;
  }

  return sampleIndex;
}