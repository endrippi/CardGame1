extends Marker2D

var carteArray
@onready var selectionState = $"../StateMachine/SelezioneCarte"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selectionState.tableCardsUpdated.connect(_on_tableCardsUpdated)
	pass
	
# Position cards on the table.
func positionCards() -> void:
	var i = 1
	var offset_x : int = 130
	
	for card in carteArray:
		print(card)
		# Position the card with offset
		card.position.x = card.position.x + i * offset_x
		card.z_index = i
		# Add it as children to the table
		self.add_child(card)
		i += 1
	#print('figli del tavolo: ', self.get_child_count())

# On signal _on_tableCardsUpdated, updates current cards in table and later updates visuals.
func _on_tableCardsUpdated(cards : Array[Card]) -> void:
	carteArray = cards 
	for card in carteArray:
		card.inHand = false
	#print("carteArrray da tavolo dopo segnale: ", carteArray)
	positionCards()
