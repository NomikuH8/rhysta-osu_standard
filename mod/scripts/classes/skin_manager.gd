class_name SkinManager
extends Node

static func get_from_path(path: String) -> Dictionary:
	var dir = DirAccess.open(path)
	if dir == null:
		push_error(DirAccess.get_open_error())
		return {}
	
	dir.list_dir_begin()
	
	var filename = dir.get_next()
	var skin: Dictionary = {}
	while filename != "":
		if filename.ends_with(".png"):
			var full_path: String = path + "/" + filename
			var image := Image.new()
			var err := image.load(full_path)
			
			if err == OK:
				var texture = ImageTexture.create_from_image(image)
				skin[filename] = texture
			else:
				push_error("error to load image: " + full_path + " (code: %s)" % err)
		
		filename = dir.get_next()
	
	return skin
