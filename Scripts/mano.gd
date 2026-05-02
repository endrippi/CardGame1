extends Marker2D

var carteArray
@onready var selectionState = $"../StateMachine/SelezioneCarte"
@export var fanAngle : float = 25
@onready var pivot : Node2D = $CardPivot
var radius := 300.0  # distance from pivot to card center

@export var currentlyHovering : Card = null
var cardsWhereMouseIsOn : Array[Card] = []

var selectedHandCard : Card
signal valManoChanged(val : String)
signal selectedHandCardChanged(card : Card)

# Animation stuff
var time : float = 0.0
var sineOffsetMult : float = 0.003		# How much to emphasize the sine curve when card still.
var cosineOffsetMult : float = 0.00002
@export var timeMultiplier : float = 2.0
var tween : Tween
@export var drawingSpeed : float = 0.4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selectionState.handCardsUpdated.connect(_on_handCardsUpdated)
	
func _process(delta):
	time += delta
	var i = 0
	for card in carteArray:
		# Sine function to make it "float" regularly:
		# The index of the card is used to make the curve different for each card
		# The time part is to make sure that the card oscillates (otherwise sin is fixed)
		var val: float = sin(i + (time * timeMultiplier))
		card.position.y += val * sineOffsetMult
		# Rotate
		card.rotation += cos(i + (time * timeMultiplier)) * cosineOffsetMult
		i += 1


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

# Fan out cards in hand.
func fanoutCards(justDrawn : bool) -> void:
	var N = carteArray.size()
	var angles
	# TODO Get correct fan angle according to number of cards in hand
	if N > 3:
		angles = getRotationAngles(N, adjustFanAngle(N, fanAngle*2.5))
	else:
		angles = getRotationAngles(N, fanAngle)
		
	if justDrawn:
		if tween and tween.is_running():
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		for i in range(N):
			var currPivot = pivot.duplicate()
			currPivot.add_child(carteArray[i])
			
			var startingPosition = Vector2(-550,-400)
			carteArray[i].position = startingPosition
			#carteArray[i].scale = Vector2(3, 3)
			var finalPosition = Vector2(0, -radius)  # Placed on pivot's radius
			
			tween.parallel().tween_property(carteArray[i], "position", finalPosition, drawingSpeed + (i * 0.075))
			tween.parallel().tween_property(currPivot, "rotation_degrees", angles[i], drawingSpeed + (i * 0.075))
			tween.parallel().tween_property(carteArray[i], "scale", Vector2(3, 3), drawingSpeed + (i * 0.075))
			#currPivot.rotation_degrees = angles[i]
			
			# Instantiate the pivot and the actual card
			self.add_child(currPivot)
	else:
		for i in range(N):
			var currPivot = pivot.duplicate()
			currPivot.add_child(carteArray[i])
			carteArray[i].scale = Vector2(3, 3)
			carteArray[i].position = Vector2(0, -radius)  # Placed on pivot's radius
			
			currPivot.rotation_degrees = angles[i]
			
			# Instantiate the pivot and the actual card
			self.add_child(currPivot)

# Function to connect the signals of the cards that are currently in hand to 
# the hand script (for hovering and clicks).
func _on_handCardsUpdated(cards : Array[Card], justDrawn : bool) -> void:
	carteArray = cards
	for card in carteArray:
		card.cardAreaEntered.connect(_on_cardAreaEntered)
		card.cardAreaExited.connect(_on_cardAreaExited)
		card.cardInHandToRaise.connect(_on_cardInHandToRaise)
		card.cardInHandToLower.connect(_on_cardInHandToLower)
		
		# Signals are now moved here from state "selezionecarte" in order
		# to be handled regardless of play state
		card.cardSelected.connect(_on_card_clicked)
		
		card.inHand = true
	fanoutCards(justDrawn)

# Function that was previously in "selezioneCarte"
# Handling which card is selected and signaling card and value to the connected state
func _on_card_clicked(card : Card) -> void:
	print("On card hand clicked per ", card.value, ' di ', card.suit)
	var valMano : String = ''
	if selectedHandCard == card:
		card.selected = false
		selectedHandCard = null
		print("\tDeselezionata")
		valMano = "0"
	else:
		if selectedHandCard != null:
			selectedHandCard.selected = false
			selectedHandCard = card
			print("\tClickata ", selectedHandCard.value, " di ", selectedHandCard.suit, "(cambiando da carta)")
			valMano = str(selectedHandCard.value)
		else:
			selectedHandCard = card
			print("\tClickata ", selectedHandCard.value, " di ", selectedHandCard.suit)
			valMano = str(selectedHandCard.value)
		selectedHandCard.selected = true
	valManoChanged.emit(valMano)
	selectedHandCardChanged.emit(selectedHandCard)
	updateHandVisuals()

func updateHandVisuals() -> void:
	print('\n')
	for carta in carteArray:
		carta.updateCardVisual()
		
# Function to disconnect the signals of the cards from the observing hand script.
func cleanupAfterStateExit() -> void:
	for carta in carteArray:
		if carta.cardSelected.is_connected(_on_card_clicked):
			carta.cardSelected.disconnect(_on_card_clicked)
		carta.selected = false
	updateHandVisuals()
	
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

# Utility to print card values in string.
func printArray(cards : Array[Card]) -> String:
	var vals : String
	for c in cards:
		vals += str(c.value)
		vals += ', '
	return vals
	
# Decreasing sort by z-index.
func _sort_by_z_index(c1, c2):
	return c1.z_index > c2.z_index
