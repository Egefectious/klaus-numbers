extends Node

enum GameState { START, SHOP, ENCOUNTER, DEATH_GIFT, BOSS_FIGHT, GAME_OVER }

var current_state = GameState.START
var current_boss_index: int = 1 # 1 to 8 (7 Disciples + Death)
var current_encounter_index: int = 1 # 1 to 3 per Boss
var bosses_defeated: int = 0

# The Narrative Names
var boss_names = {
	1: "The Guide", # Tutorial Boss
	2: "The Twin",
	3: "The Swarm",
	4: "The Wall",
	5: "The Mimic",
	6: "The Giant",
	7: "The Lich",
	8: "DEATH"
}

func start_new_run():
	current_boss_index = 1
	current_encounter_index = 1
	ShopManager.is_tutorial_shop = true
	load_scene("ShopScene") # Goes to the free slab shop

# Called when "Next" button is clicked in Shop
func on_shop_finished():
	current_state = GameState.ENCOUNTER
	load_scene("EncounterScene")
	# Setup the encounter parameters (Target Score, etc.) based on boss_index

# Called when Encounter is Won
func on_encounter_won():
	current_encounter_index += 1
	
	# Check: Was this the 3rd encounter (The Boss Fight)?
	if current_encounter_index > 3:
		# BOSS DEFEATED
		bosses_defeated += 1
		current_boss_index += 1
		current_encounter_index = 1
		
		ShopManager.current_shop_level = bosses_defeated
		
		# Trigger Death Gift Scene instead of Shop
		current_state = GameState.DEATH_GIFT
		load_scene("DeathGiftScene")
	else:
		# Just a normal round win, go to Shop
		current_state = GameState.SHOP
		load_scene("ShopScene")

func load_scene(scene_name: String):
	print("Loading: " + scene_name)
	# get_tree().change_scene_to_file("res://scenes/" + scene_name + ".tscn")

func on_death_gift_complete():
	print("Death Gift Selected. Moving to Next Boss...")
	# Reset for next boss
	current_encounter_index = 1
	# Move to the Shop logic for the new Boss
	current_state = GameState.SHOP
	load_scene("ShopScene")
