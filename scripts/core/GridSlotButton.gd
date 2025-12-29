extends Button
class_name GridSlotButton

# Reference to the slot data
var slot_coords: Vector2
var slot_data: GridSlot
var target_label: Label
var slab_container: Control

signal slot_clicked(coords: Vector2)

const RUNE_COLORS = {
	"L": Color("#ac1444"),  # Red
	"I": Color("#9b581a"),  # Orange  
	"M": Color("#ffff07"),  # Yellow
	"B": Color("#33ff00"),  # Green
	"O": Color("#a40dc8")   # Purple
}

func setup(coords: Vector2, grid_slot: GridSlot):
	slot_coords = coords
	slot_data = grid_slot
	
	custom_minimum_size = Vector2(105, 105)
	
	# Create the visual layers
	_setup_style()
	_create_content()
	
	# Connect signal
	pressed.connect(_on_pressed)

func _setup_style():
	# Create stone-like base style
	var normal_style = StyleBoxFlat.new()
	
	if slot_data.is_locked:
		# Locked slot - darker, dimmed
		normal_style.bg_color = Color(0.08, 0.08, 0.10, 1.0)
		normal_style.border_color = Color(0.15, 0.15, 0.18, 0.8)
	else:
		# Active slot - stone texture
		normal_style.bg_color = Color(0.12, 0.12, 0.15, 1.0)
		normal_style.border_color = Color(0.25, 0.25, 0.30, 0.8)
	
	# Rounded corners
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_bottom_left = 8
	
	# Border
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	
	# Subtle shadow
	normal_style.shadow_size = 6
	normal_style.shadow_color = Color(0, 0, 0, 0.5)
	normal_style.shadow_offset = Vector2(0, 3)
	
	add_theme_stylebox_override("normal", normal_style)
	add_theme_stylebox_override("hover", normal_style)
	add_theme_stylebox_override("pressed", normal_style)
	add_theme_stylebox_override("disabled", normal_style)

func _create_content():
	# Container for all visual elements
	var content_layer = Control.new()
	content_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content_layer)
	
	# Stone texture overlay
	var texture_overlay = ColorRect.new()
	texture_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_overlay.color = Color(0.18, 0.18, 0.20, 0.3)
	texture_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content_layer.add_child(texture_overlay)
	
	# Target number (dimmed, in background)
	target_label = Label.new()
	target_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	target_label.text = str(slot_data.target_number)
	target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	target_label.add_theme_font_size_override("font_size", 42)
	target_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.35, 0.4))
	target_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content_layer.add_child(target_label)
	
	# Letter indicator (top-left corner, small)
	var letter_label = Label.new()
	letter_label.position = Vector2(8, 4)
	letter_label.text = slot_data.target_letter
	letter_label.add_theme_font_size_override("font_size", 18)
	
	var letter_color = RUNE_COLORS.get(slot_data.target_letter, Color.WHITE)
	letter_label.add_theme_color_override("font_color", letter_color)
	letter_label.add_theme_color_override("font_shadow_color", letter_color)
	letter_label.add_theme_constant_override("shadow_offset_x", 0)
	letter_label.add_theme_constant_override("shadow_offset_y", 0)
	letter_label.add_theme_constant_override("shadow_outline_size", 4)
	letter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content_layer.add_child(letter_label)
	
	# Container for placed slab (if any)
	slab_container = Control.new()
	slab_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	slab_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content_layer.add_child(slab_container)
	
	# Show locked state if applicable
	if slot_data.is_locked:
		disabled = true
		modulate = Color(0.5, 0.5, 0.5, 1.0)
		
		var lock_icon = Label.new()
		lock_icon.set_anchors_preset(Control.PRESET_CENTER)
		lock_icon.text = "🔒"
		lock_icon.add_theme_font_size_override("font_size", 32)
		lock_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content_layer.add_child(lock_icon)

func place_slab(slab_ui_scene: PackedScene, slab_data):
	# Clear any existing slab
	for child in slab_container.get_children():
		child.queue_free()
	
	if slab_data != null:
		var slab_ui = slab_ui_scene.instantiate()
		slab_container.add_child(slab_ui)
		slab_ui.setup(slab_data)
		
		# Center it and scale slightly smaller to fit in slot
		slab_ui.position = Vector2(2, 2)
		slab_ui.scale = Vector2(0.95, 0.95)
		slab_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Hide the target number when slab is placed
		target_label.modulate.a = 0.0

func clear_slab():
	for child in slab_container.get_children():
		child.queue_free()
	
	# Show target number again
	target_label.modulate.a = 0.4

func _on_pressed():
	slot_clicked.emit(slot_coords)

func set_hover_effect(active: bool):
	if disabled:
		return
		
	if active:
		# Brighten on hover
		modulate = Color(1.1, 1.1, 1.15, 1.0)
		var style = get_theme_stylebox("normal").duplicate()
		style.border_color = Color(0.4, 0.5, 0.65, 0.9)
		style.shadow_size = 10
		add_theme_stylebox_override("hover", style)
	else:
		modulate = Color.WHITE
		_setup_style()
