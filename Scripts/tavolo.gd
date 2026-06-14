extends Marker2D

var carteArray
@onready var selectionState = $"../StateMachine/SelezioneCarte"
@onready var gameData: GameData = $"../GameData"
var spazioCarteTavolo : int = 0
@onready var uiManager: UiManager = $"../UiManager"

# Animation stuff!
@onready var animationManager = %AnimationManager
var time : float = 0.0
var sineOffsetMult : float = 0.005		# How much to emphasize the sine curve when card still.
var cosineOffsetMult  : float = 0.00005
@export var timeMultiplier : float = 2.0
var tween : Tween
@export var drawingSpeed : float = 0.4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selectionState.tableCardsUpdated.connect(_on_tableCardsUpdated)
	selectionState.tableCardsDrawn.connect(_on_tableCardsDrawn)
	spazioCarteTavolo = gameData.spazioCarteTavolo
	pass
	
func _process(delta):
	time = animationManager.animateCardRow(false, delta, time, sineOffsetMult, cosineOffsetMult, timeMultiplier)

func positionDrawnCards() -> void:
	print("Positioning drawn cards...")
	
	var left_bound: float = 0
	var right_bound: float = spazioCarteTavolo
	var min_offset: float = 60.0
	var max_offset: float = 150.0
	
	# Total available width
	var available_width = right_bound - left_bound
	# Number of cards
	var count = carteArray.size()
	# If only one card, place it in the center
	var offset_x: float = 0
		
	var N = carteArray.size()
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	var startingPosition = Vector2(-550,-400)
	#var offset_x : float = (spazioCarteTavolo-110)/carteArray.size()
	# Ideal spacing between cards
	offset_x = clamp(
		available_width / (N - 1),
		min_offset,
		max_offset
	)
	
	# Total width occupied by the table
	var total_table_width = offset_x * (count - 1)
	# Center the hand inside bounds
	var start_x = left_bound + (available_width - total_table_width) / 2.0
	#print('offset_x: ', offset_x)
	
	for i in range(N):
		carteArray[i].position = startingPosition
		var finalPosition = Vector2(start_x + (i * offset_x),-30)
		
		carteArray[i].z_index = i
		
		tween.parallel().tween_property(carteArray[i], "position", finalPosition, drawingSpeed + (i * 0.075))
		tween.parallel().tween_property(carteArray[i], "scale", carteArray[i].baseTableCardScale, drawingSpeed + (i * 0.075))
		
		self.add_child(carteArray[i])
		
# Position cards on the table.
func positionCards() -> void:
	print("Positioning cards...")
	
	if carteArray.is_empty():
		return

	var left_bound: float = 0
	var right_bound: float = spazioCarteTavolo
	var min_offset: float = 60.0
	var max_offset: float = 150.0
	
	# Total available width
	var available_width = right_bound - left_bound
	# Number of cards
	var count = carteArray.size()
	# If only one card, place it in the center
	var offset_x: float = 0

	if count > 1:
		# Ideal spacing between cards
		offset_x = clamp(
			available_width / (count - 1),
			min_offset,
			max_offset
		)

	# Total width occupied by the table
	var total_table_width = offset_x * (count - 1)
	# Center the hand inside bounds
	var start_x = left_bound + (available_width - total_table_width) / 2.0
	
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	for i in range(count):
		var card = carteArray[i]

		#print("CARD from position: ", card.value, " di ", card.suit, " with offset ", offset_x)

		var final_position = Vector2(start_x + (i * offset_x), -30)
		#print('final position: ', final_position)
		card.z_index = i

		tween.parallel().tween_property(card, "position", final_position, 0.3)

		# Add card to table if not already added
		if card.get_parent() != self:
			self.add_child(card)


# On signal _on_tableCardsUpdated, updates current cards in table and later updates visuals.
func _on_tableCardsUpdated(cards : Array[Card]) -> void:
	#print("Segnale di TABLE UPDATE ricevuto")
	#_printTableCards()
	carteArray = cards 
	for card in carteArray:
		card.inHand = false
	#print("carteArray da tavolo dopo segnale: ", carteArray)
	positionCards()
	
func _on_tableCardsDrawn(cards : Array[Card]) -> void:
	carteArray = cards 
	for card in carteArray:
		card.inHand = false
	positionDrawnCards()
	
# Print current table cards
func _printTableCards():
	print("\tCURRENT TABLE CARDS:")
	var i = 1
	for card in carteArray:
		print("\t\t", i, '. ', card.value, ' di ', card.suit, ' con z-index: ', card.z_index)
		card._printClickingState()
		i += 1
