extends Node


@onready var game: Node2D = $Game
@onready var player: AudioStreamPlayer = $Player
@onready var hit_circle_scene = preload("res://modules/osu_standard/mod/scenes/gameplay/hit_circle.tscn")
#@onready var slider_scene = preload("res://Slider.tscn")
#@onready var spinner_scene = preload("res://Spinner.tscn")


var diff: Dictionary = {}
var path: String = ""
var time_begin: float
var time_delay: float
var current_object_index := 0


const PRELOAD_TIME_MS := 1000


func _ready():
	import_audio()
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	
	player.play()


func spawn_hit_object(obj: Dictionary):
	match obj.get("inputType", ""):
		"circle":
			var circle = hit_circle_scene.instantiate()
			circle.hit_time = obj["time"]
			circle.position = Vector2(obj["x"], obj["y"])
			circle.name = "Circle_%s" % obj["time"]
			game.add_child(circle)
		
		"slider":
			var slider = hit_circle_scene.instantiate()
			slider.position = Vector2(obj["x"], obj["y"])
			slider.name = "Slider_%s" % obj["time"]
			game.add_child(slider)
		
		"spinner":
			var spinner = hit_circle_scene.instantiate()
			spinner.name = "Spinner_%s" % obj["time"]
			game.add_child(spinner)


func _process(_delta: float):
	if current_object_index >= diff["HitObjects"].size():
		return
	
	var current_time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	current_time -= time_delay
	current_time = max(0, current_time)
	var current_time_ms = round(current_time * 1000)
	
	while current_object_index < diff["HitObjects"].size():
		var obj = diff["HitObjects"][current_object_index]
		if obj["time"] <= current_time_ms + PRELOAD_TIME_MS:
			spawn_hit_object(obj)
			current_object_index += 1
		else:
			break


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
	
	if audio_stream:
		player.stream = audio_stream
	else:
		push_error("failed to load audio: %s" % audio_path)


func _input(event: InputEvent):
	if (
		event is InputEventMouseButton and
		event.pressed and
		event.button_index == MOUSE_BUTTON_LEFT
	) or (
		event is InputEventKey and
		event.is_pressed() and
		(
			event.as_text() == "j" or
			event.as_text() == "l"
		)
	):
		for child in game.get_children():
			if child is Area2D and child.has_method("try_hit"):
				var result = child.try_hit()
				if result != "":
					print("Acerto:", result)
