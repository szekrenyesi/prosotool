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
Praat prosotool.praat INPUT_DIRECTIRY_PATH SCALE_OF_STYLISATION SCALE_OF_SMOOTHING PITCH_EXTRACTION_METHOD OPERATING_SYSTEM 
```
##Example
```
Praat prosotool.praat input 2 1.5 dynamic windows
```
