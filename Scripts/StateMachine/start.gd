extends State

@export var mano : Marker2D
@export var tavolo : Marker2D
@export var deck : Deck

@onready var carteMano : Array[Card]
@onready var carteTavolo : Array[Card]

var selectedHandCard : Card
var selectedTableCards: Array[Card]
var currentTableSum : int = 0

signal tableCardsUpdated(cards : Array[Card])
signal handCardsUpdated(cards : Array[Card])


# Called when the node enters the scene tree for the first time.
func enter(data : GameData) -> void:
	print("ciao sono nello stato iniziale")
	mano = data.mano
	tavolo = data.tavolo
	deck = data.deck
	carteMano = data.carteMano
	carteTavolo = data.carteTavolo
	selectedHandCard = data.selectedHandCard
	selectedTableCards = data.selectedTableCards
	currentTableSum = data.currentTableSum
	
	if carteTavolo.is_empty():
		carteTavolo = deck.drawCard(4, tavolo)
	if carteMano.is_empty():
		carteMano = deck.drawCard(5, mano)
	
	tableCardsUpdated.emit(carteTavolo)
	handCardsUpdated.emit(carteMano)
	
	for carta in carteMano:
		carta.cardSelected.connect(_on_card_hand_clicked)
	for carta in carteTavolo:
		carta.cardSelected.connect(_on_card_table_clicked)
	

#func update(_delta: float) -> void:
#	pass


func _on_play_button_pressed() -> void:
	transitioned.emit(self, "Giocato")

func _on_card_table_clicked(card : Card):
	if card.selected == true:
		selectedTableCards.erase(card)
		card.selected = false
		currentTableSum -= card.value
	else:
		selectedTableCards.append(card)
		card.selected = true
		currentTableSum += card.value
	card.updateCardVisual()
	print("Array di size ", selectedTableCards.size(), " con somma: ", currentTableSum)
	#updateTableVisuals()


func _on_card_hand_clicked(card : Card) -> void:
	if selectedHandCard == card:
		card.selected = false
		selectedHandCard = null
		print("Deselezionata")
	else:
		if selectedHandCard != null:
			selectedHandCard.selected = false
			selectedHandCard = card
			print("Clickata ", selectedHandCard.value, " di papapapa (cambiando da carta)")
		else:
			selectedHandCard = card
			print("Clickata ", selectedHandCard.value, " di papapapa")
		selectedHandCard.selected = true
	updateHandVisuals()


func updateHandVisuals() -> void:
	for carta in carteMano:
		carta.updateCardVisual()
		
func updateTableVisuals() -> void:
	for carta in carteTavolo:
		carta.updateCardVisual()
		
		
func exit(data : GameData) -> void:
	for carta in carteTavolo:
		if carta.cardSelected.is_connected(_on_card_table_clicked):
			carta.cardSelected.disconnect(_on_card_table_clicked)
		carta.selected = false
	for carta in carteMano:
		if carta.cardSelected.is_connected(_on_card_hand_clicked):
			carta.cardSelected.disconnect(_on_card_hand_clicked)
		carta.selected = false
	updateHandVisuals()
	updateTableVisuals()
	
	data.mano = mano
	data.tavolo = tavolo
	data.deck = deck
	data.carteMano = carteMano
	data.carteTavolo = carteTavolo
	data.selectedHandCard = selectedHandCard
	data.selectedTableCards = selectedTableCards
	data.currentTableSum = currentTableSum
