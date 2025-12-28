extends GridContainer

# Manages the 5x5 grid of rune cards

var cards: Array = []
var rune_card_script
var selected_cards: Array = []

signal card_selected(card)
signal cards_scored(total_score)

func _ready():
	# Load the rune card script
	rune_card_script = load("res://scripts/ui/rune_card.gd")
	
	columns = 5
	add_theme_constant_override("h_separation", 10)
	add_theme_constant_override("v_separation", 10)
	
	# Generate initial grid
	populate_grid()

func populate_grid():
	# Clear existing cards
	for child in get_children():
		child.queue_free()
	cards.clear()
	
	# Create 5x5 grid (25 cards)
	for row in range(5):
		for col in range(5):
			create_card(row, col)

func create_card(row: int, col: int):
	var card = PanelContainer.new()
	card.set_script(rune_card_script)
	
	# Randomly make some cards inactive (like the HTML)
	card.is_active = randf() > 0.4
	
	# Connect signals
	card.card_clicked.connect(_on_card_clicked)
	card.card_hovered.connect(_on_card_hovered)
	
	add_child(card)
	cards.append(card)
	
	# Start subtle pulse animation on active cards
	if card.is_active:
		card.call_deferred("pulse_glow")

func _on_card_clicked(card):
	if not card.is_active:
		return
	
	# Toggle selection
	if card in selected_cards:
		selected_cards.erase(card)
		# Visual feedback for deselection
	else:
		selected_cards.append(card)
		# Visual feedback for selection
	
	card_selected.emit(card)
	
	# Show score preview
	show_score_preview(card)

func _on_card_hovered(card):
	# Optional: show tooltip or highlight valid moves
	pass

func show_score_preview(card):
	# Calculate what this card would score
	var score = calculate_card_score(card)
	
	# Create floating score text (like the HTML)
	var score_label = Label.new()
	score_label.text = "+%d" % score
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	score_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	score_label.add_theme_constant_override("shadow_offset_x", 0)
	score_label.add_theme_constant_override("shadow_offset_y", 2)
	score_label.add_theme_constant_override("shadow_outline_size", 4)
	
	# Position above card
	var card_global_pos = card.global_position
	score_label.global_position = card_global_pos + Vector2(card.size.x / 2 - 30, -40)
	
	get_tree().root.add_child(score_label)
	
	# Animate upward and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(score_label, "position:y", score_label.position.y - 50, 1.0)
	tween.tween_property(score_label, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	score_label.queue_free()

func calculate_card_score(card) -> int:
	# Placeholder scoring logic
	return card.card_value if card.card_value > 0 else 250

func score_selected_cards():
	if selected_cards.is_empty():
		return
	
	var total_score = 0
	for card in selected_cards:
		total_score += calculate_card_score(card)
		# Animate card removal
		animate_card_removal(card)
	
	cards_scored.emit(total_score)
	selected_cards.clear()

func animate_card_removal(card):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(card, "scale", Vector2.ZERO, 0.3)
	tween.tween_property(card, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	card.set_active(false)
	card.scale = Vector2.ONE
	card.modulate.a = 1.0

func refill_grid():
	# Reactivate cards or spawn new ones
	for card in cards:
		if not card.is_active:
			card.randomize_rune()
			card.set_active(true)
			
			# Spawn animation
			card.scale = Vector2.ZERO
			var spawn = create_tween()
			spawn.set_ease(Tween.EASE_OUT)
			spawn.set_trans(Tween.TRANS_BACK)
			spawn.tween_property(card, "scale", Vector2.ONE, 0.4)
			
			card.call_deferred("pulse_glow")

func clear_selection():
	selected_cards.clear()
