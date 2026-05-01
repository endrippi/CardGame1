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

# Audio players.
@onready var hoveringSound : AudioStreamPlayer = $HoveringSound
@onready var clickingSound : AudioStreamPlayer = $ClickingSound

# For click managament.
@onready var clickableArea2D : Area2D = $Area2DClickable
@onready var clickableCollisionShape : CollisionShape2D = $Area2DClickable/CollisionShape2DClickable

# Animations!
var tweenHover : Tween
var tweenRaise : Tween

# To mark whether the card is on the table or in the hand 
# (needed for different processing of downscaling and on-hover behaviour)
var inHand : bool


var selected : bool = false
var offset_y : int = 35

func _ready() -> void:
	sprite.texture = cardTexture
	sprite.scale.x = 0.311 #55
	sprite.scale.y = 0.267 #80
	#print("Spawnata")
	
	
func _on_area_2d_mouse_entered() -> void:
	# Letting hand and table handle it
	cardAreaEntered.emit(self)
	#area2d.z_index += 10
	#print("Questa carta è il ", self.value, " di ", self.suit, " con z-index ", self.z_index)


func _on_area_2d_mouse_exited() -> void:
	# Letting hand and table handle it
	cardAreaExited.emit(self)
	#area2d.z_index +- 10
	
	
func _on_area_2d_clickable_card_clicked(left: bool) -> void:
	#print("Ricevuto segnale per ", value, " di ", suit)
	if left:
		print('[!] CLICCATO IL ', value, " di ", suit, " con z index: ", z_index)
		cardSelected.emit(self)
		var conns = get_signal_connection_list('cardSelected')
		#print('connections to cardSelected: ', conns)
		updateCardVisual()
		
func disableClicks() -> void:
	clickableArea2D.disableClicks()
	
func enableClicks() -> void:
	clickableArea2D.enableClicks()
	

func updateCardVisual() -> void:
	#print("updating (card) visuals")
	# if in table then we just raise them
	if !inHand:
		#print("in table")
		if not selected:
			#print("not selected")
			#position.y = 0
			# Animating going back down
			if tweenRaise and tweenRaise.is_running():
				tweenRaise.kill()
			tweenRaise = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			tweenRaise.tween_property(self, 'position', Vector2(position.x, 0),0.1)
			
			#selected = true
		elif selected:
			# Animating going up
			if tweenRaise and tweenRaise.is_running():
				tweenRaise.kill()
			tweenRaise = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			tweenRaise.tween_property(self, 'position', Vector2(position.x, position.y-offset_y),0.1)
			#position.y -= offset_y
		playClickingSound()
			#selected = false
	# if in hand then we raise them but depending on their current radius (done by mano.gd)
	else:
		#print("in hand")
		#print("This is card ", value, " which has been clicked.")
		if not selected:
			print("not selected and in hand, lowering ", value, ' of ', suit)
			cardInHandToLower.emit(self)
		elif selected:
			#print("selected")
			print("selected and in hand, raising ", value, ' of ', suit)
			cardInHandToRaise.emit(self)
		
		
func upscaleCard() -> void:
	#print('upscaling')
	if tweenHover and tweenHover.is_running():
		tweenHover.kill()
	# Transition elastic makes the "bouncing" effect, otherwise it just "grows" to the desired size linearly
	# Ease out looks more like in Balatro
	tweenHover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	var upscaleValue : float = 0.2
	if inHand:
		upscaleValue += 0.05
	tweenHover.tween_property(self, "scale", Vector2(scale.x + upscaleValue, scale.y + upscaleValue), 0.5)
	#scale.x += 0.10
	#scale.y += 0.10
	playHoveringSound()

# Different downscaling, depends on whether the card is in hand or on the table.
func downscaleCard() -> void:
	if tweenHover and tweenHover.is_running():
		tweenHover.kill()
	tweenHover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	if inHand:
		tweenHover.tween_property(self, "scale", Vector2(3, 3), 0.5)
	else:
		tweenHover.tween_property(self, "scale", Vector2(2, 2), 0.5)
	
	"""
	if inHand:
		scale = Vector2(3, 3)
	else:
		scale = Vector2(2, 2)
	"""

# Function to animate card in hand being selected.
func selectCardInHand(radius : float, radius_offset : float) -> void:
	if tweenRaise and tweenRaise.is_running():
		tweenRaise.kill()
	tweenRaise = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tweenRaise.tween_property(self,'position', Vector2(0, -(radius + offset_y + radius_offset)), 0.1)

# Function to animate card in hand being de-selected.	
func deselectCardInHand(radius : float) -> void:
	if tweenRaise and tweenRaise.is_running():
		tweenRaise.kill()
	tweenRaise = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tweenRaise.tween_property(self,'position', Vector2(0, -radius), 0.1)
	
		
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
