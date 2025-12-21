extends Node
class_name GridSlot

# The "Rules" of this specific slot
var coordinate: Vector2       
var target_number: int        
var target_letter: String     

# The State
var current_slab: SlabData = null
var is_locked: bool = false       # For "The Twin" boss
var temp_score_modifier: int = 0  # For "The Lich" boss (Decay)

func initialize(coords: Vector2, t_num: int, t_letter: String):
	coordinate = coords
	target_number = t_num
	target_letter = t_letter
	current_slab = null
	reset_round_state()

# New: Call this when wiping board or starting fresh
func reset_round_state():
	is_locked = false
	temp_score_modifier = 0

func is_empty() -> bool:
	return current_slab == null

func fill_slot(slab: SlabData):
	current_slab = slab

# New: Helper to get final score including decay
func get_calculated_score() -> int:
	if current_slab == null: return 0
	# Base card value + Any temporary decay/buff on this slot
	return current_slab.get_current_score() + temp_score_modifier
