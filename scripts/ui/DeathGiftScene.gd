extends Control

# UI References (Link in Editor)
@onready var card_container: HBoxContainer = $CenterContainer/HBox
@onready var karma_label: Label = $TopBar/KarmaLabel

# Data
var offered_gifts: Array = []

func _ready():
	_generate_offerings()
	_update_ui()

func _generate_offerings():
	# 1. Get all Death Gifts from DB
	var all_gifts = []
	for id in ItemDB.death_gifts_db:
		var gift = ItemDB.death_gifts_db[id]
		gift["id"] = id # Inject ID
		all_gifts.append(gift)
	
	# 2. Pick 3 Random ones
	all_gifts.shuffle()
	offered_gifts = all_gifts.slice(0, 3)

func _update_ui():
	# Clear old buttons
	for child in card_container.get_children():
		child.queue_free()
		
	# Create new buttons for the 3 gifts
	for gift_data in offered_gifts:
		var btn = Button.new()
		btn.text = "%s\n\n%s\n\nCost: %d Karma" % [gift_data.name, gift_data.desc, gift_data.cost]
		btn.custom_minimum_size = Vector2(200, 300)
		
		# Bind the click to the buy function
		btn.pressed.connect(_on_gift_selected.bind(gift_data))
		
		# Disable if too expensive
		if Global.player_karma < gift_data.cost:
			btn.disabled = true
			
		card_container.add_child(btn)

func _on_gift_selected(gift_data):
	# 1. Deduct Karma
	Global.player_karma -= gift_data.cost
	
	# 2. Apply the Permanent Effect
	_apply_gift_effect(gift_data.id)
	
	# 3. Move to Next Boss Loop
	LoopManager.on_death_gift_complete()

func _apply_gift_effect(id: String):
	match id:
		"gift_pocket":
			RunManager.CARDS_PER_ROUND += 1
		"gift_bias_low":
			# Set a global flag that GridManager checks during RNG
			Global.rng_bias = "LOW"
		"gift_uncapped":
			Global.score_cap_removed = true
	
	print("Death Gift Applied: " + id)
