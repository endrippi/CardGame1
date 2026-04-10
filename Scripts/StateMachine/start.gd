extends State

@export var mano : Marker2D
@export var tavolo : Marker2D
@export var deck : Deck

@onready var carteMano : Array[Card]
@onready var carteTavolo : Array[Card]

# Called when the node enters the scene tree for the first time.
func enter() -> void:
	carteTavolo = deck.drawCard(4, tavolo)
	carteMano = deck.drawCard(3, mano)
	

func update(_delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	pass


func _on_card_selected(click : bool):
	pass
