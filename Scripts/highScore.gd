extends Node

var highscore: int = 0
const SAVE_PATH = "user://highscore.save"

func _ready():
	# Carica l'highscore non appena il nodo viene inizializzato
	load_highscore()

# Funzione da chiamare quando il giocatore batte il record
func save_highscore(new_score: int):
	highscore = new_score
	# Apri il file in modalità scrittura (sovrascrive il file esistente)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file:
		# Salva l'intero come intero a 32 bit
		file.store_32(highscore)
		print("Highscore salvato con successo: ", highscore)
	else:
		print("Errore durante il salvataggio del file.")

# Funzione per recuperare il record
func load_highscore() -> int:
	# Controlla prima se il file esiste
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			# Legge l'intero a 32 bit salvato
			highscore = file.get_32()
			print("Highscore caricato: ", highscore)
	else:
		print("Nessun salvataggio trovato. Imposto l'highscore a 80.")
		highscore = 80
	
	return highscore
