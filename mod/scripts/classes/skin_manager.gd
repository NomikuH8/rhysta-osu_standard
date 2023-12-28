class_name SkinManager
extends Node

static func get_from_path(path: String) -> Dictionary:
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	
	var filename = dir.get_next()
	var skin: Dictionary = {}
	while filename != "":
		if filename.ends_with(".png"):
			var image = Image.load_from_file(path + "/" + filename)
			var texture = ImageTexture.create_from_image(image)
			skin[filename] = texture
		
		filename = dir.get_next()
	
	return skin
