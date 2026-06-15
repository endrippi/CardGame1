class_name Card extends Node2D

@onready var shadow: ColorRect = $Shadow
@export var shader_smoothing: float = 12.0
@export_range(1, 10) var value : int = 1
@export_enum("Bastoni", "Coppe", "Denari", "Spade") var suit : String = "Denari"
@export var cardTexture : Texture
@onready var sprite : Sprite2D = $Sprite2D
signal cardSelected(card : Card)

@onready var area2d : Area2D = $Area2D
# Massima rotazione (se il tuo shader accetta gradi, es. 25.0. Se accetta radianti usa es. 0.4)
@export var shader_max_rotation: float = 25.0

var current_x_rot: float = 0.0
var current_y_rot: float = 0.0

signal cardAreaEntered(card : Card)
signal cardAreaExited(card : Card)

signal cardInHandToRaise(card : Card)
signal cardInHandToLower(card : Card)

# Audio players.
@onready var hoveringSound : AudioStreamPlayer = $HoveringSound
@onready var clickingSound : AudioStreamPlayer = $ClickingSound

# For click managament.
@onready var clickableArea2D : Area2D = $ClickableArea2D
@onready var clickableCollisionShape : CollisionShape2D = $ClickableArea2D/CollisionShape2DClickable

# Animations!
var tweenHover : Tween
var tweenRaise : Tween
@export var baseHandCardScale = Vector2(2.50,2.50)
@export var hoveredHandCardScale = Vector2(2.75,2.75)
@export var baseTableCardScale = Vector2(1.75,1.75)
@export var hoveredTableCardScale = Vector2(2,2)

# Visual aids with shaders
var highlightShader = preload("res://Shaders/cardSelectable.gdshader")
var highlightShader2 = preload("res://Shaders/cardSelectable2.gdshader")
var messyOutlineShader = preload("res://Shaders/outline.gdshader")

# To mark whether the card is on the table or in the hand 
# (needed for different processing of downscaling and on-hover behaviour)
var inHand : bool

var selected : bool = false
var offset_y : int = 35

var isMouseOnCard : bool = false


func _ready() -> void:
	sprite.texture = cardTexture
	#sprite.scale.x = 0.311 #55
	#sprite.scale.y = 0.267 #80
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
	isMouseOnCard = true

func _on_area_2d_mouse_exited() -> void:
	#scale.x -= 0.10
	#scale.y -= 0.10
	if inHand:
		cardAreaExited.emit(self)
	else:
		downscaleCard()
	#area2d.z_index +- 10
	isMouseOnCard = false

func updateCardVisual() -> void:
	#print("updating (card) visuals")
	# if in table then we just raise them
	if !inHand:
		#print("in table")
		if not selected:
			deselectCardOnTable()
			#print("not selected")
			#position.y = 0
			# Animating going back down
			#cardLower()
			#selected = true
		elif selected:
			# Animating going up
			selectCardOnTable()
			#position.y -= offset_y
		playClickingSound()
			#selected = false
	# if in hand then we raise them but depending on their current radius (done by mano.gd)
	else:
		#print("in hand")
		#print("This is card ", value, " which has been clicked.")
		if not selected:
			#print("not selected and in hand, lowering ", value, ' of ', suit)
			cardInHandToLower.emit(self)
		elif selected:
			#print("selected")
			#print("selected and in hand, raising ", value, ' of ', suit)
			cardInHandToRaise.emit(self)
		
		
func upscaleCard() -> void:
	#print('upscaling')
	if tweenHover and tweenHover.is_running():
		tweenHover.kill()
	# Transition elastic makes the "bouncing" effect, otherwise it just "grows" to the desired size linearly
	# Ease out looks more like in Balatro
	tweenHover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	if inHand:
		tweenHover.tween_property(self, "scale", hoveredHandCardScale, 0.4)
	else:
		tweenHover.tween_property(self, "scale", hoveredTableCardScale, 0.4)
	#scale.x += 0.10
	#scale.y += 0.10
	
	playHoveringSound()

# Different downscaling, depends on whether the card is in hand or on the table.
func downscaleCard() -> void:
	if tweenHover and tweenHover.is_running():
		tweenHover.kill()
	tweenHover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	if inHand:
		tweenHover.tween_property(self, "scale", baseHandCardScale, 0.4)
	else:
		tweenHover.tween_property(self, "scale", baseTableCardScale, 0.4)
	
	"""
	if inHand:
		scale = Vector2(3, 3)
	else:
		scale = Vector2(2, 2)
	"""

# Function to animate card in hand being selected.
func selectCardInHand(radius : float, radius_offset : float) -> void:
	print("Selezionata carta in mano ", value, " di ", suit)
	if tweenRaise and tweenRaise.is_running():
		tweenRaise.kill()
	tweenRaise = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tweenRaise.tween_property(self,'position', Vector2(0, -(radius + offset_y + radius_offset)), 0.1)

# Function to animate card in hand being de-selected.	
func deselectCardInHand(radius : float) -> void:
	print("Deselezionata carta in mano ", value, " di ", suit)
	if tweenRaise and tweenRaise.is_running():
		tweenRaise.kill()
	tweenRaise = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tweenRaise.tween_property(self,'position', Vector2(0, -radius), 0.1)

func deselectCardOnTable() -> void:
	if tweenRaise and tweenRaise.is_running():
		tweenRaise.kill()
	tweenRaise = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tweenRaise.tween_property(self, 'position', Vector2(position.x, -30),0.1)

func selectCardOnTable() -> void:
	if tweenRaise and tweenRaise.is_running():
		tweenRaise.kill()
	tweenRaise = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tweenRaise.tween_property(self, 'position', Vector2(position.x, -65),0.1)	
	
func disableClicks() -> void:
	clickableArea2D.disableClicks()
	
func enableClicks() -> void:
	clickableArea2D.enableClicks()

func _on_clickable_area_2d_card_clicked(left: bool) -> void:
	if left:
		#print(value, " di ", suit, " con z index: ", z_index)
		cardSelected.emit(self)
		updateCardVisual()

# Activate outline shader that marks card as selectable.
func activateShader() -> void:
	var material = ShaderMaterial.new()
	
	material.shader = messyOutlineShader
	material.set_shader_parameter('color', Color('ff00fff4'))
	material.set_shader_parameter('speed', 4.0)
	
	$Sprite2D.material = material

# Deactivate outline shader that marks card as not selectable.
func deactivateShader() -> void:
	sprite.material = null

# Play hovering sound picking at random from the two available ones.
# Also randomly changes the pitch.
func playHoveringSound():
	var audioPicker = randi()
	if audioPicker % 2 == 0:
		hoveringSound.stream = load("res://Assets/Sound/Effects/tic_carta_1.mp3")
	else: 
		hoveringSound.stream = load("res://Assets/Sound/Effects/tic_carta_2.mp3")
	hoveringSound.pitch_scale = randf_range(1.2,1.5)
	hoveringSound.volume_db = -12
	hoveringSound.play()
	
# Play clicking sound picking at random from the three available ones.
# Also randomly changes the pitch (not anymore).
func playClickingSound():
	#print("clickingsound")
	var audioPicker = randi()
	if audioPicker % 2 == 0:
		clickingSound.stream = load("res://Assets/Sound/Effects/tic_carta_1.mp3")
	else: 
		clickingSound.stream = load("res://Assets/Sound/Effects/tic_carta_2.mp3")
	clickingSound.pitch_scale = randf_range(0.8,1.2)
	clickingSound.volume_db = -5
	clickingSound.play()
	
func _printClickingState():
	var isClickable = clickableArea2D.clickable
	print("\t\t\t Is this clickable? ", isClickable)
