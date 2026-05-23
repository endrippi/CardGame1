class_name UiManager extends Node
@onready var game_data: GameData = $"../GameData"

@onready var discardsLabel: RichTextLabel = %Discards
@onready var counterCarte: Label = %counterCarte
@onready var numero_punti: RichTextLabel = %ContaPunti
@onready var debug_valore_mano: Label = %DebugValoreMano
@onready var debug_valore_tavolo: Label = %DebugValoreTavolo
@onready var label: RichTextLabel = %Label
@onready var discardButton: Button = %discard
@onready var place_table: Button = %PlaceTable
@onready var undoDiscardButton: Button = %UndoDiscard
@onready var confirmDiscardButton: Button = %ConfirmDiscard
@onready var labelCardsDiscard: RichTextLabel = %labelCardsDiscard
@onready var playButton: Button = %PlayButton
@onready var sfocatura: ColorRect = %sfocatura
@onready var placeOnTableButton: Button = %placeOnTableButton

@onready var sfocaturaSuTutto : ColorRect = %sfocaturaSuTutto
@onready var scopaLabel : RichTextLabel = %scopaLabel


# To temporarily store possible playable table card combinations for shaders.
var currentPlayableCombinations = []

var scopaScreenTimeout = 1.75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func updatePoints() -> void:
	pass
	
func updateHandVisuals() -> void:
	for carta in game_data.carteMano:
		carta.updateCardVisual()
		
func updateTableVisuals() -> void:
	for carta in game_data.carteTavolo:
		carta.updateCardVisual()

func enableDiscardMode(val : bool) -> void:
	discardButton.visible = !val
	playButton.visible = !val
	sfocatura.visible = val
	undoDiscardButton.visible = val
	confirmDiscardButton.visible = val
	labelCardsDiscard.visible = val
	placeOnTableButton.visible = false
	
	# Deactivating shaders for cards on the table which were selectable
	for card in game_data.carteTavolo:
		card.deactivateShader()

func clearTableVisuals() -> void:
	for child in get_children():
		if child is Card:
			remove_child(child)

func _on_discard_pressed() -> void:
	enableDiscardMode(true)

func _on_undo_discard_pressed() -> void:
	enableDiscardMode(false)

func hideDiscard(val : bool) -> void:
	discardButton.visible = val
	
# Function to activate/deactivate shaders for selectable table cards.
# Shaders are activated for every card on the table that can be picked.
# CALLED when hand card is selected
func highlightPlayableCards(combs : Array) -> void:
	#print("Chiamata!")
	if game_data.selectedHandCard == null:
		clearCardShaders()
		return
	#print("SELECTED HAND CARD È ", game_data.selectedHandCard.value, ' di ', game_data.selectedHandCard.suit)
	var cards = []
	currentPlayableCombinations = combs
	# Get all interested cards
	for comb in combs:
		for card in comb:
			if card not in cards:
				#print('Aggiungo ', card.value, ' di ', card.suit)
				cards.append(card)
				
	# Update all table cards depending on whether they can be played or not
	for card in game_data.carteTavolo:
		if card in cards:
			#print('Attivo shader di ', card.value, ' di ', card.suit)
			card.activateShader()
		else:
			#print('Disattivo shader di ', card.value, ' di ', card.suit)
			card.deactivateShader()
	
	# Immediately show place button if there are no combinations, otherwise hide it
	#print("Is current selected card null? ", game_data.selectedHandCard == null)
	#print("Are current combs empty? ", combs.is_empty())
	if game_data.selectedHandCard == null:
		deactivatePlaceOnTableButton()
	if combs.is_empty():
		activatePlaceOnTableButton()
	else:
		deactivatePlaceOnTableButton()
			
# Function to update card shaders on table card click.
# A table card will still be highlighted if it is in at least one playable combination 
# that features the other already selected table cards.
# CALLED when table card is selected
func updateTableCardShaders() -> void:
	if game_data.selectedHandCard == null:
		clearCardShaders()
		return
	print("SELECTED HAND CARD È ", game_data.selectedHandCard.value, ' di ', game_data.selectedHandCard.suit)
	#print("Sono qui")
	var possibleCombs = []
	var cards = []
	# First retrieve all playable combinations that feature selected table cards
	print("Selected table cards: ", game_data.selectedTableCards)
	for comb in currentPlayableCombinations:
		print("Vedendo combinazione ", comb)
		if isSubset(game_data.selectedTableCards, comb):
			print('Una COMBINAZIONE che ha ancora senso è', comb)
			possibleCombs.append(comb)
	# Then get which cards are featured in them
	for comb in possibleCombs:
		for card in comb:
			if card not in cards:
				cards.append(card) 	
				print('Quindi una CARTA che ha senso è ', card)	
	# Update all table cards depending on whether they can be played or not
	for card in game_data.carteTavolo:
		if card in cards:
			card.activateShader()
		else:
			card.deactivateShader()
	
# Disable shaders for all table cards
func clearCardShaders() -> void:
	for card in game_data.carteTavolo:
		card.deactivateShader()

# Enable place on table button
func activatePlaceOnTableButton() -> void:
	print("ACTIVATE BUTTON")
	if game_data.selectedHandCard == null:
		print("NULL SELECTED CARD")
		return
	print("SELECTED CARD is ", game_data.selectedHandCard.value, ' di ', game_data.selectedHandCard.suit)
	placeOnTableButton.show()

# Disable place on table button
func deactivatePlaceOnTableButton() -> void:
	placeOnTableButton.hide()
	
func deselectTableCards() -> void:
	for card in game_data.carteTavolo:
		card.selected = false
		card.updateCardVisual()

func lowerGivenCards(cards : Array[Card])-> void:
	for card in cards:
		card.deselectCardInHand(game_data.mano.radius)

func showScopaScreen() -> void:
	sfocaturaSuTutto.visible = true 
	scopaLabel.startTextAnimation()
	await get_tree().create_timer(scopaScreenTimeout).timeout
	hideScopaScreen()
	
func hideScopaScreen() -> void:
	sfocaturaSuTutto.visible = false 
	scopaLabel.hide()

# Function to check if an array is a subset of another
func isSubset(subset: Array, biggerSet: Array) -> bool:    
	for item in subset:        
		if item not in biggerSet:           
			return false    
	return true
	
func isButtonActivated(originPoint : String) -> void:
	if placeOnTableButton != null:
		print("\tFrom ", originPoint, ' is the button visible? ', placeOnTableButton.visible)
	
	
func hideAllButtons() -> void:
	confirmDiscardButton.visible = false
	discardButton.visible = false
	playButton.visible = false
	undoDiscardButton.visible = false
	labelCardsDiscard.visible = false
	placeOnTableButton.visible = false
