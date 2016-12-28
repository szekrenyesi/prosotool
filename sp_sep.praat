form Speaker Separation
	sentence input input
	boolean extract_sound yes
	choice operating_system: 1
		button windows
		button unix
endform

system_nocheck mkdir sp_sep
Create Strings as file list: "wavList",  input$ + "/*.wav"
select Strings wavList
number_of_inputfiles = Get number of strings
if number_of_inputfiles = 0 
	Remove
	exit The directory doesn't contain any Wav file
endif
for fcall from 1 to number_of_inputfiles
	select Strings wavList
	file$ = Get string: fcall
	Open long sound file: input$ + "/" + file$
	appendInfoLine: ""
	appendInfoLine: "File: 'file$'"
	appendInfoLine: ""
    name$ = selected$ ("LongSound")
    if operating_system = 1
		system_nocheck mkdir "sp_sep\'name$'"
	else
		system_nocheck mkdir "sp_sep/'name$'"
	endif
	textpath$ = input$ + "/" + name$ + ".TextGrid"
    if fileReadable (textpath$)
		Read from file: textpath$
	else
		soundID = Read from file: input$ + "/" + file$
		silID = To TextGrid (silences): 100, 0, -35, 0.5, 0.1, "", "sounding"
		Set tier name: 1, "speech"
		select soundID
		Remove
		select silID
	endif

	tdur = Get total duration

	tiernum = Get number of tiers
	
	for spx from 1 to tiernum
		select TextGrid 'name$'
		speaker$ = Get tier name: spx
		speaker$ = replace$ (speaker$, "|", "_", 0)
		speaker$ = replace$ (speaker$, " ", "_", 0)
		speaker$['spx'] = speaker$
		firstdone = 0
		for other from 1 to tiernum
			if other != spx
				if firstdone = 0
					spxt = spx
					rest = tiernum + 1
					Insert interval tier: rest, "spX" 
				else
					spxt = tiernum + 1
					rest = tiernum + 2
					Insert interval tier: rest, "spX"
				endif
				intnum = Get number of intervals: spxt
				for i from 1 to intnum
					label$ = Get label of interval: spxt, i
					if label$ != ""
						start = Get start point: spxt, i
						end = Get end point: spxt, i
						ointfirst = Get interval at time: other, start
						ointlast = Get interval at time: other, end
						for o from ointfirst to ointlast
							olabel$ = Get label of interval: other, o
							ostart = Get start point: other, o
							oend = Get end point: other, o
							if ostart < start or ostart = start
								if oend < end
									nocheck Insert boundary: rest, start
									nocheck Insert boundary: rest, oend
									nocheck Insert boundary: rest, end
									tint1 = Get interval at time: rest, start
									tint2 = Get interval at time: rest, oend
									if olabel$ != ""
										Set interval text: rest, tint1, "OV"
										Set interval text: rest, tint2, speaker$
									else
										Set interval text: rest, tint1, speaker$
										Set interval text: rest, tint2, speaker$
									endif
								else
									nocheck Insert boundary: rest, start
									nocheck Insert boundary: rest, end
									tint = Get interval at time: rest, start
									if olabel$ != ""
										Set interval text: rest, tint, "OV"
									else
										Set interval text: rest, tint, speaker$
									endif
								endif
							endif
							if ostart > start and ostart < end
								if oend < end
									nocheck Insert boundary: rest, start
									nocheck Insert boundary: rest, ostart
									nocheck Insert boundary: rest, oend
									nocheck Insert boundary: rest, end
									tint1 = Get interval at time: rest, start
									tint2 = Get interval at time: rest, ostart
									tint3 = Get interval at time: rest, oend
									if olabel$ != ""
										Set interval text: rest, tint2, "OV"
										Set interval text: rest, tint3, speaker$
									else
										Set interval text: rest, tint2, speaker$
										Set interval text: rest, tint3, "OV"
									endif
								else
									nocheck Insert boundary: rest, start
									nocheck Insert boundary: rest, ostart
									nocheck Insert boundary: rest, end
									tint1 = Get interval at time: rest, start
									tint2 = Get interval at time: rest, ostart
									if olabel$ != ""
										Set interval text: rest, tint2, "OV"
									else
										Set interval text: rest, tint2, speaker$
									endif
								endif
							endif
						endfor
					endif
				endfor				
				if firstdone != 0
					select spText
					Remove
				endif
				spText = Create TextGrid: 0, tdur, "'speaker$'", ""
				select TextGrid 'name$'
				intnum = Get number of intervals: rest
				for i from 1 to intnum
					label$ = Get label of interval: rest, i
					if label$ = speaker$
						start = Get start point: rest, i
						end = Get end point: rest, i
						select spText
						nocheck Insert boundary: 1, start
						nocheck Insert boundary: 1, end
						int = Get interval at time: 1, start
						Set interval text: 1, int, speaker$
						select TextGrid 'name$'
					endif
				endfor
				select TextGrid 'name$'
				Remove tier: rest
				if firstdone != 0
					Remove tier: spxt
				endif
				select spText
				intnum = Get number of intervals: 1
				for i from 1 to intnum
					label$ = Get label of interval: 1, i
					if label$ = speaker$ and i != intnum
						labnext$ = speaker$
						while labnext$ = speaker$ and i < intnum
							next = i + 1
							labnext$ = Get label of interval: 1, next
							if labnext$ = speaker$
								Remove right boundary: 1, i
								Set interval text: 1, i, speaker$
								intnum = intnum - 1
							endif
						endwhile
					endif
				endfor
				if other != tiernum
					select TextGrid 'name$'
					plus spText
					newID = Merge
					select TextGrid 'name$'
					Remove
					select newID
					Rename: name$
					firstdone = 1
				endif
			endif
			if spx = tiernum and other = tiernum and firstdone != 0
				Remove tier: spxt
			endif
		endfor
		if tiernum = 1
			spText = Create TextGrid: 0, tdur, "'speaker$'", ""
			select TextGrid 'name$'
			intnum = Get number of intervals: 1
			for i from 1 to intnum
				label$ = Get label of interval: 1, i
				if label$ != ""
					start = Get start point: 1, i
					end = Get end point: 1, i
					select spText
					nocheck Insert boundary: 1, start
					nocheck Insert boundary: 1, end
					int = Get interval at time: 1, start
					Set interval text: 1, int, speaker$
					select TextGrid 'name$'
				endif
			endfor
			select spText
			intnum = Get number of intervals: 1
			for i from 1 to intnum
				label$ = Get label of interval: 1, i
				if label$ = speaker$ and i != intnum
					labnext$ = speaker$
					while labnext$ = speaker$ and i < intnum
						next = i + 1
						labnext$ = Get label of interval: 1, next
						if labnext$ = speaker$
							Remove right boundary: 1, i
							Set interval text: 1, i, speaker$
							intnum = intnum - 1
						endif
					endwhile
				endif
			endfor
		endif
		if extract_sound = 1
			appendInfoLine: "Extracting 'speaker$'..."
			select spText
			intnum = Get number of intervals: 1
			p = 0
			for i from 1 to intnum
				label$ = Get label of interval: 1, i
				if label$ = speaker$
					p = p + 1
					start = Get start point: 1, i
					end = Get end point: 1, i
					select LongSound 'name$'
					Extract part: start, end, "no"
					Rename: "part'p'"
					select spText
				endif
			endfor
			if p > 0
				select Sound part1
				if p > 1
					for i from 2 to p
						plus Sound part'i'
					endfor
					Concatenate
				endif
				Rename: "'name$'_'speaker$'"
			endif
			if p > 1
				select Sound part1
				if p > 1
					for i from 2 to p
						plus Sound part'i'
					endfor
				endif
				Remove
			endif
			if p > 0
				select Sound 'name$'_'speaker$'
				Write to WAV file: "sp_sep/'name$'/'name$'_'speaker$'.wav"
				Remove
			endif
		endif	
	endfor

	select TextGrid 'speaker$[1]'
	for i from 2 to tiernum
		textsp$ = speaker$['i']
		plus TextGrid 'textsp$'
	endfor
	Merge
	Write to text file: "sp_sep/'name$'/'name$'.TextGrid"
	for i from 1 to tiernum
		textsp$ = speaker$['i']
		plus TextGrid 'textsp$'
	endfor
	Remove
	select TextGrid 'name$'
	plus LongSound 'name$'
	Remove
endfor
