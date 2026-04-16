class_name Deck
extends Node2D

@export var carte : Array[Resource]
@export var cardScene : PackedScene
#@export var hand : Node2D
@onready var counterCarte : Label = $counterCarte

var i : int = 0

signal cardAdded(card : Card)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	carte.shuffle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func drawCard(num : int, spazio : Marker2D) -> Array[Card]:
	#var offset_x : int = 130
	
	var cardsDrawn : Array[Card]
	
	if carte.is_empty():
		print("Vuoto!")
		return cardsDrawn

	for i in range(0, num):
		var data : Resource = carte.pop_back()
		var card : Card = cardScene.instantiate()
	
		card.value = data.value
		card.suit = data.suit 
		card.cardTexture = data.cardTexture
		card.z_index = i
		
		cardsDrawn.append(card)
		cardAdded.emit(card)
		
		counterCarte.text = str(carte.size())+"/40"
		
	return cardsDrawn
	
