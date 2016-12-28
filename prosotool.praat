form Make Prosogram
	sentence input_path input
	positive stylization 2
	real smoothing 1.5
	choice pitch_scale: 2
		button standard
		button dynamic
	choice operating_system: 1
		button windows
		button unix
endform

if pitch_scale = 1
	pitch_scale$ = "standard"
else
	pitch_scale$ = "dynamic"
endif
if operating_system = 1
	operating_system$ = "windows"
else
	operating_system$ = "unix"
endif

appendInfoLine: ""
appendInfoLine: ""
appendInfoLine: "---------------------------"
appendInfoLine: "Starting speaker separation"
appendInfoLine: "---------------------------"
appendInfoLine: ""
runScript: "sp_sep.praat", input_path$, "yes", operating_system$
appendInfoLine: ""
appendInfoLine: "--------------------"
appendInfoLine: "Starting F0 analysis"
appendInfoLine: "--------------------"
appendInfoLine: ""
runScript: "intonation.praat", stylization, smoothing, pitch_scale$, "no", operating_system$
