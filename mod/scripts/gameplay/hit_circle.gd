extends Node2D


@onready var hit_circle: Sprite2D = $Colored/Sprite2D
@onready var hit_circle_overlay: Sprite2D = $Overlay/Sprite2D


static var skin: Dictionary
var number: int = 0


static func _static_init():
	var mod = ModManager.loaded_mods.filter(func(m): return m["file_name"] == "osu_standard")[0]
	var skin_name = Options.config.get_value(mod["file_name"], "skin", "Default")
	var skin_path = "res://modules/" + mod["file_name"] + "/skins/" + skin_name
	skin = SkinManager.get_from_path(skin_path)


func _ready():
	hit_circle.texture = skin["hitcircle.png"]
	hit_circle_overlay.texture = skin["hitcircleoverlay.png"]
