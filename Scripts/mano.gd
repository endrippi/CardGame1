extends Marker2D

var carteArray : Array[Card]
@onready var selectionState: Node = $"../StateMachine/SelezioneCarte"
@onready var gameData = %GameData

@export var fanAngle : float = 25
@onready var pivot : Node2D = $CardPivot
var radius := 300.0  # distance from pivot to card center

@export var currentlyHovering : Card = null
var cardsWhereMouseIsOn : Array[Card] = []

var selectedHandCard : Card

# Animation stuff
@onready var animationManager = %AnimationManager
var time : float = 0.0
var sineOffsetMult : float = 0.003		# How much to emphasize the sine curve when card still.
var cosineOffsetMult : float = 0.00002
@export var timeMultiplier : float = 2.0
var tween : Tween
var tweenForDrawing : Tween
@export var drawingSpeed : float = 0.4


func _process(delta):
	time = animationManager.animateCardRow(true, delta, time, sineOffsetMult, cosineOffsetMult, timeMultiplier)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selectionState.handCardsUpdated.connect(_on_handCardsUpdated)
	#selectionState.handCardsDrawn.connect(_on_handCardsDrawn)
		
# Function to get an array of angles for all the cards in hand
# (so they are evenly spaced automatically).
func getRotationAngles(count: int, angle: float) -> Array:
	# Safety net
	if count <= 0:
		return []
	# If only one value, it's just 0
	if count == 1:
		return [0.0]
	# We start by calculating the starting value (leftmost)
	# go all the way to the left and half it
	# (like for angle 5 and 3 cards go to -10 and then it becomes -5)
	var start = -angle * float(count - 1) / 2.0
	var step = angle
	var result = []
	# Fill the array with values, stepping of angle
	for i in range(count):
		result.append(start + step * i)
	return result
	
# Function to automatically adjust fan angle if there are more than 3 cards in hand.
func adjustFanAngle(count : int, angle : float) -> float:
	# Normally with 3 cards it covers 50 degrees, I want to evenly distribute that
	return angle/count

# FANOUT FIX?
func fanoutCardsRedone() -> void:
	var N = carteArray.size()
	var angles
	
	if N > 3:
		angles = getRotationAngles(N, adjustFanAngle(N, fanAngle*2.5))
	else:
		angles = getRotationAngles(N, fanAngle)
	
	# Now check whether the card we are fanning out was already in the hand 
	# previously or if it has just been drawn
	var i = 0
	
	var cardsToDraw = []
	var indexToStartFromForDrawing = 0
	
	_printHandCards()
	#gamdrawingTweeneData._printPreviousHandCards()
	
	if tween and tween.is_running():
		print("Killing tween")
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	for card in carteArray:
		print("Current card is ", card.value, ' di ', card.suit)
		# If the card is new, we will instantiate it and animate the drawing
		if card not in gameData.previousHandContents:
			print("It is not in previous cards")
			cardsToDraw.append(card)		
		# If the card was already there we just reposition it
		else:
			print("It is in previous cards")
			print('It will have rotation degrees ', angles[i])
			var currPivot = card.get_parent()
			
			tween.parallel().tween_property(currPivot, "rotation_degrees", angles[i], 0.3)
			indexToStartFromForDrawing += 1
		i += 1	
	
	i = 0
	
	#if tweenForDrawing and tweenForDrawing.is_running():
	#	print("Killing tween here")
	#	tweenForDrawing.kill()
	var drawingTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	for card in cardsToDraw:
		print("Card to draw is ", card.value, ' di ', card.suit)
		var currPivot = pivot.duplicate()
		# Instantiate the pivot and the actual card
		self.add_child(currPivot)
		currPivot.add_child(card)
		
		var startingPosition = Vector2(-550,-400)
		card.position = startingPosition
		var finalPosition = Vector2(0, -radius)  # Placed on pivot's radius
		
		print("It will go from ", startingPosition, ' to ', finalPosition, ' with rotation degrees ', angles[indexToStartFromForDrawing])
		
		drawingTween.parallel().tween_property(card, "position", finalPosition, drawingSpeed + (i * 0.075))
		drawingTween.parallel().tween_property(currPivot, "rotation_degrees", angles[indexToStartFromForDrawing], drawingSpeed + (i * 0.075))
		drawingTween.parallel().tween_property(card, "scale", card.baseHandCardScale, drawingSpeed + (i * 0.075))
		
		indexToStartFromForDrawing += 1
		i += 1


# Fan out cards in hand.
# BUG se scarti solo le prime due su tre in mano, va in justDrawn ma 
# dovrebbe essere gestito diversamente tra carte rimaste e non
func fanoutCards(justDrawn : bool) -> void:
	print('Fanout cards, justDrawn = ', justDrawn)
	_printHandCards()
	var N = carteArray.size()
	var angles
	# TODO Get correct fan angle according to number of cards in hand
	if N > 3:
		angles = getRotationAngles(N, adjustFanAngle(N, fanAngle*2.5))
	else:
		angles = getRotationAngles(N, fanAngle)
		
	print('angoli: ', angles)
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	if justDrawn:
		print("QUI PARTE 1")
		for i in range(N):
			var currPivot = pivot.duplicate()
			currPivot.add_child(carteArray[i])
			
			var startingPosition = Vector2(-550,-400)
			carteArray[i].position = startingPosition
			#carteArray[i].scale = Vector2(3, 3)
			var finalPosition = Vector2(0, -radius)  # Placed on pivot's radius
			
			tween.parallel().tween_property(carteArray[i], "position", finalPosition, drawingSpeed + (i * 0.075))
			tween.parallel().tween_property(currPivot, "rotation_degrees", angles[i], drawingSpeed + (i * 0.075))
			tween.parallel().tween_property(carteArray[i], "scale", carteArray[i].baseHandCardScale, drawingSpeed + (i * 0.075))
			#currPivot.rotation_degrees = angles[i]
			
			# Instantiate the pivot and the actual card
			self.add_child(currPivot)
	else:
		print("QUI PARTE 2")
		# Cards are already instantiated, we just need to change pivot rotation
		for i in range(N):
			var currPivot = carteArray[i].get_parent()
			#print("This card's (", carteArray[i].value, ' di ', carteArray[i].suit ,") parent is ", currPivot)
			tween.parallel().tween_property(currPivot, "rotation_degrees", angles[i], 0.3)
			#currPivot.rotation_degrees = angles[i]
	
func _on_handCardsUpdated(cards : Array[Card]) -> void:
	print("ON HANDCARDSUPDATED -> Segnale ricevuto")
	#print("On hand cards UPDATED")
	carteArray = cards
	#_printHandCards()
	for card in carteArray:
		card.cardAreaEntered.connect(_on_cardAreaEntered)
		card.cardAreaExited.connect(_on_cardAreaExited)
		card.cardInHandToRaise.connect(_on_cardInHandToRaise)
		card.cardInHandToLower.connect(_on_cardInHandToLower)
		card.inHand = true
	#fanoutCards(false)
	fanoutCardsRedone()
	
# We don't want to receive interrupts to hover card IF: we have not exited the area of 
# the currently hovered card AND we have not entered the area of the NEXT card in hand.
# Cards have increasing z-indexes so I can use those to see who comes first in hand.
func _on_cardAreaEntered(card : Card):
	var needClickableChange = false
	cardsWhereMouseIsOn.append(card)
	# If I am not hovering anything yet, I animate the card directly
	if currentlyHovering == null:
		card.upscaleCard()
		# Update the card I am hovering to point to this one
		currentlyHovering = card
		needClickableChange = true
	# If I am already hovering on a card I must control if I can move the hover
	else:
		# If the card to which I am moving comes later then I switch
		if card.z_index >= currentlyHovering.z_index:
			currentlyHovering.downscaleCard()
			card.upscaleCard()
			currentlyHovering = card
			needClickableChange = true
	if needClickableChange:
		updateClickableCards()
	
# If there is potentially another card to switch to, I switch and hover on it.
func _on_cardAreaExited(card : Card):
	# If there is nothing to switch to and I am still hovering the card
	# (bc maybe I have already switched)
	# then I update the card and that's it
	var needClickableChange = false
	cardsWhereMouseIsOn.erase(card)
	if cardsWhereMouseIsOn.is_empty():
		card.downscaleCard()
		currentlyHovering = null
	# If there is a card to switch to, I switch to that one.
	else:
		# We want to switch to the card which is rightmost, so we sort it by z_index
		card.downscaleCard()
		cardsWhereMouseIsOn.sort_custom(_sort_by_z_index)
			
		if cardsWhereMouseIsOn[0] != currentlyHovering:
			cardsWhereMouseIsOn[0].upscaleCard()
		currentlyHovering = cardsWhereMouseIsOn[0]
		needClickableChange = true
		
	if needClickableChange:
		updateClickableCards()

# Raise card in hand.
func _on_cardInHandToRaise(card : Card) -> void:
	var radius_offset = 25
	card.selectCardInHand(radius, radius_offset)
	card.playClickingSound()

# Lower card in hand.
func _on_cardInHandToLower(card : Card) -> void:
	#card.position = Vector2(0, -radius)
	card.deselectCardInHand(radius)
	# Play sound only if we are not switching card (otherwise it would play twice)
	if currentlyHovering == card:
		card.playClickingSound()
	#print("Chiamando suono da _on_cardInHandToLower")
	
# Function to update which area2ds can be enabled for clicking
# (only the currently hovered one)
func updateClickableCards() -> void:
	#print("updating (mano)!")
	#if (currentlyHovering != null):
		#print("CURRENTLY HOVERING: ", currentlyHovering.value, " di ", currentlyHovering.suit)
	for card in carteArray:
		if card != currentlyHovering:
			#print('disabilitando ', card.value, ' di ', card.suit)
			card.disableClicks()
		else:
			#print('abilitando ', card.value, ' di ', card.suit)
			card.enableClicks()
	
# Decreasing sort by z-index.
func _sort_by_z_index(c1, c2):
	return c1.z_index > c2.z_index
	
# Print current hand cards
func _printHandCards():
	print("\tCURRENT HAND CARDS:")
	var i = 1
	for card in carteArray:
		print("\t\t", i, '. ', card.value, ' di ', card.suit)
		i += 1
