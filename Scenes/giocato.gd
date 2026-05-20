extends State

@onready var numeroPunti: Label = %numeroPunti
var shouldGoBack : bool = false
var canGoForward : bool = false
@onready var uiManager: UiManager = $"../../UiManager"

func enter(data : GameData, previousState : State) -> void:
	print("ciao sono nello stato Giocato")

	if data.selectedHandCard == null:
		transitioned.emit(self, "SelezioneCarte")
		return

	print(
		"Mano di ",
		data.selectedHandCard.value,
		" con somma di tavolo di ",
		data.currentTableSum
	)

	# COMBINAZIONE CORRETTA
	if data.selectedHandCard.value == data.currentTableSum:
		print("Combinazione giusta")
		# Punti
		data.totalPoints += data.currentTableSum + data.selectedHandCard.value
		numeroPunti.text = str(data.totalPoints)

		# Rimuove carte tavolo
		for card in data.selectedTableCards:
			data.carteTavolo.erase(card)
			card.queue_free()
			
		# Rimuove carta mano
		data.carteMano.erase(data.selectedHandCard)
		data.selectedHandCard.queue_free()

		# Reset selezioni
		data.selectedTableCards.clear()

		data.selectedHandCard = null

		data.currentTableSum = 0
		canGoForward = true
	else:
		data.currentTableSum = 0
		uiManager.updateTableVisuals()
		shouldGoBack = true


func update(_delta: float) -> void:
	if shouldGoBack:
		transitioned.emit(self, "SelezioneCarte")
	if canGoForward:
		transitioned.emit(self, "Fine")
