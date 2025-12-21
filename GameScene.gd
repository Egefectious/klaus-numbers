extends Control

# UI References
@onready var grid_container: GridContainer = $MainLayout/CenterPanel/GridBoard
@onready var active_slab_slot: PanelContainer = $MainLayout/RightPanel/ActiveSlabSlot
@onready var score_label: Label = $MainLayout/RightPanel/Stats/ScoreLabel
@onready var bench_area: Control = $MainLayout/CenterPanel/BenchArea

# Scenes to Instance
var slab_scene = preload("res://scenes/ui/SlabUI.tscn")

func _ready():
	# Connect to Managers
	GridManager.connect("grid_generated", _on_grid_generated)
	RunManager.connect("slab_drawn", _on_slab_drawn)
	ScoreManager.connect("score_calculated", _on_score_update)
	
	# Connect Buttons
	$MainLayout/RightPanel/ActionButtons/BtnDraw.pressed.connect(_on_draw_pressed)
	$MainLayout/RightPanel/ActionButtons/BtnScore.pressed.connect(_on_score_pressed)

# --- VISUAL GENERATION ---

func _on_grid_generated(grid_data: Dictionary):
	# Clear old grid
	for child in grid_container.get_children():
		child.queue_free()
		
	# Create 25 Slots (Visuals only)
	# Note: We need to ensure order matches (0,0) to (4,4)
	for y in range(5):
		for x in range(5):
			var coords = Vector2(x, y)
			var slot_data = grid_data.get(coords)
			
			var slot_visual = Panel.new() # Placeholder for the slot background
			slot_visual.custom_minimum_size = Vector2(80, 80)
			
			# Add text for Target Number
			var lbl = Label.new()
			lbl.text = str(slot_data.target_number)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			slot_visual.add_child(lbl)
			
			grid_container.add_child(slot_visual)

func _on_draw_pressed():
	RunManager.draw_slab()

func _on_slab_drawn(slab_data: SlabData):
	# Clear previous active slab
	for child in active_slab_slot.get_children():
		child.queue_free()
		
	# Create new visual
	var slab_ui = slab_scene.instantiate()
	active_slab_slot.add_child(slab_ui)
	slab_ui.setup(slab_data)

func _on_score_pressed():
	GameController._on_score_button_pressed() # Trigger the logic

func _on_score_update(total, breakdown):
	score_label.text = str(total)
	# TODO: Play cool animation here
