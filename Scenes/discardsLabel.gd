extends RichTextLabel

@onready var gameData: GameData = $"../GameData"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = str("[wave]Discards: ", gameData.scartiDisponibili,"[/wave]")
