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

@onready var valTavolo: Label = $"../../DebugValoreTavolo"

@onready var valMano: Label = $"../../DebugValoreMano"

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
		carteMano = deck.drawCard(3, mano)
	
	# These two signals are super important to emit as soon as cards are updated in
	# some way (especially after play etc) to make sure that all signals are 
	# correctly connected between card and hand/table 
	# (like for clicking visuals)
	tableCardsUpdated.emit(carteTavolo)
	handCardsUpdated.emit(carteMano)

	# Connecting signals that handle the update of hand/table cards
	mano.valManoChanged.connect(_on_mano_valManoChanged)
	mano.selectedHandCardChanged.connect(_on_mano_selectedHandCardChanged)
	tavolo.tableChanged.connect(_on_tavolo_tableChanged)

#func update(_delta: float) -> void:
#	pass


func _on_play_button_pressed() -> void:
	if selectedHandCard != null:
		transitioned.emit(self, "Giocato")

func _on_mano_valManoChanged(val : String) -> void:
	valMano.text = val
	
func _on_mano_selectedHandCardChanged(card : Card) -> void:
	selectedHandCard = card

func _on_tavolo_tableChanged(val : String, cards: Array[Card], sum : int) -> void:
	valTavolo.text = val
	selectedTableCards = cards
	currentTableSum = sum

		
func exit(data : GameData) -> void:
	print("exiting start")
	
	# Functions to disconnect the signals emitted from the cards to the 
	# observers in hand/table
	mano.cleanupAfterStateExit()
	tavolo.cleanupAfterStateExit()
	
	data.mano = mano
	data.tavolo = tavolo
	data.deck = deck
	data.carteMano = carteMano
	data.carteTavolo = carteTavolo
	data.selectedHandCard = selectedHandCard
	data.selectedTableCards = selectedTableCards
	data.currentTableSum = currentTableSum
