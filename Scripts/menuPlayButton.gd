extends Button

@onready var label = %PlayLabel
@onready var cards = %Cards
@onready var backCard = %Back
@onready var titleBg = %TitleBG
@onready var title = %Title
@onready var playButton = %PlayButton
@onready var quitButton = %QuitButton

var tween : Tween  
const fadeDuration : float = 0.1
const cardFadeDuration : float = 0.2

func _ready() -> void:
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)

func resetTween() -> void:
	tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)

func animateCardsExiting() -> void:	
	resetTween()
	
	# If back card, first remove all that is on top in parallel with the card
	for element in cards.get_children():		
		if element == backCard:
			tween.parallel().tween_property(titleBg, "position:y", 1000, fadeDuration)
			tween.parallel().tween_property(title, "position:y", 1000, fadeDuration)
			tween.parallel().tween_property(playButton, "position:y", 1000, fadeDuration)
			tween.parallel().tween_property(quitButton, "position:y", 1000, fadeDuration)
		
		# Actually remove card
		tween.parallel().tween_property(element, "position:y", 1000, cardFadeDuration)
		await tween.finished
		resetTween()
		

func _on_pressed() -> void:
	await animateCardsExiting()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_mouse_entered() -> void:
	label.position += Vector2(0,5)


func _on_mouse_exited() -> void:
	label.position -= Vector2(0,5)
