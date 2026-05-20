extends State

@onready var gameData: GameData = $"../../GameData"
@onready var uiManager: UiManager = $"../../UiManager"

var canReturn : bool = false
var hasWon :bool = false

func enter(data : GameData) -> void:
	print("Ecco la fine!")
	data.carteRimaste -=1
	if data.carteRimaste <= 0:
		data.maniDisponibili -= 1
		data.carteRimaste = 3
		data.carteMano = data.deck.drawCard(3, data.mano)
	if data.totalPoints >= data.targetPunti:
		hasWon = true
		win()
		
	if data.maniDisponibili == 0:
		lose()
	canReturn = true


func update(_delta: float) -> void:
	if canReturn:
		transitioned.emit(self, "SelezioneCarte")

func win() -> void:
	pass

func lose() -> void:
	pass
