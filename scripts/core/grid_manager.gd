extends Node


# Configuration
const GRID_SIZE = 5
const LETTERS = ["L", "I", "M", "B", "O"]

# The Data: A Dictionary mapping Vector2 -> GridSlot
var grid: Dictionary = {}

# Signal to tell UI to update (we keep UI code separate!)
signal grid_generated(grid_data)
signal slab_placed(coordinate, slab, score_result)

func _ready():
	# We don't generate immediately, we wait for the game loop to call it
	pass

# 1. Generate a new Encounter Board
func start_new_encounter():
	grid.clear()
	
	for x in range(GRID_SIZE):
		# Generate a unique list of numbers 1-15 for this column (Row in visual, but Col in data)
		var column_numbers = _get_random_unique_numbers(GRID_SIZE, 1, 15)
		var letter = LETTERS[x]
		
		for y in range(GRID_SIZE):
			var coords = Vector2(x, y)
			var slot = GridSlot.new() # Create the small data container
			
			# Assign the random unique number
			slot.initialize(coords, column_numbers[y], letter)
			
			grid[coords] = slot
			
	emit_signal("grid_generated", grid)

# 2. Logic to place a slab
func place_slab_on_grid(coords: Vector2, slab: SlabData):
	if not grid.has(coords):
		return # Error safety
		
	var slot: GridSlot = grid[coords]
	
	if not slot.is_empty():
		print("Slot occupied!")
		return

	# Place it
	slot.fill_slot(slab)
	slab.on_played() # Trigger the scaling counter
	
	# Calculate Immediate Score (Visual Feedback)
	var score_data = _calculate_placement_score(slot, slab)
	emit_signal("slab_placed", coords, slab, score_data)

# 3. Helper: Math for scoring a single placement
func _calculate_placement_score(slot: GridSlot, slab: SlabData) -> Dictionary:
	var result = {
		"score": 0,
		"type": "MISMATCH"
	}
	
	var val = slab.get_current_score()
	
	# Logic from your GDD
	if slab.letter_type == slot.target_letter and slab.number_value == slot.target_number:
		result["type"] = "PERFECT"
		result["score"] = (val + 10) * 1.5
	
	elif slab.letter_type == slot.target_letter:
		result["type"] = "MATCH"
		result["score"] = val * 1.5
		
	else:
		result["type"] = "MISMATCH"
		result["score"] = val
		
	return result

# Utility: Get X unique random numbers
func _get_random_unique_numbers(count: int, min_val: int, max_val: int) -> Array:
	var pool = []
	for i in range(min_val, max_val + 1):
		pool.append(i)
	pool.shuffle()
	return pool.slice(0, count)

# --- Add this to res://scripts/core/grid_manager.gd ---

# Call this when the player hits "SCORE" and the board wipes
func reroll_grid_targets():
	# 1. Clear the dictionary but keep the structure? 
	# Actually, easier to just regenerate the data from scratch.
	grid.clear()
	
	print("--- REROLLING GRID TARGETS ---")
	
	for x in range(GRID_SIZE):
		# Reroll unique numbers for this column (visual row)
		var column_numbers = _get_random_unique_numbers(GRID_SIZE, 1, 15)
		var letter = LETTERS[x]
		
		for y in range(GRID_SIZE):
			var coords = Vector2(x, y)
			var slot = GridSlot.new()
			
			# New Target Number is assigned here
			slot.initialize(coords, column_numbers[y], letter)
			
			grid[coords] = slot
			
	emit_signal("grid_generated", grid)

# Helper to remove slabs but keep targets (If we ever need it)
func clear_slabs_only():
	for coords in grid:
		grid[coords].current_slab = null
	# Note: We likely won't use this often if we are rerolling targets on wipe.

# --- BOSS MECHANICS ---

# 1. Lock a specific slot (The Twin)
func lock_slot(coords: Vector2):
	if grid.has(coords):
		var slot = grid[coords]
		slot.is_locked = true
		print("Grid Slot Locked: ", coords)
		# TODO: Add visual lock sprite here later

# 2. Shuffle Column Letters (The Mimic)
func shuffle_column_letters():
	# Standard order is L, I, M, B, O
	var new_order = LETTERS.duplicate()
	new_order.shuffle() # e.g. becomes ["B", "L", "O", "M", "I"]
	
	print("Boss shuffled columns to: ", new_order)
	
	# Apply new letters to the existing grid
	for x in range(GRID_SIZE):
		var new_letter = new_order[x]
		for y in range(GRID_SIZE):
			var coords = Vector2(x, y)
			if grid.has(coords):
				grid[coords].target_letter = new_letter

# 3. Decay all placed slabs (The Lich)
func apply_decay_to_all(amount: int):
	for coords in grid:
		var slot = grid[coords]
		if not slot.is_empty():
			# We apply it to the SLOT, not the Slab Resource
			# (So we don't permanently ruin the card in your deck)
			slot.temp_score_modifier += amount
			print("Applied decay %d to %s" % [amount, coords])

# 4. Destroy Contents (The Giant)
func destroy_slot_contents(coords: Vector2):
	if grid.has(coords):
		var slot = grid[coords]
		if not slot.is_empty():
			print("Boss destroyed slab at: ", coords)
			slot.current_slab = null # Poof, gone.
			slot.temp_score_modifier = 0
			
