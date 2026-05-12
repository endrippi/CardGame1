class_name UiManager extends Node
@onready var game_data: GameData = $"../GameData"

@onready var discardsLabel: Label = %Discards
@onready var counterCarte: Label = %counterCarte
@onready var numero_punti: Label = %numeroPunti
@onready var debug_valore_mano: Label = %DebugValoreMano
@onready var debug_valore_tavolo: Label = %DebugValoreTavolo
@onready var label: Label = %Label
@onready var discardButton: Button = %discard
@onready var place_table: Button = %PlaceTable
@onready var undoDiscardButton: Button = %UndoDiscard
@onready var confirmDiscardButton: Button = %ConfirmDiscard
@onready var labelCardsDiscard: Label = %labelCardsDiscard
@onready var playButton: Button = %PlayButton
@onready var sfocatura: ColorRect = %sfocatura
@onready var placeOnTableButton: Button = $"../placeOnTableButton"




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
	placeOnTableButton.visible = !val

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
