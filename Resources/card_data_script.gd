#extends Node

@export_range(1, 10) var value : int = 1
@export_enum("Bastoni", "Coppe", "Denari", "Spade") var suit : String = "Denari"
@export var cardTexture : Texture
