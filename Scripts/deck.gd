extends Node2D

@export var carte : Array[Resource]
@export var cardScene : PackedScene
@export var hand : Node2D
var i : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	carte.shuffle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func drawCard() -> void:
	if carte.is_empty():
		print("Vuoto!")
		return
	
	var data : Resource = carte.pop_back()
	var card : Card = cardScene.instantiate()
	
	card.value = data.value
	card.suit = data.suit 
	card.cardTexture = data.cardTexture
	card.z_index = i
	
	card.global_position.x = randf_range(-50, 50)
	card.global_position.y = randf_range(-50, 50)
	
	hand.add_child(card)
	
	i += 1
	
