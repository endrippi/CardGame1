extends Marker2D

var carteArray
@onready var selectionState = $"../StateMachine/SelezioneCarte"
@onready var gameData: GameData = $"../GameData"
var spazioCarteTavolo : int = 0

@export var currentlyHovering : Card = null
var cardsWhereMouseIsOn : Array[Card] = []

var selectedTableCards: Array[Card]
signal tableChanged(val : String, cards: Array[Card], sum : int)
var currentTableSum : int = 0

# Animation stuff
var time : float = 0.0
var sineOffsetMult : float = 0.005		# How much to emphasize the sine curve when card still.
var cosineOffsetMult  : float = 0.00005
@export var timeMultiplier : float = 2.0
var tween : Tween
@export var drawingSpeed : float = 0.4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selectionState.tableCardsUpdated.connect(_on_tableCardsUpdated)
	spazioCarteTavolo = gameData.spazioCarteTavolo
	pass
	
func _process(delta):
	time += delta
	var i = 0
	for card in carteArray:
		# Sine function to make it "float" regularly
		var val: float = sin(i + (time * timeMultiplier))
		#print('card ', i, ' with val :', val)
		card.position.y += val * sineOffsetMult
		# Also rotate
		card.rotation += cos(i + (time * timeMultiplier)) * cosineOffsetMult
		i += 1
	
# Position cards on the table.
func positionCards(justDrawn : bool) -> void:
	var i = 1
	var offset_x : float = (spazioCarteTavolo-110)/carteArray.size()
	
	# If cards are just drawn, then animate them to come from the deck to the table.
	if justDrawn:
		if tween and tween.is_running():
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		for card in carteArray:
			print(card)
			# Position the card with offset
			var finalPosition =  Vector2(i * offset_x, card.position.y)
			# Starting from where the deck is located (circa), then card is animated to its place
			var startingPosition = Vector2(-233,300)
			card.position = startingPosition
			card.z_index = i
			# Add it as children to the table
			self.add_child(card)
			tween.parallel().tween_property(card, "position", finalPosition, drawingSpeed + (i * 0.075))
			i += 1
	# Otherwise, just rearrrange them (TODO update in the future with animation).
	else:
		for card in carteArray:
			print(card)
			# Position the card with offset
			card.position.x =  i * offset_x
			card.z_index = i
			# Add it as children to the table
			self.add_child(card)
			i += 1
	#print('figli del tavolo: ', self.get_child_count())

# On signal _on_tableCardsUpdated, updates current cards in table and later updates visuals.
func _on_tableCardsUpdated(cards : Array[Card], justDrawn : bool) -> void:
	carteArray = cards 
	for card in carteArray:
		card.inHand = false
		card.cardAreaEntered.connect(_on_cardAreaEntered)
		card.cardAreaExited.connect(_on_cardAreaExited)
	#print("carteArrray da tavolo dopo segnale: ", carteArray)
		card.cardSelected.connect(_on_card_clicked)
	positionCards(justDrawn)

# Function that was previously in "selezioneCarte"
# Handling which cards are selected and signaling selected cards, their value,
# and sum to the connected state.
func _on_card_clicked(card : Card):
	var valTavolo : String = ''
	#print("On card table clicked per ", card.value, ' di ', card.suit)
	if card.selected == true:
		selectedTableCards.erase(card)
		card.selected = false
		currentTableSum -= card.value
	else:
		selectedTableCards.append(card)
		card.selected = true
		currentTableSum += card.value
	card.updateCardVisual()
	#print("Array di size ", selectedTableCards.size(), " con somma: ", currentTableSum)
	
	valTavolo = str(currentTableSum)
	tableChanged.emit(valTavolo, selectedTableCards, currentTableSum)

func updateTableVisuals() -> void:
	#print("Updating (table) visuals")
	for carta in carteArray:
		carta.updateCardVisual()

# Function to disconnect cards' signals from the observing table.
func cleanupAfterStateExit() -> void:
	for carta in carteArray:
		if carta.cardSelected.is_connected(_on_card_clicked):
			carta.cardSelected.disconnect(_on_card_clicked)
		carta.selected = false
	updateTableVisuals()
	
func _on_cardAreaEntered(card : Card) -> void:
	var needClickableChange = false
	cardsWhereMouseIsOn.append(card)
	# If I am not hovering anything yet, I animate the card directly
	if currentlyHovering == null:
		print('upscale chiamato da qui1')
		card.upscaleCard()
		# Update the card I am hovering to point to this one
		currentlyHovering = card
		needClickableChange = true
	# If I am already hovering on a card I must control if I can move the hover
	else:
		# If the card to which I am moving comes later then I switch
		if card.z_index >= currentlyHovering.z_index:
			currentlyHovering.downscaleCard()
			print('upscale chiamato da qui2')
			card.upscaleCard()
			currentlyHovering = card
			needClickableChange = true
	if needClickableChange:
		updateClickableCards()
	
func _on_cardAreaExited(card : Card) -> void:
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
			print('upscale chiamato da qui3')
			cardsWhereMouseIsOn[0].upscaleCard()
		needClickableChange = true
		currentlyHovering = cardsWhereMouseIsOn[0]
	if needClickableChange:
		updateClickableCards()
		
		
# Function to update which area2ds can be enabled for clicking
# (only the currently hovered one)
func updateClickableCards() -> void:
	print("updating (tavolo)!")
	#if (currentlyHovering != null):
	#	print("CURRENTLY HOVERING: ", currentlyHovering.value, " di ", currentlyHovering.suit)
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
