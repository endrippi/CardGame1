extends State
@onready var persoLabel : RichTextLabel = $"../../haiPersoLabel"
@onready var sfocatura_su_tutto: ColorRect = %sfocaturaSuTutto
@onready var backgroundMusic: AudioStreamPlayer = $"../../BackgroundMusic"
@onready var ui_manager: UiManager = $"../../UiManager"

# Called when the node enters the scene tree for the first time.
func enter(data : GameData, previousState : State) -> void:
	print("Hai perso! :(")
	persoLabel.visible = true
	sfocatura_su_tutto.visible = true
	backgroundMusic.pitch_scale = 0.8
	ui_manager.hideAllButtons()
