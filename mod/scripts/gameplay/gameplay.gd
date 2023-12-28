extends Node


@onready var player: AudioStreamPlayer = $Player


var diff: Dictionary = {}
var path: String = ""
var time_begin: float
var time_delay: float
var current_hit_object: Dictionary = {}


func _ready():
	import_audio()
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	player.play()


func _process(_delta: float):
	var time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	time -= time_delay
	time = max(0, time)
	var time_millis = round(time * 1000)
	
	if not current_hit_object.has("time"):
		current_hit_object["time"] = 0
	
	if time_millis >= current_hit_object["time"]:
		current_hit_object = diff["HitObjects"][diff["HitObjects"].find(current_hit_object) + 1]


func import_audio():
	var audio_filename: String = diff["General"]["AudioFilename"]
	var audio_path = path + "/" + audio_filename
	var audio_stream
	
	if audio_filename.ends_with("mp3"):
		audio_stream = AudioStreamMP3.new()
		var file = FileAccess.open(audio_path, FileAccess.READ)
		audio_stream.data = file.get_buffer(file.get_length())
	
	if audio_filename.ends_with("wav"):
		audio_stream = AudioStreamWAV.new()
		var file = FileAccess.open(audio_path, FileAccess.READ)
		audio_stream.data = file.get_buffer(file.get_length())
	
	player.stream = audio_stream
