extends State

@export var mano : Marker2D
@export var tavolo : Marker2D
@export var deck : Deck

@onready var carteMano : Array[Card]
@onready var carteTavolo : Array[Card]

@onready var currentCard : Card

var selectedHandCard : Card
var selectedTableCards: Array[Card]
var currentTableSum : int = 0


# Called when the node enters the scene tree for the first time.
func enter() -> void:
	carteTavolo = deck.drawCard(4, tavolo)
	carteMano = deck.drawCard(3, mano)
	for carta in carteMano:
		carta.cardSelected.connect(_on_card_hand_clicked)
	for carta in carteTavolo:
		carta.cardSelected.connect(_on_card_table_clicked)

func update(_delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	pass

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
