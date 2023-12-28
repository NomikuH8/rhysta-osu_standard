extends Control


@export var back_scene: PackedScene
@export var diff_scene: PackedScene


func _ready():
	spawn_songs()


func spawn_songs():
	var mod = ModManager.loaded_mods.filter(func(m): return m["file_name"] == "osu_standard")[0]
	var mod_path = "res://modules/" + mod["file_name"]
	var mod_song_path = mod_path + "/songs"
	
	var _BeatmapParserScript = load(mod_path + "/mod/scripts/classes/beatmap_parser.gd")
	
	var dir = DirAccess.open(mod_song_path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():  
			file_name = dir.get_next()
			continue
		
		var new_dir = DirAccess.open(mod_song_path + "/" + file_name)
		new_dir.list_dir_begin()
		var new_file_name = new_dir.get_next()
		while new_file_name != "":
			if new_dir.current_is_dir():
				new_file_name = new_dir.get_next()
				continue
			
			if new_file_name.ends_with(".osu"):
				var path = mod_song_path + "/" + file_name + "/" + new_file_name
				var globalized_path = ProjectSettings.globalize_path(path)
				var file_access = FileAccess.open(globalized_path, FileAccess.READ)
				var text = file_access.get_as_text()
				
				var diff = diff_scene.instantiate()
				diff.infos = BeatmapParser.parse(text)
				diff.path = mod_song_path + "/" + file_name
				%SongsContainer.add_child(diff)
			
			new_file_name = new_dir.get_next()
		
		file_name = dir.get_next()


func reload_song_name_label(song_name: String):
	%SongNameLabel.text = song_name


func reload_diff_image(image_path: String):
	var image = Image.load_from_file(image_path)
	var texture = ImageTexture.create_from_image(image)
	%DiffImage.texture = texture


func _on_back_button_pressed():
	get_tree().change_scene_to_packed(back_scene)
