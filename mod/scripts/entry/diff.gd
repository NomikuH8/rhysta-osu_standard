extends Control


var infos: Dictionary = {}


func _ready():
	print(infos)
	%SongTitleLabel.text = infos["Metadata"]["TitleUnicode"]
	%DiffNameLabel.text = infos["Metadata"]["Version"]
