extends Marker2D

var carteArray
@onready var selectionState = $"../StateMachine/SelezioneCarte"
@export var fan_angle : float = 25
@onready var pivot : Node2D = $CardPivot
var radius := 300.0  # distance from pivot to card center

var currentlyHovering : Card = null
var nextHover : Card = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selectionState.handCardsUpdated.connect(_on_handCardsUpdated)

# Fan out cards in hand.
func fanoutCards() -> void:
	var N = carteArray.size()
	for i in range(N):
		var currPivot = pivot.duplicate()
		currPivot.add_child(carteArray[i])
		carteArray[i].scale = Vector2(3, 3)
		carteArray[i].position = Vector2(0, -radius)  # Placed on pivot's radius
		
		# Evenly spaced and centered around 0
		var offset: float		
		if N % 2 == 1:			
			# Odd: center card at 0		
			offset = i - int(N / 2)		
		else:			
			# Even: no center card	
			offset = i - int(N / 2)			
			if i >= N / 2:				
				offset += 1
		
		# Rotate the card accordingly
		currPivot.rotation_degrees = offset * fan_angle
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
	# If I am not hovering anything yet, I animate the card directly
	if currentlyHovering == null:
		card.upscaleCard()
		# Update the card I am hovering to point to this one
		currentlyHovering = card
	# If I am already hovering on a card I must control if I can move the hover
	else:
		# If the card to which I am moving comes later then I switch
		if card.z_index >= currentlyHovering.z_index:
			currentlyHovering.downscaleCard()
			card.upscaleCard()
			currentlyHovering = card
		# If the card to which I am moving comes first then I remember it 
		# and switch later
		else:
			nextHover = card
	
# If there is potentially another card to switch to, I switch and hover on it.
func _on_cardAreaExited(card : Card):
	# If there is nothing to switch to and I am still hovering the card
	# (bc maybe I have already switched)
	# then I update the card and that's it
	if nextHover == null && currentlyHovering == card:
		card.downscaleCard()
	# If there is a card to switch to, I switch to that one.
	elif nextHover != null:
		card.downscaleCard()
		nextHover.upscaleCard()
		currentlyHovering = nextHover
		nextHover = null

# Raise card in hand.	
func _on_cardInHandToRaise(card : Card ) -> void:
	var radius_offset = 25
	#print("now should raise card ", card)
	card.position = Vector2(0, -(radius + card.offset_y + radius_offset))

# Lower card in hand.
func _on_cardInHandToLower(card : Card) -> void:
	#print("now should lower card ", card)
	card.position = Vector2(0, -radius)
