extends State

@export var mano : Marker2D
@export var tavolo : Marker2D
@export var deck : Deck
@onready var uiManager: UiManager = $"../../UiManager"

@onready var carteMano : Array[Card]
@onready var carteTavolo : Array[Card]
@onready var gameData: GameData = $"../../GameData"

var selectedHandCard : Card
var selectedTableCards: Array[Card]
var currentTableSum : int = 0

signal tableCardsUpdated(cards : Array[Card])
signal tableCardsDrawn(cards : Array[Card])
signal handCardsUpdated(cards : Array[Card])

@onready var valTavolo: Label = $"../../DebugValoreTavolo"
@onready var discard: Button = %discard
@onready var valMano: Label = $"../../DebugValoreMano"

var canDiscard : bool = true
var handEmpty : bool = false

@onready var discardState = %Scarto
@onready var endState = %Fine

var tableWasPreviouslyAutoSelected = false
var autoSelectedCards : Array[Card] = []

# Called when the node enters the scene tree for the first time.
func enter(data : GameData, previousState : State) -> void:
	#print("Da start 1: ")
	#gameData._printPreviousHandCards()
	
	var handWasEmpty = false 
	var tableWasEmpty = false

	print("ciao sono nello stato iniziale")
	if data.mano:
		mano = data.mano
	if data.tavolo:
		tavolo = data.tavolo
	deck = data.deck
	carteMano = data.carteMano
	carteTavolo = data.carteTavolo
	selectedHandCard = data.selectedHandCard
	selectedTableCards = data.selectedTableCards
	currentTableSum = data.currentTableSum
	
	print("Current table sum: ", currentTableSum)

	#print("ENTRATO START, CARTE MANO IS EMPTY?", carteMano.is_empty())
	#print("In carte mano: ", carteMano)

	if carteTavolo.is_empty() and !data.partitaIniziata:
		carteTavolo = gameData.deck.drawCard(4, data.tavolo)
		data.partitaIniziata = true
		tableWasEmpty = true
	if carteMano.is_empty():
		#print("Da start, carte mano è vuoto")
		# If we were not at the beginning of the game
		# FANOUT FIX?
		#print("Entrato qui")
		carteMano = gameData.deck.drawCard(3, data.mano)
		if !tableWasEmpty:
			#print("Entrato anche qui")
			gameData.previousHandContents = carteMano.duplicate()
		handWasEmpty = true
		
	#print('previous state is ', previousState)
	updateGameData(gameData)
	gameData.carteMano = carteMano
	
	#print("Da start 2: ")
	#gameData._printPreviousHandCards()

	if tableWasEmpty:
		tableCardsDrawn.emit(carteTavolo)
	else:
		uiManager.deactivatePlaceOnTableButton()
		tableCardsUpdated.emit(carteTavolo)
	if handWasEmpty or gameData.handCardsWereAlreadyRefilled:
		#print("Calling HAND DRAWN")
		handCardsUpdated.emit.call_deferred(carteMano)
		if gameData.handCardsWereAlreadyRefilled:
			gameData.handCardsWereAlreadyRefilled = false
	# FANOUT FIX?
	elif previousState == discardState:
		handCardsUpdated.emit.call_deferred(carteMano)
	else:
		#print("Calling HAND UPDATED")
		handCardsUpdated.emit.call_deferred(carteMano)

	for carta in carteMano:
		carta.cardSelected.connect(_on_card_hand_clicked)
	for carta in carteTavolo:
		carta.cardSelected.connect(_on_card_table_clicked)
		
	valTavolo.text = "0"
	
func update(_delta: float) -> void:
	if gameData.totalPoints >= gameData.targetPunti:
		transitioned.emit(self, "Vittoria")


func _on_play_button_pressed() -> void:
	if selectedHandCard != null:
		transitioned.emit(self, "Giocato")

func _on_card_table_clicked(card : Card):
	print("Carta tavolo cliccata: ", card.value, ' di ', card.suit)
		
	if card.selected == true:
		print("Sto abbassando la carta")
		selectedTableCards.erase(card)
		card.selected = false
		# If previously we had to force a single combination, reset
		if gameData.singleCombination:
			resetAfterSingleCombination()
		elif currentTableSum > 0:
			currentTableSum -= card.value
			print("\tHo tolto ", card.value, " alla table sum")
	else:
		print("Adding ", card, " ovvero ", card.value, " di ", card.suit, " alle selected table cards")
		selectedTableCards.append(card)
		card.selected = true
		# If previously we had to force a single combination, reset
		if gameData.singleCombination:
			resetAfterSingleCombination()
		
		currentTableSum += card.value
		print("\tHo aggiunto", card.value, " alla table sum")
	card.updateCardVisual()
	
	print("Valore tavolo: ", currentTableSum)
	#print("Array di size ", selectedTableCards.size(), " con somma: ", currentTableSum)
	
	print("Selected table cards: ", selectedTableCards)
	
	valTavolo.text = str(currentTableSum)
	# Update shaders to check which cards can be selected now
	#print("Calling update")
	updateGameData(gameData)
	uiManager.updateTableCardShaders()


func _on_card_hand_clicked(card : Card) -> void:
	if selectedHandCard == card:
		card.selected = false
		selectedHandCard = null
		#print("Deselezionata")
		valMano.text = "0"
		uiManager.deactivatePlaceOnTableButton()
	else:
		if selectedHandCard != null:
			selectedHandCard.selected = false
			selectedHandCard = card
			#print("Clickata ", selectedHandCard.value, " di papapapa (cambiando da carta)")
			valMano.text = str(selectedHandCard.value)
			
		else:
			selectedHandCard = card
			#print("Clickata ", selectedHandCard.value, " di papapapa")
			valMano.text = str(selectedHandCard.value)
		selectedHandCard.selected = true
	
	updateGameData(gameData)
	
	# If previously we had to force a single combination, reset
	if gameData.singleCombination:
		resetAfterSingleCombination()
	
	# VISUAL (ogni volta che viene selezionata una carta della mano)
	# 1. Calcolo le combinazioni
	# 2. Da UiManager attivo shader delle carte che si possono prendere
	if selectedHandCard != null:
		var combs = getTableCombinations()
		uiManager.highlightPlayableCards(combs)
		# If there is only one combination, then automatically select the table cards
		if combs.size() == 1  and selectedTableCards.size() == 0:
			#print(combs[0])
			handleSingleCombination(combs[0])
	else:
		uiManager.clearCardShaders()
		#uiManager.deactivatePlaceOnTableButton()
		
	uiManager.updateHandVisuals()
	
# TODO QoL: If there is only one possible combination of cards,
# then automatically select those
func handleSingleCombination(cards) -> void:
	print("HANDLE SINGLE COMB")
	for card in cards:
		print("Ora ", card.value, " di ", card.suit, " è selezionata automaticamente")
		selectedTableCards.append(card)
		card.selected = true 
		card.updateCardVisual()
		autoSelectedCards.append(card)
	gameData.singleCombination = true
	print("Currentsum passa da ", gameData.currentTableSum, " a ", selectedHandCard.value)
	currentTableSum = selectedHandCard.value
	updateGameData(gameData)
	valTavolo.text = str(currentTableSum)
	_printAutoSelectedCards()
	
# Reset auto-selection once a hand card is not clicked anymore.
func resetAfterSingleCombination() -> void:
	print("Reset:")
	_printAutoSelectedCards()
	gameData.singleCombination = false 
	for card in autoSelectedCards:
		print("Ora ", card.value, " di ", card.suit, " non è più selezionata automaticamente")
		card.selected = false 
		card.updateCardVisual()
		selectedTableCards.erase(card)
		print("CurrentTableSum sarebbe ", currentTableSum, ", gli tolgo ", card.value)
	autoSelectedCards = []
	currentTableSum = 0
	updateGameData(gameData)
	valTavolo.text = str(currentTableSum)
	print("Function end: ")
	_printAutoSelectedCards()
	
func updateGameData(data : GameData) -> void:
	data.mano = mano
	data.tavolo = tavolo
	data.deck = deck
	data.carteMano = carteMano
	data.carteTavolo = carteTavolo
	data.selectedHandCard = selectedHandCard
	data.selectedTableCards = selectedTableCards
	data.currentTableSum = currentTableSum
	data.autoSelectedCards = autoSelectedCards

func exit(data : GameData) -> void:
	for carta in carteTavolo:
		if carta.cardSelected.is_connected(_on_card_table_clicked):
			carta.cardSelected.disconnect(_on_card_table_clicked)
		carta.selected = false
	for carta in carteMano:
		if carta.cardSelected.is_connected(_on_card_hand_clicked):
			carta.cardSelected.disconnect(_on_card_hand_clicked)
		carta.selected = false
	uiManager.updateHandVisuals()
	uiManager.updateTableVisuals()
	updateGameData(gameData)
	
func _on_discard_pressed() -> void:
	transitioned.emit(self, "Scarto")

func placeCardOnTable(card : Card) -> void:
	# FANOUT FIX?
	gameData.previousHandContents = carteMano.duplicate()
	#print("\tDa placeCardOnTable:")
	#gameData._printPreviousHandCards()
	
	gameData.carteMano.erase(card)
	gameData.carteTavolo.append(card)
	
	card.selected = false
	card.inHand = false

	card.scale = Vector2(2,2)

	card.rotation = 0

	gameData.selectedHandCard = null
	selectedHandCard = null
	card.cardSelected.disconnect(_on_card_hand_clicked)
	card.cardSelected.connect(_on_card_table_clicked)
	
	# Disconnect from all hands signals
	card.cardAreaEntered.disconnect(mano._on_cardAreaEntered)
	card.cardAreaExited.disconnect(mano._on_cardAreaExited)
	card.cardInHandToRaise.disconnect(mano._on_cardInHandToRaise)
	card.cardInHandToLower.disconnect(mano._on_cardInHandToLower)
	
	# Rimuove dal pivot della mano
	if card.get_parent():
		card.get_parent().remove_child(card)
	
	gameData.carteRimaste -= 1
	if gameData.carteRimaste <= 0:
		refreshHand()
		gameData.carteRimaste = 3
	
	#print("Ecco l'array prima della chiamata al segnale ", gameData.carteTavolo)
	# Aggiorna layout
	tableCardsUpdated.emit(gameData.carteTavolo)
	handCardsUpdated.emit(gameData.carteMano)
	uiManager.updateTableVisuals()
	uiManager.updateHandVisuals()
	fixTable()
	
func fixTable():
	for card in gameData.carteTavolo:
		card.enableClicks()
		card.downscaleCard()
		if card.cardSelected.is_connected(_on_card_hand_clicked):
			card.cardSelected.disconnect(_on_card_hand_clicked)
		if !card.cardSelected.is_connected(_on_card_table_clicked):
			card.cardSelected.connect(_on_card_table_clicked)	
		if card.cardSelected.is_connected(_on_card_hand_clicked):
			card.cardSelected.disconnect(_on_card_hand_clicked)
			
		if card.cardAreaEntered.is_connected(mano._on_cardAreaEntered):
			card.cardAreaEntered.disconnect(mano._on_cardAreaEntered)
		if card.cardAreaExited.is_connected(mano._on_cardAreaExited):
			card.cardAreaExited.disconnect(mano._on_cardAreaExited)
		if card.cardInHandToRaise.is_connected(mano._on_cardInHandToRaise):
			card.cardInHandToRaise.disconnect(mano._on_cardInHandToRaise)
		if card.cardInHandToLower.is_connected(mano._on_cardInHandToLower):
			card.cardInHandToLower.disconnect(mano._on_cardInHandToLower)
		

func _on_place_on_table_button_pressed() -> void:
	if selectedHandCard:
		uiManager.deactivatePlaceOnTableButton()
		placeCardOnTable(selectedHandCard)	
		# If we place a card, deselect everything that was on the table and 
		# update accordingly
		for card in selectedTableCards:
			card.selected = false 
			currentTableSum = 0 
			valTavolo.text = "0"
			card.updateCardVisual()
		if gameData.singleCombination:
			resetAfterSingleCombination()
		selectedTableCards = []
		updateGameData(gameData)
		if gameData.maniDisponibili <= 0 and gameData.carteMano.is_empty():
			transitioned.emit(self, "Sconfitta")

func refreshHand() -> void:
	# Scala le mani disponibili (se le regole del tuo gioco lo prevedono)
	gameData.maniDisponibili -= 1
	#gameData.handCardsWereAlreadyRefilled = true
	
	# Se le mani sono finite, potresti voler gestire la fine della partita qui
	if gameData.maniDisponibili <= 0:
		transitioned.emit(self, "Sconfitta") # O lo stato di game over appropriato
		return

	# 1. Pesca e salva le nuove carte
	var nuoveCarte = gameData.deck.drawCard(3, gameData.mano)
	
	# FANOUT FIX?
	gameData.previousHandContents = carteMano.duplicate()
	
	gameData.carteMano.append_array(nuoveCarte)
	carteMano = gameData.carteMano
	
	# 2. Connetti i segnali
	for carta in nuoveCarte:
		if not carta.cardSelected.is_connected(_on_card_hand_clicked):
			carta.cardSelected.connect(_on_card_hand_clicked)
	
	# 3. Notifica la Ui
	handCardsUpdated.emit.call_deferred(gameData.carteMano)

# Get all the possible combinations of table cards that you can choose to select 
# from the hand card you selected.
# Uses recursive helper function.
func getTableCombinations() -> Array:
	var target := selectedHandCard.value
	var totalCards := []		# The subsets of cards that have the right sum
	var curr := []				# Current subset being built via recursion
	# Start recursion from first card with sum 0
	_backtrack_table_combinations(0, 0, curr, totalCards, target)
	return totalCards

# Helper for backtracking combinations
func _backtrack_table_combinations(idx: int, currSum: int, curr: Array, totalCards: Array, target: int) -> void:
	# If the current sum is already the target, add current combination to the total ones
	if currSum == target:
		totalCards.append(curr.duplicate(true))
		return
	# If sum is bigger, skip
	if currSum > target:
		return
	# If we finished the cards, skip
	if idx >= carteTavolo.size():
		return

	# Include current card
	curr.append(carteTavolo[idx])
	_backtrack_table_combinations(idx + 1, currSum + carteTavolo[idx].value, curr, totalCards, target)
	
	# Remove current card from the array to test branch without it
	curr.pop_back()	
	# Exclude current card
	_backtrack_table_combinations(idx + 1, currSum, curr, totalCards, target)

# Print autoselected cards
func _printAutoSelectedCards():
	print("\tAUTOSELECTED CARDS:")
	var i = 1
	for card in autoSelectedCards:
		print("\t\t", i, '. ', card.value, ' di ', card.suit, ' con z-index: ', card.z_index)
		#card._printClickingState()
		i += 1
