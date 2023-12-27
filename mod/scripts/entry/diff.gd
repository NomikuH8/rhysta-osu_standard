extends Control


var infos: ConfigFile


func _ready():
	%SongTitleLabel.text = infos.get_value("Metadata", "TitleUnicode", "Song title")
