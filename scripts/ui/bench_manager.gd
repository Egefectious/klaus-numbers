extends Control

# Manages bench cards in a fan layout

var bench_card_script
var bench_cards: Array = []
const MAX_BENCH_SIZE = 6

signal bench_card_selected(card)

func _ready():
	bench_card_script = load("res://scripts/ui/bench_card.gd")
	custom_minimum_size = Vector2(0, 200)
	populate_bench()

func populate_bench():
	# Clear existing
	for child in get_children():
		child.queue_free()
	bench_cards.clear()
	
	# Create 6 bench cards
	for i in range(MAX_BENCH_SIZE):
		create_bench_card(i)

func create_bench_card(index: int):
	var card = PanelContainer.new()
	card.set_script(bench_card_script)
	
	# Calculate fan position and rotation
	var center_x = size.x / 2
	var card_width = 80
	var spacing = 90
	var total_width = (MAX_BENCH_SIZE - 1) * spacing
	var start_x = center_x - total_width / 2
	
	# Position
	var x_pos = start_x + index * spacing
	var y_offset = abs(index - (MAX_BENCH_SIZE - 1) / 2.0) * 5  # Arc effect
	
	card.position = Vector2(x_pos, size.y - 130 + y_offset)
	
	# Rotation for fan effect
	var rotation_deg = (index - (MAX_BENCH_SIZE - 1) / 2.0) * 3
	card.rotation_angle = rotation_deg
	
	# Connect signal
	card.bench_card_clicked.connect(_on_bench_card_clicked)
	
	add_child(card)
	bench_cards.append(card)

func _on_bench_card_clicked(card):
	bench_card_selected.emit(card)
	# Play selection animation
	flash_selection(card)

func flash_selection(card):
	var flash_tween = create_tween()
	flash_tween.tween_property(card, "modulate", Color(1.5, 1.5, 1.5), 0.1)
	flash_tween.tween_property(card, "modulate", Color.WHITE, 0.2)

func add_card_to_bench(rune_symbol: String, rune_color: Color):
	if bench_cards.size() >= MAX_BENCH_SIZE:
		return  # Bench full
	
	var card = PanelContainer.new()
	card.set_script(bench_card_script)
	card.rune_symbol = rune_symbol
	card.rune_color = rune_color
	
	# Position at the end
	var index = bench_cards.size()
	var center_x = size.x / 2
	var spacing = 90
	var total_width = (MAX_BENCH_SIZE - 1) * spacing
	var start_x = center_x - total_width / 2
	var x_pos = start_x + index * spacing
	var y_offset = abs(index - (MAX_BENCH_SIZE - 1) / 2.0) * 5
	
	card.position = Vector2(x_pos, size.y - 130 + y_offset)
	card.rotation_angle = (index - (MAX_BENCH_SIZE - 1) / 2.0) * 3
	
	card.bench_card_clicked.connect(_on_bench_card_clicked)
	
	add_child(card)
	bench_cards.append(card)
	
	# Spawn animation
	card.scale = Vector2.ZERO
	var spawn = create_tween()
	spawn.set_ease(Tween.EASE_OUT)
	spawn.set_trans(Tween.TRANS_BACK)
	spawn.tween_property(card, "scale", Vector2.ONE, 0.4)

func remove_card(card):
	if card not in bench_cards:
		return
	
	bench_cards.erase(card)
	
	# Remove animation
	var remove_tween = create_tween()
	remove_tween.set_parallel(true)
	remove_tween.tween_property(card, "scale", Vector2.ZERO, 0.3)
	remove_tween.tween_property(card, "modulate:a", 0.0, 0.3)
	
	await remove_tween.finished
	card.queue_free()
	
	# Reposition remaining cards
	reposition_cards()

func reposition_cards():
	for i in range(bench_cards.size()):
		var card = bench_cards[i]
		var center_x = size.x / 2
		var spacing = 90
		var total_width = (MAX_BENCH_SIZE - 1) * spacing
		var start_x = center_x - total_width / 2
		var x_pos = start_x + i * spacing
		var y_offset = abs(i - (MAX_BENCH_SIZE - 1) / 2.0) * 5
		
		var reposition = create_tween()
		reposition.set_parallel(true)
		reposition.tween_property(card, "position", Vector2(x_pos, size.y - 130 + y_offset), 0.3)
		reposition.tween_property(card, "rotation_degrees", (i - (MAX_BENCH_SIZE - 1) / 2.0) * 3, 0.3)
