extends Node


# References
@onready var grid_manager: GridManager = $"../GridManager"
@onready var run_manager: RunManager = $"../RunManager"
@onready var game_controller: GameController = $".."

# Configuration
var current_boss_id: int = 1

func apply_boss_attack(round_num: int):
	print("--- BOSS ATTACK TRIGGERED: ID %d ---" % current_boss_id)
	
	match current_boss_id:
		1: # The Guide
			pass # Tutorial, do nothing
			
		2: # The Twin (Lock 2 Slots)
			var slot1 = Vector2(randi() % 5, randi() % 5)
			var slot2 = Vector2(randi() % 5, randi() % 5)
			grid_manager.lock_slot(slot1)
			grid_manager.lock_slot(slot2)
			_show_boss_popup("Mirror Lock!", "2 Grid slots have been blocked.")

		3: # The Swarm (Add Junk to Deck)
			var bug = _create_bug_slab()
			run_manager.add_card_to_deck(bug) # Adds to draw pile immediately
			run_manager.add_card_to_deck(bug)
			_show_boss_popup("Infestation!", "2 Bugs added to your deck.")

		4: # The Wall (Increase Target)
			if round_num > 1:
				var increase = int(game_controller.target_score * 0.15)
				game_controller.target_score += increase
				_show_boss_popup("Fortify!", "Target Score increased by %d!" % increase)

		5: # The Mimic (Shuffle Letters)
			# We need a function in GridManager to swap column definitions
			grid_manager.shuffle_column_letters() 
			_show_boss_popup("Confusion!", "Column Letters have been swapped.")

		6: # The Giant (Destroy Center)
			grid_manager.destroy_slot_contents(Vector2(2,2))
			# Maybe lock it too so it can't be used
			grid_manager.lock_slot(Vector2(2,2))
			_show_boss_popup("STOMP!", "The Center slot was crushed.")

		7: # The Lich (Decay Board)
			grid_manager.apply_decay_to_all(-2)
			_show_boss_popup("Wither...", "All board slabs lost -2 Value.")

		8: # Death (Random)
			var random_boss = randi_range(2, 7)
			# Recursive call (dangerous but fun) - actually safer to just copy logic
			# For now, let's just say Death applies Decay + Lock
			grid_manager.apply_decay_to_all(-5)
			grid_manager.lock_slot(Vector2(2,2))

# Helper to make the Bug Slab on the fly
func _create_bug_slab() -> SlabData:
	var bug = SlabData.new()
	bug.id = "slab_bug"
	bug.display_name = "Bug"
	bug.base_score = -5
	bug.rarity = "Common"
	return bug

func _show_boss_popup(title: String, desc: String):
	# Connect to UI here
	print("BOSS: %s - %s" % [title, desc])
