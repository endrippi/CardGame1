extends Marker2D

var carteArray
@onready var selectionState = $"../StateMachine/SelezioneCarte"
@onready var gameData: GameData = $"../GameData"
var spazioCarteTavolo : int = 0

@export var currentlyHovering : Card = null
var cardsWhereMouseIsOn : Array[Card] = []

var selectedTableCards: Array[Card]
#signal valTavoloChanged(val : String)
#signal selectedTableCardsChanged(cards : Array[Card])
#signal currentTableSumChanged()
signal tableChanged(val : String, cards: Array[Card], sum : int)
var currentTableSum : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selectionState.tableCardsUpdated.connect(_on_tableCardsUpdated)
	spazioCarteTavolo = gameData.spazioCarteTavolo
	pass
	
# Position cards on the table.
func positionCards() -> void:
	var i = 1
	var offset_x : float = (spazioCarteTavolo-110)/carteArray.size()
	
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
func _on_tableCardsUpdated(cards : Array[Card]) -> void:
	carteArray = cards 
	for card in carteArray:
		card.inHand = false
		card.cardAreaEntered.connect(_on_cardAreaEntered)
		card.cardAreaExited.connect(_on_cardAreaExited)
	#print("carteArrray da tavolo dopo segnale: ", carteArray)
		card.cardSelected.connect(_on_card_clicked)
	positionCards()
	
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
	#valTavoloChanged.emit(valTavolo)
	#selectedTableCardsChanged.emit(selectedTableCards)
	
func updateTableVisuals() -> void:
	#print("Updating (table) visuals")
	for carta in carteArray:
		carta.updateCardVisual()
		
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
