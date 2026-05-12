extends State

@onready var gameData: GameData = $"../../GameData"
@onready var uiManager: UiManager = $"../../UiManager"

var canReturn : bool = false

func enter(data : GameData) -> void:
	data.maniDisponibili -= 1
	canReturn = true


func update(_delta: float) -> void:
	if canReturn:
		transitioned.emit(self, "SelezioneCarte")
