extends PanelContainer

# Currency display (Obols or Essence) with icon and styled frame

@export var currency_name: String = "OBOLS"
@export var currency_value: int = 0
@export var icon_text: String = "⚜"
@export var border_color: Color = Color(1.0, 0.784, 0.314, 0.6)  # Gold
@export var icon_color: Color = Color(1.0, 0.9, 0.6)

var value_label: Label

func _ready():
	setup_style()
	setup_content()

func setup_style():
	var style = StyleBoxFlat.new()
	
	# Background with subtle gradient effect
	style.bg_color = Color(0.118, 0.118, 0.176, 0.9)
	
	# Colored border based on currency type
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	
	# Rounded corners
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	# Glow effect
	style.shadow_size = 6
	style.shadow_color = Color(border_color.r, border_color.g, border_color.b, 0.3)
	
	# Padding
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	
	add_theme_stylebox_override("panel", style)

func setup_content():
	# Main horizontal layout
	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 8)
	add_child(hbox)
	
	# Icon
	var icon = Label.new()
	icon.text = icon_text
	icon.add_theme_font_size_override("font_size", 24)
	icon.add_theme_color_override("font_color", icon_color)
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon)
	
	# Currency info VBox
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	# Currency name label
	var name_label = Label.new()
	name_label.text = currency_name
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	vbox.add_child(name_label)
	
	# Currency value
	value_label = Label.new()
	value_label.text = str(currency_value)
	value_label.add_theme_font_size_override("font_size", 20)
	value_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	vbox.add_child(value_label)

func set_value(new_value: int):
	currency_value = new_value
	if value_label:
		value_label.text = str(new_value)

func add_value(amount: int):
	set_value(currency_value + amount)

func subtract_value(amount: int):
	set_value(max(0, currency_value - amount))
