extends Node
class_name ScoreManager

# Constants for the shapes
const GRID_SIZE = 5

# Data structure to track our permanent Payline Masteries (The permanent scaling)
# Key: String Name of line -> Value: float Multiplier
var permanent_multipliers: Dictionary = {
	"ROW_0": 0.0, "ROW_1": 0.0, "ROW_2": 0.0, "ROW_3": 0.0, "ROW_4": 0.0,
	"COL_0": 0.0, "COL_1": 0.0, "COL_2": 0.0, "COL_3": 0.0, "COL_4": 0.0,
	"DIAG_1": 0.0, "DIAG_2": 0.0, # 1 is Top-Left to Bot-Right
	"H_SHAPE": 0.0,
	"X_SHAPE": 0.0
}

# Signal to send the final calculated score back to the Game Controller
signal score_calculated(total_score, breakdown_data)

# Main Function: Called when player clicks "Score" button
# grid_data comes from GridManager.grid (Dictionary of Vector2 -> GridSlot)
func calculate_round_score(grid_data: Dictionary):
	var total_score: float = 0.0
	var breakdown = [] # To show the player detailed logs
	
	# 1. Identify which slots are used in Paylines
	var slots_used_in_lines = {} # Vector2 -> bool
	
	# We temporarily gather all valid lines to process
	var active_lines = _identify_valid_lines(grid_data)
	
	# Mark used slots so we know which are "Singles"
	for line_info in active_lines:
		for coords in line_info["coords"]:
			slots_used_in_lines[coords] = true

	# ---------------------------------------------------------
	# STEP 1: Score Single Spots (The Safe Money)
	# ---------------------------------------------------------
	for coords in grid_data:
		var slot = grid_data[coords]
		# Check if slot has a slab AND is NOT in a payline
		if not slot.is_empty() and not slots_used_in_lines.has(coords):
			var slab_val = _get_slab_score(slot)
			total_score += slab_val
			breakdown.append("Single Spot at %s: +%d" % [coords, slab_val])

	# ---------------------------------------------------------
	# STEP 2: Score Paylines (The Multipliers)
	# ---------------------------------------------------------
	for line in active_lines:
		var line_raw_score = 0
		var perfect_count = 0
		
		# A. Sum the raw values of slabs in this line
		for coords in line["coords"]:
			var slot = grid_data[coords]
			if not slot.is_empty():
				line_raw_score += _get_slab_score(slot)
				if _is_perfect(slot):
					perfect_count += 1
		
		# B. Calculate Multiplier
		# Formula: Base (0.0) + ArtifactPerms + (Perfects * 0.5)
		var perm_boost = permanent_multipliers.get(line["id"], 0.0)
		var perfect_boost = perfect_count * 0.5
		
		var final_mult = 0.0 + perm_boost + perfect_boost
		
		# C. Final Line Math
		var line_total = line_raw_score * final_mult
		
		# D. Scaling Logic (Add to permanent mastery if it scored > 0)
		if line_total > 0:
			_apply_permanent_growth(line["id"])
		
		total_score += line_total
		breakdown.append("%s: Raw(%d) x Mult(%.1f) = %d" % [line["id"], line_raw_score, final_mult, line_total])

	# ---------------------------------------------------------
	# STEP 3: Finish
	# ---------------------------------------------------------
	emit_signal("score_calculated", total_score, breakdown)
	print(breakdown) # Debug log

# --- Helper Functions ---

func _get_slab_score(slot: GridSlot) -> int:
	if slot.is_empty(): return 0
	var slab = slot.current_slab
	var val = slot.get_calculated_score()
	
	# Basic Matching Logic for raw value
	if slab.letter_type == slot.target_letter and slab.number_value == slot.target_number:
		return int((val + 10) * 1.5) # Perfect
	elif slab.letter_type == slot.target_letter:
		return int(val * 1.5)        # Match
	else:
		return val                   # Mismatch

func _is_perfect(slot: GridSlot) -> bool:
	if slot.is_empty(): return false
	return (slot.current_slab.letter_type == slot.target_letter and 
			slot.current_slab.number_value == slot.target_number)

func _apply_permanent_growth(line_id: String):
	# This handles the "Scaling" aspect. 
	# For now, let's say every successful score adds +0.01 to that line permanently.
	# We can hook Artifact logic here later.
	if permanent_multipliers.has(line_id):
		permanent_multipliers[line_id] += 0.01 # Adjustable value

# --- Shape Definitions ---

func _identify_valid_lines(grid_data: Dictionary) -> Array:
	var lines = []
	
	# 1. Vertical Columns (COL_0 to COL_4)
	for x in range(GRID_SIZE):
		var coords_list = []
		for y in range(GRID_SIZE):
			coords_list.append(Vector2(x,y))
		lines.append({"id": "COL_" + str(x), "coords": coords_list})
		
	# 2. Horizontal Rows (ROW_0 to ROW_4)
	for y in range(GRID_SIZE):
		var coords_list = []
		for x in range(GRID_SIZE):
			coords_list.append(Vector2(x,y))
		lines.append({"id": "ROW_" + str(y), "coords": coords_list})

	# 3. Diagonals
	var d1 = [] # Top-Left -> Bot-Right
	var d2 = [] # Top-Right -> Bot-Left
	for i in range(GRID_SIZE):
		d1.append(Vector2(i, i))
		d2.append(Vector2(4-i, i))
	lines.append({"id": "DIAG_1", "coords": d1})
	lines.append({"id": "DIAG_2", "coords": d2})

	# 4. H-SHAPE (Col 0 + Col 4 + Row 2)
	# Note: This is a complex shape. Some slots (0,2 and 4,2) overlap with verticals.
	# Standard logic: We count them again! Big points!
	var h_shape = []
	# Left Column
	for y in range(GRID_SIZE): h_shape.append(Vector2(0, y))
	# Right Column
	for y in range(GRID_SIZE): h_shape.append(Vector2(4, y))
	# Middle Bar (excluding existing corners to prevent double counting in the same array)
	h_shape.append(Vector2(1, 2))
	h_shape.append(Vector2(2, 2))
	h_shape.append(Vector2(3, 2))
	
	lines.append({"id": "H_SHAPE", "coords": h_shape})
	
	# 5. X-SHAPE (Diag 1 + Diag 2)
	var x_shape = d1.duplicate()
	for coord in d2:
		if not coord in x_shape: # Avoid adding center (2,2) twice
			x_shape.append(coord)
	lines.append({"id": "X_SHAPE", "coords": x_shape})

	return lines
