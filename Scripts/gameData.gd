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
