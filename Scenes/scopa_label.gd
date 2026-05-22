extends RichTextLabel

var labelText : String = "[wave]SCOPA![/wave]"
var revealSpeed := 0.03

func _ready():
	bbcode_enabled = true
	text = labelText
	visible_characters = 0
	#reveal_text()

func startTextAnimation() -> void:
	reveal_text()

func reveal_text() -> void:
	show()
	while visible_characters < get_total_character_count():
		visible_characters += 1
		await get_tree().create_timer(revealSpeed).timeout
