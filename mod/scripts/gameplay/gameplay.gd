extends Node


@onready var player: AudioStreamPlayer = $Player
@onready var hit_circle_scene = preload("res://modules/osu_standard/mod/scenes/gameplay/hit_circle.tscn")
#@onready var slider_scene = preload("res://Slider.tscn")
#@onready var spinner_scene = preload("res://Spinner.tscn")


var diff: Dictionary = {}
var path: String = ""
var time_begin: float
var time_delay: float
var current_hit_object: Dictionary = {}


func _ready():
	spawn_hit_objects(diff["HitObjects"])
	import_audio()
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	player.play()


func spawn_hit_objects(objects: Array):
	for obj in objects:
		match obj.get("inputType", ""):
			"circle":
				var circle = hit_circle_scene.instantiate()
				circle.position = Vector2(obj["x"], obj["y"])
				circle.name = "Circle_%s" % obj["time"]
				add_child(circle)
			
			"slider":
				var slider = hit_circle_scene.instantiate()
				slider.position = Vector2(obj["x"], obj["y"])
				slider.name = "Slider_%s" % obj["time"]
				add_child(slider)
			
			"spinner":
				var spinner = hit_circle_scene.instantiate()
				spinner.name = "Spinner_%s" % obj["time"]
				add_child(spinner)


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
		audio_stream = AudioStreamMP3.load_from_file(audio_path)
	
	if audio_filename.ends_with("wav"):
		audio_stream = AudioStreamWAV.load_from_file(audio_path)
	
	if audio_filename.ends_with("ogg"):
		audio_stream = AudioStreamOggVorbis.load_from_file(audio_path)
	
	player.stream = audio_stream
