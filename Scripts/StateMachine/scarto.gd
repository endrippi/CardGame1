extends State

var selectedHandCards : Array[Card]
@onready var uiManager: UiManager = $"../../UiManager"
@onready var gameData: GameData = $"../../GameData"


func enter(data : GameData) -> void:
	print("Sono nello scarto")
	for card in data.carteMano:
		card.cardSelected.connect(_on_card_hand_clicked)


func discardCard(card : Card, data : GameData) -> void:
	if card:
		data.carteMano.erase(card)

		if data.selectedHandCard == card:
			data.selectedHandCard = null

		card.queue_free()

func _on_card_hand_clicked(card : Card) -> void:
	if card.selected == true:
		selectedHandCards.erase(card)
		card.selected = false
	else:
		selectedHandCards.append(card)
		card.selected = true
	card.updateCardVisual()


func _on_undo_discard_pressed() -> void:
	selectedHandCards.clear()
	transitioned.emit(self, "SelezioneCarte")


func _on_confirm_discard_pressed() -> void:
	var sz : int = selectedHandCards.size()
	for card in selectedHandCards:
		discardCard(card, gameData)

	selectedHandCards.clear()

	uiManager.enableDiscardMode(false)

	var newCards = gameData.deck.drawCard(sz, gameData.mano)

	gameData.carteMano.append_array(newCards)
	
	#handCardsUpdated.emit(gameData.carteMano)
	
	transitioned.emit(self, "SelezioneCarte")
	

func exit(data : GameData) -> void:
	for card in data.carteMano:
		if is_instance_valid(card):
			if card.cardSelected.is_connected(_on_card_hand_clicked):
				card.cardSelected.disconnect(_on_card_hand_clicked)

	selectedHandCards.clear()
