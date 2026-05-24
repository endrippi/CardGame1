extends State
@onready var ui_manager: UiManager = $"../../UiManager"

@onready var vintoLabel: RichTextLabel = $"../../haiVintoLabel"
@onready var sfocatura_su_tutto: ColorRect = %sfocaturaFinePartita
@onready var backgroundMusic: AudioStreamPlayer = $"../../BackgroundMusic"

# Called when the node enters the scene tree for the first time.
func enter(data : GameData, previousState : State) -> void:
	print("Hai vinto!!! :)")
	vintoLabel.visible = true
	sfocatura_su_tutto.visible = true
	ui_manager.hideAllButtons()
