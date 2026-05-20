extends State

@export var mano : Marker2D
@export var tavolo : Marker2D
@export var deck : Deck
@onready var uiManager: UiManager = $"../../UiManager"

@onready var carteMano : Array[Card]
@onready var carteTavolo : Array[Card]
@onready var gameData: GameData = $"../../GameData"


var selectedHandCard : Card
var selectedTableCards: Array[Card]
var currentTableSum : int = 0

signal tableCardsUpdated(cards : Array[Card])
signal handCardsUpdated(cards : Array[Card])

@onready var valTavolo: Label = $"../../DebugValoreTavolo"
@onready var discard: Button = %discard
@onready var valMano: Label = $"../../DebugValoreMano"

var canDiscard : bool = true
var handEmpty : bool = false

# Called when the node enters the scene tree for the first time.
func enter(data : GameData) -> void:
	print("ciao sono nello stato iniziale")
	if data.mano:
		mano = data.mano
	if data.tavolo:
		tavolo = data.tavolo
	deck = data.deck
	carteMano = data.carteMano
	carteTavolo = data.carteTavolo
	selectedHandCard = data.selectedHandCard
	selectedTableCards = data.selectedTableCards
	currentTableSum = data.currentTableSum
	
	if carteTavolo.is_empty() and !data.partitaIniziata:
		carteTavolo = gameData.deck.drawCard(4, data.tavolo)
		data.partitaIniziata = true
	if carteMano.is_empty():
		carteMano = gameData.deck.drawCard(3, data.mano)

	updateGameData(gameData)
	gameData.carteMano = carteMano
	
	tableCardsUpdated.emit(carteTavolo)
	handCardsUpdated.emit.call_deferred(carteMano)
	
	for carta in carteMano:
		carta.cardSelected.connect(_on_card_hand_clicked)
	for carta in carteTavolo:
		carta.cardSelected.connect(_on_card_table_clicked)
	



func _on_play_button_pressed() -> void:
	if selectedHandCard != null:
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
	
	valTavolo.text = str(currentTableSum)


func _on_card_hand_clicked(card : Card) -> void:
	if selectedHandCard == card:
		card.selected = false
		selectedHandCard = null
		print("Deselezionata")
		valMano.text = "0"
	else:
		if selectedHandCard != null:
			selectedHandCard.selected = false
			selectedHandCard = card
			print("Clickata ", selectedHandCard.value, " di papapapa (cambiando da carta)")
			valMano.text = str(selectedHandCard.value)
		else:
			selectedHandCard = card
			print("Clickata ", selectedHandCard.value, " di papapapa")
			valMano.text = str(selectedHandCard.value)
		selectedHandCard.selected = true
	uiManager.updateHandVisuals()
	
func updateGameData(data : GameData) -> void:
	data.mano = mano
	data.tavolo = tavolo
	data.deck = deck
	data.carteMano = carteMano
	data.carteTavolo = carteTavolo
	data.selectedHandCard = selectedHandCard
	data.selectedTableCards = selectedTableCards
	data.currentTableSum = currentTableSum



func exit(data : GameData) -> void:
	for carta in carteTavolo:
		if carta.cardSelected.is_connected(_on_card_table_clicked):
			carta.cardSelected.disconnect(_on_card_table_clicked)
		carta.selected = false
	for carta in carteMano:
		if carta.cardSelected.is_connected(_on_card_hand_clicked):
			carta.cardSelected.disconnect(_on_card_hand_clicked)
		carta.selected = false
	uiManager.updateHandVisuals()
	uiManager.updateTableVisuals()
	updateGameData(gameData)
	


func _on_discard_pressed() -> void:
	transitioned.emit(self, "Scarto")




func placeCardOnTable(card : Card) -> void:

	gameData.carteMano.erase(card)
	gameData.carteTavolo.append(card)

	card.selected = false
	card.inHand = false

	card.scale = Vector2(2,2)

	card.rotation = 0

	gameData.selectedHandCard = null
	selectedHandCard = null
	card.cardSelected.disconnect(_on_card_hand_clicked)
	card.cardSelected.connect(_on_card_table_clicked)
	
	# Rimuove dal pivot della mano
	if card.get_parent():
		card.get_parent().remove_child(card)
	
	gameData.carteRimaste -= 1
	if gameData.carteRimaste <= 0:
		refreshHand()
		gameData.carteRimaste = 3
	
	print("Ecco l'array prima della chiamata al segnale ", gameData.carteTavolo)
	# Aggiorna layout
	tableCardsUpdated.emit(gameData.carteTavolo)
	handCardsUpdated.emit(gameData.carteMano)
	uiManager.updateTableVisuals()
	uiManager.updateHandVisuals()


func _on_place_on_table_button_pressed() -> void:
	if selectedHandCard:
		placeCardOnTable(selectedHandCard)
		

func refreshHand() -> void:
	# Scala le mani disponibili (se le regole del tuo gioco lo prevedono)
	gameData.maniDisponibili -= 1
	
	# Se le mani sono finite, potresti voler gestire la fine della partita qui
	if gameData.maniDisponibili <= 0:
		transitioned.emit(self, "Sconfitta") # O lo stato di game over appropriato
		return

	# 1. Pesca e salva le nuove carte
	var nuoveCarte = gameData.deck.drawCard(3, gameData.mano)
	gameData.carteMano.append_array(nuoveCarte)
	carteMano = gameData.carteMano
	
	# 2. Connetti i segnali
	for carta in nuoveCarte:
		if not carta.cardSelected.is_connected(_on_card_hand_clicked):
			carta.cardSelected.connect(_on_card_hand_clicked)
	
	# 3. Notifica la Ui
	handCardsUpdated.emit.call_deferred(gameData.carteMano)
