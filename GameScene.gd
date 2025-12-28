extends Control

# UI References
@onready var grid_board: GridContainer = $MainLayout/CenterPanel/GridFrame/GridBoard
@onready var bench_area: Control = $MainLayout/CenterPanel/BenchArea
@onready var score_lbl: PanelContainer = $MainLayout/RightPanel/StatsBox/StatsPanel/StatsContent/ScoreStat
@onready var target_lbl: PanelContainer = $MainLayout/RightPanel/StatsBox/StatsPanel/StatsContent/TargetStat
@onready var round_lbl: PanelContainer = $MainLayout/RightPanel/StatsBox/StatsPanel/StatsContent/SmallStatsRow/RoundStat
@onready var active_slab_slot: PanelContainer = $MainLayout/RightPanel/ActiveSlabSlot

var slab_scene = preload("res://scenes/ui/SlabUI.tscn")

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
		
	if not ScoreManager.is_connected("score_calculated", _on_score_update):
		ScoreManager.connect("score_calculated", _on_score_update)
	
	# 2. Connect Buttons
	var actions = $MainLayout/RightPanel/ActionsBox
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
	for c in grid_board.get_children(): c.queue_free()
	
	# Rebuild 5x5 Grid
	for y in range(5):
		for x in range(5):
			var coords = Vector2(x, y)
			var slot_data = grid_data.get(coords)
			
			# UPDATE: Use a Button so we can click it!
			var slot_btn = Button.new()
			slot_btn.custom_minimum_size = Vector2(90, 90)
			
			# Style it to look like a stone slot (Flat style)
			var style = StyleBoxFlat.new()
			style.bg_color = Color("#2b2b30") # Dark Stone
			style.border_width_bottom = 4
			style.border_color = Color("#444444")
			style.corner_radius_top_left = 4
			style.corner_radius_top_right = 4
			style.corner_radius_bottom_right = 4
			style.corner_radius_bottom_left = 4
			slot_btn.add_theme_stylebox_override("normal", style)
			slot_btn.add_theme_stylebox_override("hover", style) # Keep same style on hover
			
			# Add Target Number Label
			var lbl = Label.new()
			lbl.text = str(slot_data.target_number)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.position = Vector2(0, 30) # Manually center roughly
			lbl.custom_minimum_size = Vector2(90, 90) # Match button size to center text
			lbl.add_theme_font_size_override("font_size", 24)
			lbl.modulate = Color(1, 1, 1, 0.3) # Dim target number
			# Make label 'transparent' to clicks so button catches input
			lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE 
			
			slot_btn.add_child(lbl)
			
			# CONNECT CLICK SIGNAL
			slot_btn.pressed.connect(func(): GameController._on_grid_slot_clicked(coords))
			
			grid_board.add_child(slot_btn)

func _on_slab_placed(coords: Vector2, slab_data: SlabData, result: Dictionary):
	# 1. Update the Grid Slot Visual
	var index = (coords.y * 5) + coords.x
	if index < grid_board.get_child_count():
		var slot_btn = grid_board.get_child(index)
		
		# If we have data, spawn the visual
		if slab_data != null:
			var slab_ui = slab_scene.instantiate()
			# Scale it down slightly to fit in the grid
			slab_ui.scale = Vector2(0.8, 0.8) 
			slab_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE # Don't block future clicks
			
			slot_btn.add_child(slab_ui)
			slab_ui.setup(slab_data)
			
			# Center it (Math based on 90px slot and approx 80px scaled slab)
			slab_ui.position = Vector2(5, 0)
			
		# If data is null (Destroyed/Cleared), remove visuals
		else:
			for child in slot_btn.get_children():
				if child is SlabUI: child.queue_free()

	# 2. Clear Active Slot UI if hand is empty
	_check_clear_active_slot()

func _on_slab_drawn(slab_data: SlabData):
	# Clear old slab
	for c in active_slab_slot.get_children(): c.queue_free()

	# Create new visual
	var slab_ui = slab_scene.instantiate()
	active_slab_slot.add_child(slab_ui)
	slab_ui.setup(slab_data)
	
	# Reset position for PanelContainer
	slab_ui.position = Vector2.ZERO 

func _on_bench_updated(bench_array: Array):
	# 1. Clear Active Slot UI if hand is empty (Moved to Bench)
	_check_clear_active_slot()
	
	# 2. Clear bench visuals
	for c in bench_area.get_children(): c.queue_free()
	
	# 3. Re-fan the cards
	var start_x = 0
	for i in range(bench_array.size()):
		var slab_ui = slab_scene.instantiate()
		bench_area.add_child(slab_ui)
		slab_ui.setup(bench_array[i])
		# Adjust spacing for fan
		slab_ui.position = Vector2(start_x + (i * 90), 20)
		slab_ui.rotation_degrees = (i - bench_array.size()/2.0) * 5 

func _check_clear_active_slot():
	# If RunManager says we aren't holding anything, clear the big preview slot
	if RunManager.current_slab_holding == null:
		for c in active_slab_slot.get_children(): c.queue_free()

func _on_score_update(total, breakdown):
	score_lbl.text = "SCORE: " + str(total)

func _on_round_update(round_num):
	round_lbl.text = "ROUND: %d/3" % round_num
