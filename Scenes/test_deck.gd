extends Node2D
@onready var deck: Node2D = $Deck


# Called when the node enters the scene tree for the first time.


func _on_button_pressed() -> void:
	print("Premuto!")
	deck.drawCard()
