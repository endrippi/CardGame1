class_name Card extends Node2D

@export_range(1, 10) var value : int = 1
@export_enum("Bastoni", "Coppe", "Denari", "Spade") var suit : String = "Denari"
@export var cardTexture : Texture
@onready var sprite : Sprite2D = $Sprite2D


func _ready() -> void:
	sprite.texture = cardTexture
	sprite.scale.x = 0.311
	sprite.scale.y = 0.267
	print("Spawnata")
	
	
func _on_area_2d_mouse_entered() -> void:
	scale.x += 0.10
	scale.y += 0.10
	


func _on_area_2d_mouse_exited() -> void:
	scale.x -= 0.10
	scale.y -= 0.10


func _on_area_2d_card_clicked(left: bool) -> void:
	if left:
		print(value, " di ", suit, "con z index: ", z_index)
