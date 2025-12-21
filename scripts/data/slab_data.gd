extends Resource
class_name SlabData

# Identity
@export var id: String = "slab_standard"
@export var display_name: String = "Standard Slab"
@export_multiline var description: String = ""
@export_enum("Common", "Uncommon", "Rare", "Legendary") var rarity: String = "Common"

# Core Stats
@export_enum("L", "I", "M", "B", "O", "WILD") var letter_type: String = "L"
@export var number_value: int = 1         # 1-15
@export var base_score: int = 10

# Scaling Logic
@export var times_played: int = 0         # Saved across runs/games
@export var is_special: bool = false      # If true, triggers special effect logic

# Functions for scaling (Growth logic)
func get_current_score() -> int:
	var total = base_score
	
	# Example: Standard scaling (Coal Slab, etc.)
	# We can expand this later for specific IDs
	if id == "slab_coal":
		total += (times_played * 2)
		
	return total

func on_played():
	times_played += 1
