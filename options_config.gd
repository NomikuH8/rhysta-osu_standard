var options_config: Dictionary = {
	"skin": {
		"default_value": "Default",
		"type": Options.OptionType.DROPDOWN,
		"dropdown_values": {
			"Default": "Default",
		},
	},
}

func _init() -> void:
	var mod = ModManager.loaded_mods.filter(func(m): return m["file_name"] == "osu_standard")[0]
	var skins_path = "res://modules/" + mod["file_name"] + "/skins"
	
	var dir = DirAccess.open(skins_path)
	dir.list_dir_begin()
	var skin = dir.get_next()
	
	while skin != "":
		if not dir.current_is_dir():
			skin = dir.get_next()
			continue
		
		options_config["skin"]["dropdown_values"][skin] = skin
		skin = dir.get_next()
