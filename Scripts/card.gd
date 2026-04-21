class_name Card extends Node2D

@export_range(1, 10) var value : int = 1
@export_enum("Bastoni", "Coppe", "Denari", "Spade") var suit : String = "Denari"
@export var cardTexture : Texture
@onready var sprite : Sprite2D = $Sprite2D
signal cardSelected(card : Card)

@onready var area2d : Area2D = $Area2D

signal cardAreaEntered(card : Card)
signal cardAreaExited(card : Card)

signal cardInHandToRaise(card : Card)
signal cardInHandToLower(card : Card)

# To mark whether the card is on the table or in the hand 
# (needed for different processing of downscaling and on-hover behaviour)
var inHand : bool


var selected : bool = false
var offset_y : int = 35

func _ready() -> void:
	sprite.texture = cardTexture
	sprite.scale.x = 0.311 #55
	sprite.scale.y = 0.267 #80
	print("Spawnata")
	
	
func _on_area_2d_mouse_entered() -> void:
	#scale.x += 0.10
	#scale.y += 0.10
	if inHand:
		cardAreaEntered.emit(self)
	else:
		upscaleCard()
	#area2d.z_index += 10
	#print("Questa carta è il ", self.value, " di ", self.suit, " con z-index ", self.z_index)


func _on_area_2d_mouse_exited() -> void:
	#scale.x -= 0.10
	#scale.y -= 0.10
	if inHand:
		cardAreaExited.emit(self)
	else:
		downscaleCard()
	#area2d.z_index +- 10

func _on_area_2d_card_clicked(left: bool) -> void:
	if left:
		print(value, " di ", suit, " con z index: ", z_index)
		cardSelected.emit(self)
		updateCardVisual()

func updateCardVisual() -> void:
	# if in table then we just raise them
	if !inHand:
		if not selected:
			position.y = 0
			#selected = true
		elif selected:
			position.y -= offset_y
			#selected = false
	# if in hand then we raise them but depending on their current radius (done by mano.gd)
	else:
		#print("This is card ", value, " which has been clicked.")
		if not selected:
			cardInHandToLower.emit(self)
		elif selected:
			cardInHandToRaise.emit(self)
		
		
func upscaleCard() -> void:
	scale.x += 0.10
	scale.y += 0.10

# Different downscaling, depends on whether the card is in hand or on the table.
func downscaleCard() -> void:
	if inHand:
		scale = Vector2(3, 3)
	else:
		scale = Vector2(2, 2)
