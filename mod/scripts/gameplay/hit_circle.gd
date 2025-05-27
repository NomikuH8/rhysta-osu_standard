extends Node2D


@onready var hit_circle: Sprite2D = $Colored/Sprite2D
@onready var hit_circle_overlay: Sprite2D = $Overlay/Sprite2D


static var skin: Dictionary
var number: int = 0
var hit_time: int
var hit_window: int = 150
var was_hit: bool = false
var result: String = ""


static func _static_init():
	var mod = ModManager.loaded_mods.filter(func(m): return m["file_name"] == "osu_standard")[0]
	var skin_name = Options.config.get_value(mod["file_name"], "skin", "Default")
	var skin_path = "res://modules/" + mod["file_name"] + "/skins/" + skin_name
	skin = SkinManager.get_from_path(skin_path)


func _ready():
	hit_circle.texture = skin["hitcircle.png"]
	hit_circle_overlay.texture = skin["hitcircleoverlay.png"]
	set_process(true)


func _process(_delta):
	var time = get_game_time_ms()
	var time_diff = time - hit_time

	if not was_hit and time_diff > hit_window:
		result = "miss"
		queue_free()


func try_hit() -> String:
	var time = get_game_time_ms()
	var time_diff = abs(time - hit_time)

	if was_hit:
		return ""

	if time_diff <= 30:
		result = "perfect"
	elif time_diff <= 80:
		result = "good"
	elif time_diff <= hit_window:
		result = "bad"
	else:
		result = "miss"

	if result != "miss":
		was_hit = true
		queue_free()

	return result


func get_game_time_ms() -> int:
	var root = get_tree().get_root().get_node("Gameplay")
	var time = (Time.get_ticks_usec() - root.time_begin) / 1000000.0
	time -= root.time_delay
	time = max(0, time)
	return round(time * 1000)
