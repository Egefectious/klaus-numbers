extends Node

# --- STATE ---
var current_shop_level: int = 0 # Increases as you beat bosses
var is_tutorial_shop: bool = true # The very first shop
var player_obols: int = 0

# --- SIGNALS ---
signal shop_generated(slabs_for_sale, artifacts_for_sale)
signal transaction_complete(item_data, type)

# --- GENERATION LOGIC ---

# Call this when entering a Shop Scene
func generate_shop_inventory():
	var slabs_for_sale = []
	var artifacts_for_sale = []
	
	# SCENARIO 1: The Tutorial Shop (Start of Game)
	if is_tutorial_shop:
		# Just 1 Free Common Slab
		var free_slab = _get_random_item("slabs", "Common", 0) # Unlock Level 0 only
		free_slab["cost"] = 0 # It's free
		slabs_for_sale.append(free_slab)
		
		is_tutorial_shop = false # Next shop will be normal
		emit_signal("shop_generated", slabs_for_sale, [])
		return

	# SCENARIO 2: Normal Shop (Between Encounters)
	# Determine how many items based on Boss Level
	var slab_count = 3 + (current_shop_level / 2) # 3, 3, 4, 4...
	var artifact_count = 1 + (current_shop_level / 3) # 1, 1, 2...
	
	# 1. Populate Slabs
	for i in range(slab_count):
		# Rolling Rarity based on Shop Level
		var rarity = _roll_rarity(current_shop_level)
		var item = _get_random_item("slabs", rarity, current_shop_level)
		if item: slabs_for_sale.append(item)
		
	# 2. Populate Artifacts
	for i in range(artifact_count):
		var rarity = _roll_rarity(current_shop_level)
		var item = _get_random_item("artifacts", rarity, current_shop_level)
		if item: artifacts_for_sale.append(item)
		
	emit_signal("shop_generated", slabs_for_sale, artifacts_for_sale)


# --- HELPER FUNCTIONS ---

func _roll_rarity(level: int) -> String:
	var rand = randi() % 100
	# As level gets higher, chances improve
	if rand < (60 - level * 2): return "Common"
	if rand < (85 - level): return "Uncommon"
	if rand < (97): return "Rare"
	return "Legendary"

func _get_random_item(type: String, target_rarity: String, max_unlock_level: int):
	var db_node = get_node("/root/ItemDB") # Force find the node
	var database = db_node.slabs_db if type == "slabs" else db_node.artifacts_db
	var pool = []
	
	# Filter Database
	for id in database:
		var item = database[id]
		# Check 1: Is it the right rarity?
		# Check 2: Is it unlocked? (Item Level <= Current Boss Level)
		if item.rarity == target_rarity and item.unlock_boss <= max_unlock_level:
			var item_copy = item.duplicate()
			item_copy["id"] = id # Add ID to the data passed to UI
			pool.append(item_copy)
			
	if pool.is_empty():
		# Fallback to Common if no Legendary found
		if target_rarity != "Common": 
			return _get_random_item(type, "Common", max_unlock_level)
		return null
		
	return pool.pick_random()

# --- TRANSACTION LOGIC ---

# Called when player clicks a Slab in the UI
func attempt_buy_slab(slab_data: Dictionary) -> bool:
	var cost = slab_data.cost
	
	# Check affordability
	if Global.player_obols >= cost:
		# 1. Pay
		Global.player_obols -= cost
		
		# 2. Convert Dictionary data back into a real Resource
		var new_slab = SlabData.new()
		new_slab.id = slab_data.id
		new_slab.display_name = slab_data.name
		# (You would fill in the rest of the stats from ItemDB here usually, 
		# or just use the data passed in if it's complete)
		
		# 3. Give to Player
		RunManager.add_slab_to_deck(new_slab)
		
		return true # Purchase Successful
	else:
		print("Not enough Obols!")
		return false # Failed

# Called when player clicks an Artifact
func attempt_buy_artifact(artifact_data: Dictionary) -> bool:
	var cost = artifact_data.cost
	
	if Global.player_obols >= cost:
		if Global.player_artifacts.size() >= 5:
			print("Inventory Full!")
			return false
			
		Global.player_obols -= cost
		RunManager.add_artifact(artifact_data.id)
		return true
	
	return false
