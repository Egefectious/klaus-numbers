extends Node
class_name GameController

# References to our child managers
@onready var grid_manager: GridManager = $GridManager
@onready var run_manager: RunManager = $RunManager
@onready var score_manager: ScoreManager = $ScoreManager

# References to UI (You'll link these in Editor)
@onready var ui_message_log: Label = $UI/MessageLog 

# State
var total_run_score: int = 0
var target_score: int = 5000 # Example target for Encounter 1

func _ready():
	# 1. Initialize a test deck (We will make a real one later)
	var starter_deck = DeckFactory.create_starter_deck()
	
	# 2. Start the game loop
	run_manager.start_encounter(starter_deck)
	grid_manager.start_new_encounter() # Fills the grid with targets
	
	# 3. Connect Signals
	run_manager.connect("slab_drawn", _on_slab_drawn)
	
func _on_slab_drawn(slab: SlabData):
	# Update UI to show the slab hovering
	print("Player drew: %s %d" % [slab.letter_type, slab.number_value])

# --- Input Handling (The Player's Clicks) ---

# Called when player clicks a Grid Slot
func _on_grid_slot_clicked(coords: Vector2):
	# CASE 1: Player is holding a Just-Drawn Slab
	if run_manager.current_slab_holding != null:
		var slab = run_manager.play_holding()
		grid_manager.place_slab_on_grid(coords, slab)
		
	# CASE 2: Player selected a Slab from Bench (UI logic required here)
	# For now, let's assume we have a variable 'selected_bench_slab_index'
	# var slab = run_manager.play_from_bench(index)
	# grid_manager.place_slab_on_grid(coords, slab)

# Called when player clicks "Score" Button
func _on_score_button_pressed():
	# 1. Calculate Score
	score_manager.calculate_round_score(grid_manager.grid)
	
	# 2. Wait for signal back (see below)

# Connect this to ScoreManager "score_calculated"
func _on_score_calculated(score_val: float, breakdown: Array):
	total_run_score += int(score_val)
	print("Scored this round: %d | Total: %d" % [score_val, total_run_score])
	
	# Logic: Did we beat the Boss?
	if total_run_score >= target_score:
		print(">>> ENCOUNTER WON! <<<")
		run_manager.end_encounter()
		# TODO: Trigger Shop Scene
	else:
		# Logic: Continue to next round
		var next_round = run_manager.current_round + 1
		
		if next_round > 3:
			print(">>> ENCOUNTER FAILED (Out of rounds) <<<")
			# TODO: Trigger Game Over or Death Gift screen
		else:
			print(">>> Board Wiped & Targets Rerolled. Starting Round %d <<<" % next_round)
			
			# 1. Reroll the grid targets
			grid_manager.reroll_grid_targets()
			
			# 2. Tell RunManager to reset draws for the new round
			run_manager.start_round(next_round)
