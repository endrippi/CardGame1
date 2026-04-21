extends Marker2D

var carteArray
@onready var selectionState = $"../StateMachine/SelezioneCarte"
@export var fanAngle : float = 25
@onready var pivot : Node2D = $CardPivot
var radius := 300.0  # distance from pivot to card center

@export var currentlyHovering : Card = null
var cardsWhereMouseIsOn : Array[Card] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selectionState.handCardsUpdated.connect(_on_handCardsUpdated)

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
func fanoutCards() -> void:
	var N = carteArray.size()
	var angles
	# TODO Get correct fan angle according to number of cards in hand
	if N > 3:
		angles = getRotationAngles(N, adjustFanAngle(N, fanAngle*2.5))
	else:
		angles = getRotationAngles(N, fanAngle)
	for i in range(N):
		var currPivot = pivot.duplicate()
		currPivot.add_child(carteArray[i])
		carteArray[i].scale = Vector2(3, 3)
		carteArray[i].position = Vector2(0, -radius)  # Placed on pivot's radius
		
		currPivot.rotation_degrees = angles[i]
		
		# Instantiate the pivot and the actual card
		self.add_child(currPivot)
	
func _on_handCardsUpdated(cards : Array[Card]) -> void:
	carteArray = cards
	for card in carteArray:
		card.cardAreaEntered.connect(_on_cardAreaEntered)
		card.cardAreaExited.connect(_on_cardAreaExited)
		card.cardInHandToRaise.connect(_on_cardInHandToRaise)
		card.cardInHandToLower.connect(_on_cardInHandToLower)
		card.inHand = true
	fanoutCards()
	
# We don't want to receive interrupts to hover card IF: we have not exited the area of 
# the currently hovered card AND we have not entered the area of the NEXT card in hand.
# Cards have increasing z-indexes so I can use those to see who comes first in hand.
func _on_cardAreaEntered(card : Card):
	print("ENTRATO in ", card.value, ", la aggiungo all'array")
	cardsWhereMouseIsOn.append(card)
	# If I am not hovering anything yet, I animate the card directly
	if currentlyHovering == null:
		card.upscaleCard()
		# Update the card I am hovering to point to this one
		currentlyHovering = card
		print("\tENTRATO: Ho attivato ", card.value, " e ci switcho direttamente.")
	# If I am already hovering on a card I must control if I can move the hover
	else:
		# If the card to which I am moving comes later then I switch
		if card.z_index >= currentlyHovering.z_index:
			currentlyHovering.downscaleCard()
			card.upscaleCard()
			currentlyHovering = card
			print("\tENTRATO: Ho attivato ", card.value, " e ci switcho perché viene dopo.")
	
# If there is potentially another card to switch to, I switch and hover on it.
func _on_cardAreaExited(card : Card):
	# If there is nothing to switch to and I am still hovering the card
	# (bc maybe I have already switched)
	# then I update the card and that's it
	print("USCITO da ", card.value, ", la tolgo dall'array")
	cardsWhereMouseIsOn.erase(card)
	if cardsWhereMouseIsOn.is_empty():
		print("\tEXITED: CASO NEXTHOVER == NULL -> downscalo ", card.value)
		card.downscaleCard()
		currentlyHovering = null
	# If there is a card to switch to, I switch to that one.
	else:
		# We want to switch to the card which is rightmost, so we sort it by z_index
		card.downscaleCard()
		cardsWhereMouseIsOn.sort_custom(_sort_by_z_index)
		
		print("\t\tSortato ho (in ordine):")
		for c in cardsWhereMouseIsOn:
			print("\t\t\tcarta ", c.value, " con z-index:", c.z_index)
			
		if cardsWhereMouseIsOn[0] != currentlyHovering:
			cardsWhereMouseIsOn[0].upscaleCard()
		currentlyHovering = cardsWhereMouseIsOn[0]
		print("\tEXITED: passo alla carta più a dx tra ", printArray(cardsWhereMouseIsOn), " che è ", cardsWhereMouseIsOn[0].value)
		#nextHover.remove_at(0)
			
# Raise card in hand.
func _on_cardInHandToRaise(card : Card) -> void:
	var radius_offset = 25
	#print("now should raise card ", card)
	card.position = Vector2(0, -(radius + card.offset_y + radius_offset))

# Lower card in hand.
func _on_cardInHandToLower(card : Card) -> void:
	#print("now should lower card ", card)
	card.position = Vector2(0, -radius)

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
