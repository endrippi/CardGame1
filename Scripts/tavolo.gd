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
	spazioCarteTavolo = gameData.spazioCarteTavolo
	pass
	
func _process(delta):
	time = animationManager.animateCardRow(false, delta, time, sineOffsetMult, cosineOffsetMult, timeMultiplier)
	
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
	print("Segnale di TABLE UPDATE ricevuto")
	carteArray = cards 
	for card in carteArray:
		card.inHand = false
	print("carteArray da tavolo dopo segnale: ", carteArray)
	positionCards()
