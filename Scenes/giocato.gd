extends State

@onready var numeroPunti: RichTextLabel = %ContaPunti
var shouldGoBack : bool = false
var canGoForward : bool = false
@onready var uiManager: UiManager = $"../../UiManager"
@onready var gameData = %GameData

@onready var scopaSound : AudioStreamPlayer = %ScopaSound
@onready var pointSound : AudioStreamPlayer = $"../../SuonoPunti"
var ultimoPunteggio : int = 0

var pointsTween : Tween


func enter(data : GameData, previousState : State) -> void:
	print("ciao sono nello stato Giocato")

	if data.selectedHandCard == null:
		transitioned.emit(self, "SelezioneCarte")
		return

	#print(
	#	"Mano di ",
	#	data.selectedHandCard.value,
	#	" con somma di tavolo di ",
	#	data.currentTableSum
	#)

	# COMBINAZIONE CORRETTA
	if data.selectedHandCard.value == data.currentTableSum:
		#print("Combinazione giusta, uso ", data.selectedHandCard.value, " di ", data.selectedHandCard.suit)
		# Punti
		var puntiIniziali : int = data.totalPoints
		var puntiDaAggiungere : int = data.selectedHandCard.value + data.currentTableSum

		_printSelectedTableCards()
		
		# Rimuove carte tavolo
		for card in data.selectedTableCards:
			#print("Sto togliendo dal tavolo il ", card.value, " di ", card.suit)
			data.carteTavolo.erase(card)
			card.queue_free()
			
		if data.carteTavolo.is_empty():
			puntiDaAggiungere += 10
			numeroPunti.text = str(data.totalPoints)
			scopaSound.play()
			uiManager.showScopaScreen()
		
		data.totalPoints += puntiDaAggiungere
		resetTween()
		pointsTween.tween_method(updatePointsText, puntiIniziali, data.totalPoints, 1.0)
		resetPitch()
		
		# FANOUT FIX?
		data.previousHandContents = data.carteMano.duplicate()
		#print("\tDa update in Giocato:")
		#data._printPreviousHandCards()
		
		# Rimuove carta mano
		#print("Rimuovo dalla mano il ", data.selectedHandCard.value, " di ", data.selectedHandCard.suit)
		data.carteMano.erase(data.selectedHandCard)
		data.selectedHandCard.get_parent().queue_free()		# Also remove pivot

		# Reset selezioni
		data.selectedTableCards.clear()

		data.selectedHandCard = null

		data.currentTableSum = 0
		canGoForward = true
		transitioned.emit.call_deferred(self, "Fine")
	else:
		#print("Combinazione sbagliata!")
		#print("volevo usare ", data.selectedHandCard.value, " di ", data.selectedHandCard.suit, ' per prendere:')
		#_printSelectedTableCards()
		
		data.currentTableSum = 0
		
		# PLEASE GOD LET IT BE THIS
		data.selectedTableCards = []		
		#data.selectedHandCard.selected = false 
		#data.selectedHandCard = null 
		data.currentTableSum = 0
		
		uiManager.updateHandVisuals()
		uiManager.updateTableVisuals()
		
		shouldGoBack = true
		transitioned.emit.call_deferred(self, "SelezioneCarte")


#func update(_delta: float) -> void:	
#	if shouldGoBack:
#		transitioned.emit(self, "SelezioneCarte")
#	if canGoForward:
#		transitioned.emit(self, "Fine")
		
func resetTween() -> void:
	if pointsTween:
		pointsTween.kill()
	pointsTween = create_tween().set_ease(Tween.EASE_OUT)

func updatePointsText(val : int) -> void:
	numeroPunti.text = str(val)
	
	if val > ultimoPunteggio:
		ultimoPunteggio = val
		pointSound.pitch_scale += 0.02
		pointSound.play()

func resetPitch() -> void:
	pointSound.pitch_scale = 1.0


# Print current hand cards
func _printSelectedTableCards():
	pass
	#print("\tSELECTED TABLE CARDS:")
	#var i = 1
	#for card in gameData.selectedTableCards:
	#	print("\t\t", i, '. ', card.value, ' di ', card.suit, ' con z-index: ', card.z_index)
		#card._printClickingState()
	#	i += 1
