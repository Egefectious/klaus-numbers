extends Node

# State
var total_run_score: int = 0
var target_score: int = 5000 

func _ready():
	# 1. Connect to ScoreManager (THIS WAS MISSING!)
	if not ScoreManager.is_connected("score_calculated", _on_score_calculated):
		ScoreManager.connect("score_calculated", _on_score_calculated)

	# 2. Initialize deck
	var starter_deck = DeckFactory.create_starter_deck()
	
	# 3. Start the game loop
	call_deferred("_start_game", starter_deck)

func _start_game(deck):
	RunManager.start_encounter(deck)
	GridManager.start_new_encounter()

# --- INPUT HANDLERS ---

func _on_grid_slot_clicked(coords: Vector2):
	if RunManager.current_slab_holding != null:
		var slab = RunManager.play_holding()
		GridManager.place_slab_on_grid(coords, slab)
	else:
		print("No slab selected!")

func _on_score_button_pressed():
	# This triggers the calculation
	ScoreManager.calculate_round_score(GridManager.grid)

# --- GAME LOOP LOGIC ---

func _on_score_calculated(score_val: float, breakdown: Array):
	# Now this will actually run!
	total_run_score += int(score_val)
	print("Scored: %d | Total: %d" % [score_val, total_run_score])
	
	if total_run_score >= target_score:
		print(">>> ENCOUNTER WON! <<<")
		RunManager.end_encounter()
		# TODO: Load Shop Scene here
	else:
		# Advance to next round
		var next_round = RunManager.current_round + 1
		
		if next_round > 3:
			print(">>> ENCOUNTER FAILED <<<")
			# TODO: Game Over Logic
		else:
			print(">>> Starting Round %d <<<" % next_round)
			
			# 1. Clear Board & New Targets
			GridManager.reroll_grid_targets()
			
			# 2. Reset Draws
			RunManager.start_round(next_round)
