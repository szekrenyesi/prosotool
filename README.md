# ProsoTool (emPros)
ProsoTool is a language independent algorithm implemented as a Praat script for the automatic annotation of intonation. The script stylizes F0 contour into larger (perceptually relevant) intonation segments which are classified based on the individual speech properties of the speakers. This tool is also integrated into the [e-magyar](http://www.e-magyar.hu) language processing system.

## Requirements

* Praat 6.0.13 or later

## Input

* The speech sound file in WAV format (sample.wav)
* The acoustic annotation of speaker change in Praat TextGrid format (sample.TextGrid). The speakers must be represented in different tiers.

## Output

* The type of intonation movement (rise, fall, descending, ascending, level)
* The relative position of movement (as point to point vector) in the individual vocal range of the speaker
* The above information expressed in Hertz

##Usage

```
Praat prosotool.praat INPUT STYLIZATION SMOOTHING PITCH_EXTRACTION OPERATING_SYSTEM 
```

##Options

* INPUT: The path of input directory
* STYLIZATION: The scale of stilization in semitones (integer number). The langer number results stronger stylization.
* SMOOTHING: The scale of smoothing (real number). The smaller number results stronger smoothing.
* PITCH_EXTRACTION: The method of pitch extraction: "standard" (with fixed parameters) or "dynamic" (speaker-depedent)
* OPERATING_SYSTEM: The type of running environment: "windows" or "unix"

##Example
```
./Praat prosotool.praat input 2 1.5 dynamic unix
```
##Citation

Please, cite [this](http://ieeexplore.ieee.org/document/7390606/) article on ProsoTool and [here](http://www.fon.hum.uva.nl/praat/manual/FAQ__How_to_cite_Praat.html) is the way how to cite Praat.
