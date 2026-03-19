class_name Main
extends Node2D

@export var mano : Marker2D
@export var tavolo : Marker2D
@export var deck : Deck



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_button_pressed() -> void:
	deck.drawCard(4, tavolo)
	deck.drawCard(3, mano)
