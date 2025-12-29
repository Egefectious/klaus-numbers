extends Control

# UI References
@onready var grid_board: GridContainer = $MainLayout/ContentGrid/CenterPanel/GridContainer/GridBoard
@onready var bench_area: Control = $MainLayout/ContentGrid/CenterPanel/BenchSection/BenchArea
@onready var score_lbl: PanelContainer = $MainLayout/ContentGrid/RightPanel/StatsPanel/StatsContent/ScoreStat
@onready var target_lbl: PanelContainer = $MainLayout/ContentGrid/RightPanel/StatsPanel/StatsContent/TargetStat
@onready var round_lbl: PanelContainer = $MainLayout/ContentGrid/RightPanel/StatsPanel/StatsContent/SmallStatsRow/RoundStat
@onready var draws_lbl: PanelContainer = $MainLayout/ContentGrid/RightPanel/StatsPanel/StatsContent/DrawsStat
@onready var active_slab_slot: PanelContainer = $MainLayout/ContentGrid/RightPanel/ActiveSlabSlot

var slab_scene = preload("res://scenes/ui/SlabUI.tscn")


# Store references to grid buttons for easy access
var grid_buttons: Dictionary = {}

func _ready():
	# 1. Connect Managers
	if not GridManager.is_connected("grid_generated", _on_grid_generated):
		GridManager.connect("grid_generated", _on_grid_generated)
	if not GridManager.is_connected("slab_placed", _on_slab_placed):
		GridManager.connect("slab_placed", _on_slab_placed)
		
	if not RunManager.is_connected("slab_drawn", _on_slab_drawn):
		RunManager.connect("slab_drawn", _on_slab_drawn)
	if not RunManager.is_connected("bench_updated", _on_bench_updated):
		RunManager.connect("bench_updated", _on_bench_updated)
	if not RunManager.is_connected("new_round_started", _on_round_update):
		RunManager.connect("new_round_started", _on_round_update)
	if not RunManager.is_connected("draws_changed", _on_draws_changed):
		RunManager.connect("draws_changed", _on_draws_changed)
		
	if not ScoreManager.is_connected("score_calculated", _on_score_update):
		ScoreManager.connect("score_calculated", _on_score_update)
	
	# 2. Connect Buttons
	var actions = $MainLayout/ContentGrid/RightPanel/ActionsBox
	actions.get_node("DRAW").pressed.connect(func(): RunManager.draw_slab())
	actions.get_node("BENCH").pressed.connect(func(): RunManager.move_holding_to_bench())
	actions.get_node("SCORE").pressed.connect(func(): GameController._on_score_button_pressed())

	# 3. Refresh Visuals (in case of reload)
	if not GridManager.grid.is_empty():
		_on_grid_generated(GridManager.grid)
	if not RunManager.bench.is_empty():
		_on_bench_updated(RunManager.bench)

# --- VISUAL GENERATION ---

func _on_grid_generated(grid_data: Dictionary):
	# Clear board
	for c in grid_board.get_children(): 
		c.queue_free()
	grid_buttons.clear()
	
	# Rebuild 5x5 Grid with new button system
	for y in range(5):
		for x in range(5):
			var coords = Vector2(x, y)
			var slot_data = grid_data.get(coords)
			
			# Create custom slot button
			var slot_btn = Button.new()
			slot_btn.set_script(slot_button_script)
			slot_btn.setup(coords, slot_data)
			
			# Connect click signal
			slot_btn.slot_clicked.connect(_on_grid_slot_clicked)
			
			# Add hover effects
			slot_btn.mouse_entered.connect(func(): slot_btn.set_hover_effect(true))
			slot_btn.mouse_exited.connect(func(): slot_btn.set_hover_effect(false))
			
			grid_board.add_child(slot_btn)
			grid_buttons[coords] = slot_btn

func _on_slab_placed(coords: Vector2, slab_data, result: Dictionary):
	# Update the specific grid slot
	if grid_buttons.has(coords):
		var slot_btn = grid_buttons[coords]
		
		if slab_data != null:
			# Place the slab visual
			slot_btn.place_slab(slab_scene, slab_data)
			
			# Show score feedback
			_show_score_feedback(coords, result)
		else:
			# Clear the slot
			slot_btn.clear_slab()
	
	# Clear active slot UI if hand is empty
	_check_clear_active_slot()

func _show_score_feedback(coords: Vector2, result: Dictionary):
	# Create floating score text
	if not grid_buttons.has(coords):
		return
		
	var slot_btn = grid_buttons[coords]
	var score = result.get("score", 0)
	var score_type = result.get("type", "MISMATCH")
	
	# Create label
	var score_label = Label.new()
	score_label.text = "+%d" % score
	score_label.add_theme_font_size_override("font_size", 24)
	
	# Color based on match type
	match score_type:
		"PERFECT":
			score_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
		"MATCH":
			score_label.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
		_:
			score_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	
	# Add shadow
	score_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	score_label.add_theme_constant_override("shadow_offset_x", 0)
	score_label.add_theme_constant_override("shadow_offset_y", 2)
	score_label.add_theme_constant_override("shadow_outline_size", 4)
	
	# Position above button
	var btn_pos = slot_btn.global_position
	score_label.global_position = btn_pos + Vector2(slot_btn.size.x / 2 - 30, -40)
	
	get_tree().root.add_child(score_label)
	
	# Animate
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(score_label, "position:y", score_label.position.y - 50, 1.0)
	tween.tween_property(score_label, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	score_label.queue_free()

func _on_slab_drawn(slab_data):
	# Show in active slot
	active_slab_slot.visible = true
	
	# Clear old slab
	for c in active_slab_slot.get_children(): 
		c.queue_free()

	# Create new visual
	var slab_ui = slab_scene.instantiate()
	active_slab_slot.add_child(slab_ui)
	slab_ui.setup(slab_data)
	slab_ui.position = Vector2.ZERO

func _on_bench_updated(bench_array: Array):
	# Clear active slot UI if hand is empty
	_check_clear_active_slot()
	
	# Clear bench visuals
	for c in bench_area.get_children(): 
		c.queue_free()
	
	# Create fanned bench cards
	var start_x = bench_area.size.x / 2 if bench_area.size.x > 0 else 400
	var card_width = 90
	var spacing = 95
	var total_width = (bench_array.size() - 1) * spacing
	start_x = start_x - total_width / 2
	
	for i in range(bench_array.size()):
		var slab_ui = slab_scene.instantiate()
		bench_area.add_child(slab_ui)
		slab_ui.setup(bench_array[i])
		
		# Fan layout
		var x_pos = start_x + (i * spacing)
		var y_offset = abs(i - bench_array.size() / 2.0) * 8
		var rotation_deg = (i - bench_array.size() / 2.0) * 4
		
		slab_ui.position = Vector2(x_pos, 20 + y_offset)
		slab_ui.rotation_degrees = rotation_deg
		slab_ui.scale = Vector2(0.9, 0.9)
		
		# Make clickable
		slab_ui.mouse_filter = Control.MOUSE_FILTER_STOP
		var index = i
		slab_ui.gui_input.connect(func(event): _on_bench_card_clicked(event, index))

func _on_bench_card_clicked(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var slab = RunManager.play_from_bench(index)
		if slab:
			RunManager.current_slab_holding = slab
			_on_slab_drawn(slab)

func _check_clear_active_slot():
	if RunManager.current_slab_holding == null:
		active_slab_slot.visible = false
		for c in active_slab_slot.get_children(): 
			c.queue_free()

func _on_score_update(total, breakdown):
	score_lbl.update_value(str(total))

func _on_round_update(round_num):
	round_lbl.update_value("%d/3" % round_num)

func _on_draws_changed(current: int, max_draws: int):
	draws_lbl.update_value(str(current))

func _on_grid_slot_clicked(coords: Vector2):
	GameController._on_grid_slot_clicked(coords)
