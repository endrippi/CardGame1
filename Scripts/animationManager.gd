extends Node

@onready var gameData: GameData = %GameData
@onready var scopaAnimation = %ScopaAnimation

func animateCardRow(isHand, delta, time, sineOffsetMult, cosineOffsetMult, timeMultiplier) -> float:
	time += delta
	var i = 0
	var cards
	if isHand:
		cards = gameData.carteMano
	else:
		cards = gameData.carteTavolo
	
	for card in cards:
		# Sine function to make it "float" regularly
		var val: float = sin(i + (time * timeMultiplier))
		#print('card ', i, ' with val :', val)
		card.position.y += val * sineOffsetMult
		# Also rotate
		card.rotation += cos(i + (time * timeMultiplier)) * cosineOffsetMult
		i += 1
		
	return time

func playScopaAnimation() -> void:
	scopaAnimation.show()
	scopaAnimation.frame = 0
	scopaAnimation.play("default")
	await scopaAnimation.animation_finished
	scopaAnimation.hide()
	
func checkAndWaitScopaAnimation() -> void:
	if scopaAnimation.is_playing():
		await scopaAnimation.animation_finished

	
	
