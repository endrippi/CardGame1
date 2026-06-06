class_name GameData extends Node



@export var mano : Marker2D
@export var tavolo : Marker2D
@export var deck : Deck

@onready var carteMano : Array[Card]
@onready var carteTavolo : Array[Card]

var selectedHandCard : Card
var selectedTableCards: Array[Card]
var currentTableSum : int = 0
var totalPoints: int = 0

var spazioCarteTavolo : int = 662

var manoIniziata : bool = false
var carteRimaste : int = 3

var partitaIniziata : bool = false

@export var targetPunti : int = 80
@export var maniDisponibili : int = 4
@export var scartiDisponibili: int = 3

# Mark whether the deck has been refilled by a state other than SelezioneCarte
var handCardsWereAlreadyRefilled = false
# FANOUT FIX?
# Store previous hand contents (to check which cards need to be instantiated)
var previousHandContents : Array[Card] 
# Mark whether the played cards are actually new and to play the drawing
# animation for or if it was just a wrong combination
var wasWrongCombination = false

func _ready() -> void:
	targetPunti = HighScore.load_highscore()

# Print previous hand cards
func _printPreviousHandCards():
	print("\tPREVIOUS HAND CARDS:")
	var i = 1
	for card in previousHandContents:
		print("\t\t", i, '. ', card.value, ' di ', card.suit)
		i += 1
