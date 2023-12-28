class_name BeatmapParser
extends Node

# See https://osu.ppy.sh/wiki/en/Client/File_formats/osu_%28file_format%29
static func parse(beatmap_text: String) -> Dictionary:
	var beatmap_parsed: Dictionary = {}
	var sections = beatmap_text.split("\r\n\r\n")
	for section in sections:
		var full_variables = section.split("\r\n")
		var current_ini_section: String = ""
		for full_variable in full_variables:
			if full_variable.is_empty():
				continue 
			
			if full_variable.begins_with("//") or full_variable.begins_with("osu file format"):
				continue
			
			if full_variable.begins_with("[") and full_variable.ends_with("]"):
				current_ini_section = full_variable.replace("[", "").replace("]", "")
				if ["Events", "TimingPoints", "HitObjects"].has(current_ini_section):
					beatmap_parsed[current_ini_section] = []
				else:
					beatmap_parsed[current_ini_section] = {}
				continue
			
			if current_ini_section == "Events":
				var structured = BeatmapParser.parse_event(full_variable)
				beatmap_parsed[current_ini_section].push_back(structured)
				continue
			
			if current_ini_section == "TimingPoints":
				var structured = BeatmapParser.parse_timing_point(full_variable)
				beatmap_parsed[current_ini_section].push_back(structured)
				continue
			
			if current_ini_section == "HitObjects":
				var structured = BeatmapParser.parse_hit_object(full_variable)
				beatmap_parsed[current_ini_section].push_back(structured)
				continue
			
			var splitted_variable = full_variable.split(":", true, 1)
			if splitted_variable.size() <= 1:
				continue
			
			var key = splitted_variable[0].strip_edges()
			var value = splitted_variable[1].strip_edges()
			beatmap_parsed[current_ini_section][key] = value
	
	return beatmap_parsed


static func parse_event(variable: String) -> Dictionary:
	var split = variable.split(",")
	var type = int(split[0])
	var structured: Dictionary = {}
	
	if type == 0:
		structured = {
			"type": int(split[0]),
			"startTime": int(split[1]),
			"filename": split[2],
			"xOffset": int(split[3]),
			"yOffset": int(split[4])
		}
	
	if type == 1:
		structured = {
			"type": int(split[0]),
			"startTime": int(split[1]),
			"filename": split[2],
			"xOffset": int(split[3]),
			"yOffset": int(split[4])
		}
	
	if type == 2:
		structured = {
			"type": int(split[0]),
			"startTime": int(split[1]),
			"endTime": int(split[2])
		}
	
	return structured


static func parse_timing_point(variable: String) -> Dictionary:
	var split = variable.split(",")
	var structured = {
		"time": int(split[0]),
		"beatLength": int(split[1]),
		"meter": int(split[2]),
		"sampleSet": int(split[3]),
		"sampleIndex": int(split[4]),
		"volume": int(split[5]),
		"uninherited": int(split[6]),
		"effects": int(split[7])
	}
	
	return structured


static func parse_hit_object(variable: String) -> Dictionary:
	var split = variable.split(",")
	var type = int(split[3])
	var structured: Dictionary = {}
	if [0, 2, 4, 5, 6].has(type) and split.size() == 7:
		structured = {
			"x": int(split[0]),
			"y": int(split[1]),
			"time": int(split[2]),
			"type": int(split[3]),
			"hitSound": int(split[4]),
			"objectParams": split[5],
			"hitSample": split[6]
		}
	
	if [1, 2, 4, 5, 6].has(type) and split.size() > 10:
		var edge_sounds_string = split[8].split("|")
		var edge_sounds = []
		for edge_sound in edge_sounds_string:
			edge_sounds.push_back(int(edge_sound))
		
		var curve_points_string = split[5].split("|").slice(1)
		var curve_points = []
		for curve_point in curve_points_string:
			var curve_split = curve_point.split(":")
			curve_points.push_back({
				"x": curve_split[0],
				"y": curve_split[1]
			})
		
		structured = {
			"x": int(split[0]),
			"y": int(split[1]),
			"time": int(split[2]),
			"type": int(split[3]),
			"hitSound": int(split[4]),
			"curveType": split[5].split("|")[0],
			"curvePoints": curve_points,
			"slides": split[6],
			"length": split[7],
			"edgeSounds": edge_sounds,
			"edgeSets": split[9].split("|"),
			"hitSample": split[10]
		}
	
	if [3].has(type) and split.size() == 7:
		structured = {
			"x": split[0],
			"y": split[1],
			"time": split[2],
			"type": split[3],
			"hitSound": split[4],
			"endTime": split[5],
			"hitSample": split[6]
		}
	
	return structured
