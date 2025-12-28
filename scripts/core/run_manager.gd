extends Node

# --- Configuration ---
const MAX_BENCH_SIZE = 5
var max_draws = 6  # Renamed from CARDS_PER_ROUND and removed 'static'

# --- State Data ---
var deck: Array[SlabData] = []
var draw_pile: Array[SlabData] = []
var discard_pile: Array[SlabData] = []
var bench: Array[SlabData] = []

var current_draws_left: int = 6
var current_round: int = 1
var current_slab_holding: SlabData = null

signal slab_drawn(slab)
signal bench_updated(bench_array)
signal draws_changed(current, max_draws)
signal new_round_started(round_num)

# --- 1. Encounter Setup ---
func start_encounter(full_deck: Array[SlabData]):
	deck = full_deck.duplicate()
	_reset_draw_pile()
	bench.clear()
	emit_signal("bench_updated", bench)
	start_round(1)

func start_round(round_num: int):
	current_round = round_num
	current_draws_left = max_draws
	current_slab_holding = null
	# Emit updates
	emit_signal("draws_changed", current_draws_left, max_draws)
	emit_signal("new_round_started", round_num)
	
	print("--- ROUND %d START ---" % round_num)

# --- 2. Action: Draw 1 Slab ---
func draw_slab():
	if current_draws_left <= 0:
		print("No draws left!")
		return
	if current_slab_holding != null:
		print("Place holding slab first.")
		return
	if draw_pile.is_empty():
		_reshuffle_discard_into_draw()
	if draw_pile.is_empty():
		return

	var slab = draw_pile.pop_back()
	current_slab_holding = slab
	current_draws_left -= 1
	emit_signal("slab_drawn", slab)
	emit_signal("draws_changed", current_draws_left, max_draws)

# --- 3. Decisions ---
func move_holding_to_bench():
	if current_slab_holding == null: return
	if bench.size() >= MAX_BENCH_SIZE:
		print("Bench full!")
		return
	bench.append(current_slab_holding)
	current_slab_holding = null
	emit_signal("bench_updated", bench)

func play_from_bench(slab_index: int) -> SlabData:
	if slab_index < 0 or slab_index >= bench.size(): return null
	var slab = bench.pop_at(slab_index)
	emit_signal("bench_updated", bench)
	return slab

func play_holding() -> SlabData:
	var slab = current_slab_holding
	current_slab_holding = null
	return slab

# --- 4. End Logic ---
func on_score_and_wipe():
	pass 

func end_encounter():
	bench.clear()
	draw_pile.clear()
	discard_pile.clear()

func _reset_draw_pile():
	draw_pile = deck.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()

func _reshuffle_discard_into_draw():
	draw_pile = discard_pile.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()

# --- Deck Mods ---
func add_slab_to_deck(slab_data: SlabData):
	deck.append(slab_data)

func remove_slab_from_deck(slab_data: SlabData):
	if deck.has(slab_data): deck.erase(slab_data)

func add_artifact(artifact_id: String):
	if Global.player_artifacts.size() < 5:
		Global.player_artifacts.append(artifact_id)
