extends State

@onready var numLabel: Label = $"../../SegnaPunti/num"
var shouldGoBack : bool = false

# Called when the node enters the scene tree for the first time.
func enter(data : GameData) -> void:
	print("ciao sono nello stato Giocato") # Replace with function body.
	print("Mano di ", data.selectedHandCard.value, " con somma di tavolo di ", data.currentTableSum)
	if data.selectedHandCard.value == data.currentTableSum: #Fatto bene
		data.totalPoints += data.selectedHandCard.value + data.currentTableSum
		numLabel.text = str(data.totalPoints)
		print("Ciaooo")
		shouldGoBack = false
	else:
		shouldGoBack = true
		data.currentTableSum = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	if shouldGoBack:
		transitioned.emit(self, "selezionecarte")


func exit(data : GameData) -> void:
	pass
