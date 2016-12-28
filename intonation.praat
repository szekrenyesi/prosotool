form Make Pitch
	positive stylization 2
	real smoothing 1.5
	choice pitch_scale: 2
		button standard
		button dynamic
	boolean meaning 0
	choice operating_system: 1
		button windows
		button unix
endform

input_path$ = "input"
logfile$ = "log.txt"
if fileReadable (logfile$) 
	deleteFile: logfile$
endif

# Open audio file(s)

Create Strings as file list: "wavList", input_path$ + "/*.wav"
select Strings wavList
number_of_inputfiles = Get number of strings
if number_of_inputfiles = 0 
	Remove
	exit The directory doesn't contain any Wav file
endif
for fcall from 1 to number_of_inputfiles
	select Strings wavList
	file$ = Get string: fcall
	appendInfoLine: ""
	appendInfoLine: "File: 'file$'"
	appendInfoLine: ""
	name$ = file$ - ".wav"
	name$ = name$ - ".WAV"
	textgridname$ = name$ + ".TextGrid"
	textgrid_path$ = "sp_sep/'name$'/" + textgridname$
	if operating_system = 1
		system_nocheck mkdir "output\'name$'"
	else
		system_nocheck mkdir "output/'name$'"
	endif
	writeFileLine: "output/'name$'/pitchranges.txt", "SPEAKER",tab$,"MIN",tab$,"MAX",tab$,"MEAN",tab$,"STDEV",tab$,"T1",tab$,"T2",tab$,"T3",tab$,"T4"
	if fileReadable (textgrid_path$)
		oText = Read from file: "sp_sep/'name$'/" + textgridname$
	else
		exit TextGrid file 'textgridname$' is not found in sp_sep
	endif
	
	tiernum = Get number of tiers
	
	for sptier from 1 to tiernum
		select TextGrid 'name$'
		speaker$ = Get tier name: sptier
		appendInfoLine: ""
		appendInfoLine: "Speaker: 'speaker$'"
		appendInfoLine: ""
		target_tier = sptier
		sponlywav$ = file$ - ".wav"
		sponlywav$ = sponlywav$ - ".WAV"
		sponlywav$ = sponlywav$ + "_" + speaker$ + ".wav"
		sponlywavpath$ = "sp_sep/'name$'/" + sponlywav$
		if fileReadable (sponlywavpath$)
			
			# Read or generate speaker's pitch object
			
			pitchfile$ = file$ - ".wav"
			pitchfile$ = pitchfile$ + "_" + speaker$ + ".Pitch"
			pitchfile_path$ = "sp_sep/'name$'/" + pitchfile$
			
			if fileReadable (pitchfile_path$)
				appendInfoLine: "Open 'speaker$' F0 file..."
				Read from file: "sp_sep/'name$'/" + pitchfile$
			else
				onlyID = Read from file: "sp_sep/'name$'/" + sponlywav$
				appendInfoLine: "Generate 'speaker$' F0 file..."
				firstPID = To Pitch (ac): 0, 40, 15, "no", 0.09, 0.45, 0.01, 0.35, 0.14, 600
				select onlyID
				Remove
				select firstPID
				Save as text file: "sp_sep/'name$'/" + pitchfile$
			endif
			
			# Get speaker f0 range
			
			minimum_f0= Get minimum: 0, 0, "Hertz", "Parabolic"
			maximum_f0= Get maximum: 0, 0, "Hertz", "Parabolic"
			q05 = Get quantile: 0.0, 0.0, 0.05, "Hertz"
			q10 = Get quantile: 0.0, 0.0, 0.10, "Hertz"
			q25 = Get quantile: 0.0, 0.0, 0.25, "Hertz"
			q30 = Get quantile: 0.0, 0.0, 0.30, "Hertz"
			q40 = Get quantile: 0.0, 0.0, 0.40, "Hertz"
			q45 = Get quantile: 0.0, 0.0, 0.45, "Hertz"
			q50 = Get quantile: 0.0, 0.0, 0.50, "Hertz"
			q60 = Get quantile: 0.0, 0.0, 0.60, "Hertz"
			q65 = Get quantile: 0.0, 0.0, 0.65, "Hertz"
			q70 = Get quantile: 0.0, 0.0, 0.70, "Hertz"
			q75 = Get quantile: 0.0, 0.0, 0.75, "Hertz"
			q90 = Get quantile: 0.0, 0.0, 0.90, "Hertz"
			q95 = Get quantile: 0.0, 0.0, 0.95, "Hertz"
			
			if pitch_scale = 1
				min_f0 = 20
				max_f0 = 600
			else
				min_f0 = 10*floor((0.93*q05)/10)
				max_f0 = 10*ceiling((1.5*q95)/10)
			endif
			Remove
			
			# Regenerate speaker's pitch object
			appendInfoLine: "Regenerate 'speaker$' F0 file..."
			Read from file: "sp_sep/'name$'/'name$'_'speaker$'.wav"
			To Pitch (ac): 0, min_f0, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, max_f0
			
			# Do statistics for classification
			
			appendInfoLine: "Doing some statisctics..."
			meanf0 = Get mean: 0, 0, "Hertz"
			stdev = Get standard deviation: 0, 0, "Hertz"
			medrange_lim = stdev / 3
			mov_limit = stdev / 2
			
			
			divf0range1 = meanf0 - stdev
			divf0range2 = meanf0 - medrange_lim
			divf0range3 = meanf0 + medrange_lim
			divf0range4 = meanf0 + stdev

			select all
			minus Strings wavList
			Remove
			
			# Create data files
			
			system_nocheck mkdir "output"
			if operating_system = 1
				system_nocheck mkdir "output\'name$'\'speaker$'"
			else
				system_nocheck mkdir "output/'name$'/'speaker$'"	
			endif
			appendFileLine: "output/'name$'/pitchranges.txt", speaker$,tab$,round(min_f0),tab$,round(max_f0),tab$,round(meanf0),tab$,round(stdev),tab$,round(divf0range1),tab$,round(divf0range2),tab$,round(divf0range3),tab$,round(divf0range4)
			
			# Open annotations
			
			if fileReadable (textgrid_path$)
				oText = Read from file: "sp_sep/'name$'/" + textgridname$
			else
				exit Error: TextGrid file 'textgridname$' is not found in sp_sep
			endif
			
			intnum = Get number of intervals: target_tier
			tiernum = Get number of tiers
			
			tdur = Get total duration
			sent_num = 1
			
			# Detect silences
			
			appendInfoLine: "Perfoming silence detection..."
			wavID = Read from file: input_path$ + "/" + file$
			silID = To TextGrid (silences): 100, 0, -35, 0.5, 0.1, "silent", "sounding"
			Rename... target
			select wavID
			Remove
			select silID
			Insert interval tier: 2, "target"
			longID = Open long sound file: input_path$ + "/" + file$
			
			# Start stylization
			
			appendInfoLine: "Processing speech segments..."
			for icall from 1 to intnum
				select TextGrid 'name$'
				sent_label$ = Get label of interval: target_tier, icall
				if sent_label$ != ""
					stpoint = Get start point: target_tier, icall
					enpoint = Get end point: target_tier, icall
					select TextGrid target
					stint = Get interval at time: 1, stpoint
					lint = Get interval at time: 1, enpoint
					for pint from stint to lint
						select TextGrid target
						label$ = Get label of interval: 1, pint
						if label$ = "sounding"
							s_stpoint = Get start point: 1, pint
							s_enpoint = Get end point: 1, pint
							if s_enpoint = enpoint or s_enpoint > enpoint
								pint = lint
								s_enpoint = enpoint
							endif
							if s_stpoint < stpoint
								s_stpoint = stpoint
							endif
							targetdur = s_enpoint - s_stpoint
							if targetdur >= 0.25
								number$ = "'sent_num'"
								nocheck Insert boundary: 2, s_stpoint
								nocheck Insert boundary: 2, s_enpoint
								target_int = Get interval at time: 2, s_stpoint
								Set interval text: 2, target_int, "target"
								select longID
								Extract part: s_stpoint, s_enpoint, "yes"
								wavID = selected ("Sound")
								pitchID = To Pitch (ac): 0, min_f0, 15, "no", 0.09, 0.45, 0.01, 0.35, 0.14, max_f0
								pointID = To PointProcess
								vuvText = To TextGrid (vuv): 0.02, 0.01
								Write to text file: "output/'name$'/'speaker$'/'name$'_'number$'_vuv.TextGrid"
								select pitchID
								smoothID = Smooth: smoothing
								select smoothID
								trendID = Down to PitchTier
								Write to text file: "output/'name$'/'speaker$'/'name$'_'number$'_smooth.PitchTier"
								if meaning = 1
									rstart = Get start time
									frnt = s_stpoint + 0.5
									meanID = Create PitchTier: "mean", s_stpoint, s_enpoint
									select trendID
									while frnt < s_enpoint
										prev = frnt - 0.5
										fp = Get high index from time: prev
										lp = Get low index from time: frnt
										if lp > s_stpoint and fp > s_stpoint and fp <= lp
											n = lp - fp
											n = n + 1
											s = 0
											for p from fp to lp
												v= Get value at index: p
												s = s + v
											endfor
											s = s / n
											select meanID
											a = frnt - 0.25
											Add point: a, s
											select trendID
										endif	
										frnt = frnt + 0.5
									endwhile
									select meanID
									Save as text file: "output/'name$'/'speaker$'/'name$'_'number$'_mean.PitchTier"
								endif
								Stylize: stylization, "Semitones"
								Write to text file: "output/'name$'/'speaker$'/'name$'_'number$'_trend.PitchTier"
								select pitchID
								ptierID = Down to PitchTier
								Write to text file: "output/'name$'/'speaker$'/'name$'_'number$'_pitch.PitchTier"
								select wavID
								plus pitchID
								plus smoothID
								plus ptierID
								plus trendID
								plus vuvText
								plus pointID
								if meaning = 1
									plus meanID
								endif
								Remove
								sent_num = sent_num + 1
							endif
						endif
					endfor
				endif
			endfor
			
			appendInfoLine: "Concatenate results..."
			
			# Concatenate original curves
			
			nopitch = 0
			Create Strings as file list: "stylList", "output/'name$'/'speaker$'/*pitch.PitchTier"
			select Strings stylList
			n = Get number of strings
			if n > 0 
				Create PitchTier: "'name$'_original", 0, tdur
				for scall from 1 to n
					select Strings stylList
					partfile$ = Get string: scall
					Read from file: "output/'name$'/'speaker$'/'partfile$'"
					part_name$ = selected$ ("PitchTier")
					points_num = Get number of points
					for ppp from 1 to points_num
						time_v = Get time from index: ppp
						freq_v = Get value at index: ppp
						select PitchTier 'name$'_original
						Add point: time_v, freq_v
						select PitchTier 'part_name$'
					endfor
					Remove
				endfor
				select PitchTier 'name$'_original
				point_num = Get number of points
				Write to text file: "output/'name$'/'speaker$'/'name$'_original.PitchTier"
				plus Strings stylList
			else
				nopitch = 1
				appendInfoLine: "Segments are too shorts or unvoiced. No results for this speaker!"
				appendFileLine: logfile$, "'name$': Speaker ('speaker$') has too shorts or unvoiced segments. No results."
			endif
			Remove
			
			# Concatenate smoothed curves
			
			if nopitch = 0
				Create Strings as file list: "stylList", "output/'name$'/'speaker$'/*smooth.PitchTier"
				select Strings stylList
				n = Get number of strings
				if n = 0 
					Remove
					exit The directory doesn't contain any PitchTier file
				endif
				Create PitchTier: "'name$'_fullsmooth", 0, tdur
				for scall from 1 to n
					select Strings stylList
					partfile$ = Get string: scall
					Read from file: "output/'name$'/'speaker$'/'partfile$'"
					part_name$ = selected$ ("PitchTier")
					points_num = Get number of points
					for ppp from 1 to points_num
						time_v = Get time from index: ppp
						freq_v = Get value at index: ppp
						select PitchTier 'name$'_fullsmooth
						Add point: time_v, freq_v
						select PitchTier 'part_name$'
					endfor
					Remove
				endfor
				select PitchTier 'name$'_fullsmooth
				Write to text file: "output/'name$'/'speaker$'/'name$'_fullsmooth.PitchTier"
				plus Strings stylList
				Remove
			endif
			
			
			# Concatenate stylized curves
			
			if nopitch = 0
				Create Strings as file list: "stylList", "output/'name$'/'speaker$'/*trend.PitchTier"
				select Strings stylList
				n = Get number of strings
				if n = 0 
					Remove
					exit The directory doesn't contain any PitchTier file
				endif
				Create PitchTier: "'name$'_trends", 0, tdur
				for scall from 1 to n
					select Strings stylList
					partfile$ = Get string: scall
					Read from file: "output/'name$'/'speaker$'/'partfile$'"
					part_name$ = selected$ ("PitchTier")
					points_num = Get number of points
					for ppp from 1 to points_num
						time_v = Get time from index: ppp
						freq_v = Get value at index: ppp
						select PitchTier 'name$'_trends
						Add point: time_v, freq_v
						select PitchTier 'part_name$'
					endfor
					Remove
				endfor
				select PitchTier 'name$'_trends
				point_num = Get number of points
				Write to text file... output/'name$'/'speaker$'/'name$'_trends.PitchTier
				select Strings stylList
				Remove
			endif


			# Concatenate avaraged curves
			
			if meaning = 1 and nopitch = 0
				Create Strings as file list: "stylList", "output/'name$'/'speaker$'/*mean.PitchTier"
				select Strings stylList
				n = Get number of strings
				if n = 0 
					Remove
					exit The directory doesn't contain any PitchTier file
				endif
				Create PitchTier: "'name$'_fullmean", 0, tdur
				for scall from 1 to n
					select Strings stylList
					partfile$ = Get string: scall
					Read from file: "output/'name$'/'speaker$'/'partfile$'"
					part_name$ = selected$ ("PitchTier")
					points_num = Get number of points
					for ppp from 1 to points_num
						time_v = Get time from index: ppp
						freq_v = Get value at index: ppp
						select PitchTier 'name$'_fullmean
						Add point: time_v, freq_v
						select PitchTier 'part_name$'
					endfor
					Remove
				endfor
				select PitchTier 'name$'_fullmean
				Write to text file: "output/'name$'/'speaker$'/'name$'_fullmean.PitchTier"
				plus Strings stylList
				Remove
			endif
			
			# Create prosodic annotation
			
			if nopitch = 0
			
				appendInfoLine: "Creating annotation..."
				
				Create TextGrid: 0, tdur, "'speaker$'_F0Mov 'speaker$'_F0Level 'speaker$'_F0Value 'speaker$'_Voice","'speaker$'_F0Level 'speaker$'_F0Value"
				Rename: "pitchmovements"
				select PitchTier 'name$'_trends
				points_num = Get number of points
				if points_num > 1
					for pp from 1 to points_num
						select PitchTier 'name$'_trends
						time_value = Get time from index: pp
						select TextGrid pitchmovements
						Insert boundary: 1, time_value
						Insert point: 2, time_value, ""
						Insert point: 3, time_value, ""
					endfor
					
					# Find target
					
					targetnum = 0
					select TextGrid target
					intnum = Get number of intervals: 2
					for iii from 1 to intnum
						select TextGrid target
						label$ = Get label of interval: 2, iii
						if label$ != ""
							targetnum = targetnum + 1
							target$ = "'targetnum'"
							vuvID = Read from file: "output/'name$'/'speaker$'/'name$'_'target$'_vuv.TextGrid"
							select TextGrid target
							st = Get start point: 2, iii
							en = Get end point: 2, iii
							select PitchTier 'name$'_trends
							first_p = Get high index from time: st
							last_p = Get low index from time: en
							
							# Classify
							
							select PitchTier 'name$'_trends
							
							for ppp from first_p to last_p
								if ppp != last_p and ppp != 0
									index1 = ppp
									index2 = ppp + 1
									time1 = Get time from index: index1
									time2 = Get time from index: index2
									pppdur = time2 - time1
									
									select vuvID
									unvoiced = 0
									first_vuv_int = Get interval at time: 1, time1
									last_vuv_int = Get interval at time: 1, time2
									undurtot = 0
									for vuvint from first_vuv_int to last_vuv_int
										vuvLab$ = Get label of interval: 1, vuvint
										if vuvLab$ = "U"
											unst = Get start point: 1, vuvint
											unen = Get end point: 1, vuvint
											undur = unen - unst
											undurtot = undurtot + undur
											select TextGrid pitchmovements
											nocheck Insert boundary: 4, unst
											nocheck Insert boundary: 4, unen
											resvuvint = Get interval at time: 4, unst
											Set interval text: 4, resvuvint, "U"
											select vuvID
										else
											vst = Get start point: 1, vuvint
											ven = Get end point: 1, vuvint
											select TextGrid pitchmovements
											nocheck Insert boundary: 4, vst
											nocheck Insert boundary: 4, ven
											resvuvint = Get interval at time: 4, vst
											Set interval text: 4, resvuvint, "V"
											select vuvID
										endif
									endfor
									unrate = undurtot / pppdur
									if unrate > 0.8 or pppdur < 0.1
										unvoiced = 1
									endif
									
									select PitchTier 'name$'_trends
									if unvoiced = 0
										progressdur = time2 - time1
										value1 = Get value at index: index1
										value2 = Get value at index: index2
										dif_value = abs(value2 - value1)
										dif_value2 = dif_value / progressdur
										if dif_value > mov_limit or dif_value2 > mov_limit
											if value2 > value1
												movement_lab$ = "ascending"
												if dif_value2 > mov_limit and dif_value > mov_limit
													movement_lab$ = "rise"
												endif
											else
												movement_lab$ = "descending"
												if dif_value2 > mov_limit and dif_value > mov_limit
													movement_lab$ = "fall"
												endif
											endif
										else
											movement_lab$ = "level"
										endif
										select TextGrid pitchmovements
										targetint = Get interval at time: 1, time1
										Set interval text: 1, targetint, movement_lab$
										
										p1 = Get nearest index from time: 2, time1
										p2 = Get nearest index from time: 2, time2

										if value1 < divf0range1
											Set point text: 2, p1, "L2"
										endif
										if value1 > divf0range1 and value1 < divf0range2
											Set point text: 2, p1, "L1"
										endif
										if value1 > divf0range2 and value1 < divf0range3
											Set point text: 2, p1, "M"
										endif
										if value1 > divf0range3 and value1 < divf0range4
											Set point text: 2, p1, "H1"
										endif
										if value1 > divf0range4
											Set point text: 2, p1, "H2"
										endif
										
										if value2 < divf0range1
											Set point text: 2, p2, "L2"
										endif
										if value2 > divf0range1 and value2 < divf0range2
											Set point text: 2, p2, "L1"
										endif
										if value2 > divf0range2 and value2 < divf0range3
											Set point text: 2, p2, "M"
										endif
										if value2 > divf0range3 and value2 < divf0range4
											Set point text: 2, p2, "H1"
										endif
										if value2 > divf0range4
											Set point text: 2, p2, "H2"
										endif
										
										p1 = Get nearest index from time: 2, time1
										p2 = Get nearest index from time: 2, time2
										
										value1$ = "'value1:2'"
										value2$ = "'value2:2'"
										
										Set point text: 3, p1, value1$
										Set point text: 3, p2, value2$
										
										select PitchTier 'name$'_trends
									endif
								endif
							endfor
							select vuvID
							Remove
						endif
					endfor
				endif
				# Save Results
				appendInfoLine: "Saving results..."
				select TextGrid target
				Write to text file: "output/'name$'/'name$'_'speaker$'_segments.TextGrid"
				select TextGrid pitchmovements
				Write to text file: "output/'name$'/'name$'_'speaker$'_pitch.TextGrid"
				plus PitchTier 'name$'_trends
			endif
			plus TextGrid target
			plus LongSound 'name$'
			Remove
		else
			appendInfoLine: "Result of separation is not found. Too much overlapping speech? No results for this speaker!"
			appendFileLine: logfile$, "'name$': Speaker ('speaker$') can not be analysed because of overlapping speech."
		endif
	endfor
	appendInfoLine: ""
	appendInfoLine: "Merging results..."
	restiernum = 0
	for tier from 1 to tiernum
		select TextGrid 'name$'
		speaker$[tier] = Get tier name: tier
		tier[tier] = 1
		speaker$ = speaker$[tier]
		respartpath$ = "output/'name$'/'name$'_'speaker$'_pitch.TextGrid"
		if fileReadable (respartpath$)
			Read from file: "output/'name$'/'name$'_'speaker$'_pitch.TextGrid"
			restiernum = restiernum + 1
		else
			tier[tier] = 0
		endif
	endfor
	if restiernum > 0
		for tier from 1 to tiernum
			if tier[tier] = 1
				speaker$ = speaker$[tier]
				plus TextGrid 'name$'_'speaker$'_pitch
			endif
		endfor
		Merge
		Write to text file: "output/'name$'_pitch.TextGrid"
		for tier from 1 to tiernum
			if tier[tier] = 1
				speaker$ = speaker$[tier]
				plus TextGrid 'name$'_'speaker$'_pitch
			endif
		endfor
		appendFileLine: logfile$, "'name$': Successfully done."
	else
		appendInfoLine: "Too much overlapping or unvoiced speech. No results for file: 'name$'"
		appendFileLine: logfile$, "'name$': Too much overlapping or unvoiced speech. No results for the file."
	endif
	plus TextGrid 'name$'
	Remove
endfor

appendInfoLine: ""
appendInfoLine: "All done!"
appendInfoLine: ""
