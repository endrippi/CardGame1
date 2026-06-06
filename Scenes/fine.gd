extends State

@onready var gameData: GameData = $"../../GameData"
@onready var uiManager: UiManager = $"../../UiManager"
@onready var hai_vinto_label: RichTextLabel = $"../../haiVintoLabel"

var canReturn : bool = false
var hasWon :bool = false

func enter(data : GameData, previousState : State) -> void:
	print("Ecco la fine!")
	data.carteRimaste -= 1
	if data.carteRimaste <= 0:
		data.maniDisponibili -= 1
		data.carteRimaste = 3
		
		# FANOUT FIX?
		data.previousHandContents = data.carteMano.duplicate()
	
		data.carteMano = data.deck.drawCard(3, data.mano)
		print("Non ci sono più carte in mano")
		gameData.handCardsWereAlreadyRefilled = true 
	else: 
		print("Ci sono ancora carte in mano")
		gameData.handCardsWereAlreadyRefilled = false 
	if data.totalPoints >= data.targetPunti:
		hasWon = true
		HighScore.save_highscore(data.totalPoints)
		win()
		
	if data.maniDisponibili <= 0 and data.totalPoints < data.targetPunti:
		lose()
	canReturn = true


func update(_delta: float) -> void:
	if canReturn:
		transitioned.emit(self, "SelezioneCarte")
	if hasWon:
		win()

func win() -> void:
	transitioned.emit(self, "Vittoria")

func lose() -> void:
	transitioned.emit(self, "Sconfitta")
