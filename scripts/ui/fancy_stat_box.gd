extends PanelContainer

# Fancy stat display box matching the HTML design
# Shows a stat with label, value, optional icon, and glow effects

@export var stat_label: String = "STAT"
@export var stat_value: String = "0"
@export var icon_text: String = ""
@export var is_primary: bool = false
@export var glow_color: Color = Color(0.4, 0.6, 0.9, 0.3)

var label_node: Label
var value_node: Label
var icon_node: Label

func _ready():
	setup_style()
	setup_content()

func setup_style():
	var style = StyleBoxFlat.new()
	
	if is_primary:
		# Primary stat box (like score)
		style.bg_color = Color(0.2, 0.25, 0.35, 0.9)
		style.border_color = Color(0.4, 0.6, 0.9, 0.8)
		style.shadow_size = 12
		style.shadow_color = glow_color
	else:
		# Regular stat box
		style.bg_color = Color(0.118, 0.118, 0.176, 0.85)
		style.border_color = Color(0.314, 0.353, 0.431, 0.5)
		style.shadow_size = 6
		style.shadow_color = Color(0, 0, 0, 0.4)
	
	# Rounded corners
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	
	# Border
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	
	# Padding
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	
	add_theme_stylebox_override("panel", style)

func setup_content():
	# Create main container
	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(hbox)
	
	# Add icon if provided
	if icon_text != "":
		icon_node = Label.new()
		icon_node.text = icon_text
		icon_node.add_theme_font_size_override("font_size", 32)
		icon_node.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
		icon_node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(icon_node)
		
		# Add spacing
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(8, 0)
		hbox.add_child(spacer)
	
	# Create VBox for label and value
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	# Add label
	label_node = Label.new()
	label_node.text = stat_label
	label_node.add_theme_font_size_override("font_size", 12)
	label_node.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	vbox.add_child(label_node)
	
	# Add value
	value_node = Label.new()
	value_node.text = stat_value
	value_node.add_theme_font_size_override("font_size", 28)
	if is_primary:
		value_node.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	else:
		value_node.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	vbox.add_child(value_node)

func update_value(new_value: String):
	if value_node:
		value_node.text = new_value

func update_label(new_label: String):
	if label_node:
		label_node.text = new_label
