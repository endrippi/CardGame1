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

var selectedHandCardHasPlayableCombinations = false
