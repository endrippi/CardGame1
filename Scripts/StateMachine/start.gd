extends State

@export var mano : Marker2D
@export var tavolo : Marker2D
@export var deck : Deck



# Called when the node enters the scene tree for the first time.
func enter() -> void:
	deck.drawCard(4, tavolo)
	deck.drawCard(3, mano)
