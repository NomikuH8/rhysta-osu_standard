extends Control


var infos: Dictionary = {}


func _ready():
	%SongTitleLabel.text = infos["Metadata"]["TitleUnicode"]
	%DiffNameLabel.text = infos["Metadata"]["Version"]


func _on_play_button_pressed():
	var mod = ModManager.loaded_mods.filter(func(m): return m["file_name"] == "osu_standard")[0]
	var mod_path = "res://modules/" + mod["file_name"]
	var scene_path = mod_path + "/scenes/gameplay/gameplay.tscn"
	
	SceneChanger.goto_scene(scene_path, { "diff": infos })
