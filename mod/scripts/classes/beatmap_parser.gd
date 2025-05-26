class_name BeatmapParser
extends Node


static func parse(beatmap_text: String) -> Dictionary:
	var beatmap_parsed: Dictionary = {}
	var sections = beatmap_text.split("\r\n\r\n")
	for section in sections:
		var lines = section.split("\r\n")
		var current_ini_section: String = ""
		
		for line in lines:
			if line.is_empty() or line.begins_with("//") or line.begins_with("osu file format"):
				continue
			
			if line.begins_with("[") and line.ends_with("]"):
				current_ini_section = line.strip_edges().trim_prefix("[").trim_suffix("]")
				if ["Events", "TimingPoints", "HitObjects"].has(current_ini_section):
					beatmap_parsed[current_ini_section] = []
				else:
					beatmap_parsed[current_ini_section] = {}
				continue
			
			if current_ini_section == "Events":
				beatmap_parsed[current_ini_section].append(parse_event(line))
				continue
			
			if current_ini_section == "TimingPoints":
				beatmap_parsed[current_ini_section].append(parse_timing_point(line))
				continue
			
			if current_ini_section == "HitObjects":
				beatmap_parsed[current_ini_section].append(parse_hit_object(line))
				continue
			
			var key_value = line.split(":", true, 1)
			if key_value.size() == 2:
				beatmap_parsed[current_ini_section][key_value[0].strip_edges()] = key_value[1].strip_edges()
	
	return beatmap_parsed


# Events, like background, video, breaks, etc.
static func parse_event(line: String) -> Dictionary:
	var parts = line.split(",")
	if parts.size() == 0:
		return {}
	
	var type = int(parts[0])
	var structured = {"type": type}
	
	match type:
		0, 1:
			if parts.size() >= 5:
				structured["startTime"] = int(parts[1])
				structured["filename"] = parts[2]
				structured["xOffset"] = int(parts[3])
				structured["yOffset"] = int(parts[4])
		2:
			if parts.size() >= 3:
				structured["startTime"] = int(parts[1])
				structured["endTime"] = int(parts[2])

	return structured


# Timing points (BPM, speed, inheritance)
static func parse_timing_point(line: String) -> Dictionary:
	var parts = line.split(",")
	if parts.size() < 8:
		return {}
	
	return {
		"time": int(parts[0]),
		"beatLength": float(parts[1]),
		"meter": int(parts[2]),
		"sampleSet": int(parts[3]),
		"sampleIndex": int(parts[4]),
		"volume": int(parts[5]),
		"uninherited": int(parts[6]),
		"effects": int(parts[7])
	}


# HitObjects
static func parse_hit_object(line: String) -> Dictionary:
	var split = line.split(",")
	if split.size() < 5:
		return {}

	var x = int(split[0])
	var y = int(split[1])
	var time = int(split[2])
	var type = int(split[3])
	var hitSound = int(split[4])
	
	var base = {
		"x": x,
		"y": y,
		"time": time,
		"type": type,
		"hitSound": hitSound,
	}
	
	# Hit ciecle
	if (type & 1) != 0:
		base["inputType"] = "circle"
		if split.size() >= 7:
			base["objectParams"] = split[5]
			base["hitSample"] = split[6]
	
	# Slider
	elif (type & 2) != 0:
		base["inputType"] = "slider"
		if split.size() >= 8:
			var curve_data = split[5].split("|")
			var curve_type = curve_data[0]
			var curve_points = []
			for point in curve_data.slice(1):
				var coords = point.split(":")
				if coords.size() == 2:
					curve_points.append({ "x": int(coords[0]), "y": int(coords[1]) })
			
			base["curveType"] = curve_type
			base["curvePoints"] = curve_points
			base["slides"] = int(split[6])
			base["length"] = float(split[7])
		
		if split.size() >= 9:
			base["edgeSounds"] = []
			for e in split[8].split("|"):
				base["edgeSounds"].push_back(int(e))
		
		if split.size() >= 10:
			base["edgeSets"] = split[9].split("|")
		
		if split.size() >= 11:
			base["hitSample"] = split[10]
	
	# Spinner
	elif (type & 8) != 0:
		base["inputType"] = "spinner"
		if split.size() >= 7:
			base["endTime"] = int(split[5])
			base["hitSample"] = split[6]
	
	# Hold (mania)
	elif (type & 128) != 0:
		base["inputType"] = "hold"
		if split.size() >= 6:
			var hold_data = split[5].split(":")
			if hold_data.size() >= 1:
				base["endTime"] = int(hold_data[0])
	
	return base
