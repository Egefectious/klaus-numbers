extends Node


# --- Configuration ---
const MAX_BENCH_SIZE = 5         # Can be upgraded via Artifacts later
static var CARDS_PER_ROUND = 6      # Total draws allowed per round

# --- State Data ---
var deck: Array[SlabData] = []         # The full 75+ cards
var draw_pile: Array[SlabData] = []    # Current pile to draw from
var discard_pile: Array[SlabData] = [] # Used cards
var bench: Array[SlabData] = []        # The "Hand" that persists

var current_draws_left: int = 6
var current_round: int = 1             # 1, 2, or 3
var current_slab_holding: SlabData = null # The slab currently being "dragged" or decided on

signal slab_drawn(slab)
signal bench_updated(bench_array)
signal draws_changed(current, max_draws)

# --- 1. Encounter Setup ---
func start_encounter(full_deck: Array[SlabData]):
	deck = full_deck.duplicate()
	_reset_draw_pile()
	
	# The Bench is empty at the VERY start of an encounter
	bench.clear()
	emit_signal("bench_updated", bench)
	
	start_round(1)

func start_round(round_num: int):
	current_round = round_num
	current_draws_left = CARDS_PER_ROUND
	emit_signal("draws_changed", current_draws_left, CARDS_PER_ROUND)
	print("--- ROUND %d START ---" % round_num)

# --- 2. The Core Action: Draw 1 Slab ---
func draw_slab():
	if current_draws_left <= 0:
		print("No draws left this round!")
		return
		
	if current_slab_holding != null:
		print("Already holding a slab! Place it first.")
		return

	if draw_pile.is_empty():
		_reshuffle_discard_into_draw()

	if draw_pile.is_empty():
		print("Deck is empty!") # Should rarely happen with 75 cards
		return

	# Actual Draw Logic
	var slab = draw_pile.pop_back()
	current_slab_holding = slab
	current_draws_left -= 1
	
	emit_signal("slab_drawn", slab)
	emit_signal("draws_changed", current_draws_left, CARDS_PER_ROUND)

# --- 3. The Decision: Bench or Grid? ---

# Option A: Move Holding -> Bench
func move_holding_to_bench():
	if current_slab_holding == null: return
	
	if bench.size() >= MAX_BENCH_SIZE:
		print("Bench is full! Must place on Grid or Sell.")
		return
		
	bench.append(current_slab_holding)
	current_slab_holding = null # Hand is empty, ready to draw again
	emit_signal("bench_updated", bench)

# Option B: Play from Bench -> Grid
# (This is called when player drags a slab FROM the bench TO the grid)
func play_from_bench(slab_index: int) -> SlabData:
	if slab_index < 0 or slab_index >= bench.size():
		return null
		
	var slab = bench.pop_at(slab_index)
	emit_signal("bench_updated", bench)
	return slab

# Option C: Play Holding -> Grid
# (This just returns the slab so GridManager can take it)
func play_holding() -> SlabData:
	var slab = current_slab_holding
	current_slab_holding = null
	return slab

# --- 4. End of Round Logic ---

# Call this if Player chooses "SCORE"
func on_score_and_wipe():
	# Note: We DO NOT clear the bench here. 
	# Bench persists. Only the Grid (handled by GridManager) wipes.
	pass

# Call this if Encounter is WON or LOST (Boss beaten)
func end_encounter():
	bench.clear() # NOW we wipe the bench
	draw_pile.clear()
	discard_pile.clear()

# --- Helpers ---
func _reset_draw_pile():
	draw_pile = deck.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()

func _reshuffle_discard_into_draw():
	draw_pile = discard_pile.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()

# --- DECK MODIFICATION ---

# Called when buying from Shop or getting a Death Gift
func add_slab_to_deck(slab_data: SlabData):
	deck.append(slab_data)
	print("Added %s to deck. Total count: %d" % [slab_data.display_name, deck.size()])

# Called when using "Remove" services or specialized events
func remove_slab_from_deck(slab_data: SlabData):
	if deck.has(slab_data):
		deck.erase(slab_data)
		print("Removed %s from deck." % slab_data.display_name)

# Called when buying an Artifact
func add_artifact(artifact_id: String):
	# We might need an array for artifacts in RunManager or Global
	# Let's assume Global has an array for now
	if Global.player_artifacts.size() < 5:
		Global.player_artifacts.append(artifact_id)
		print("Artifact %s obtained!" % artifact_id)
		# TODO: Trigger the passive effect immediately if needed
	else:
		print("Artifact slots full!")
