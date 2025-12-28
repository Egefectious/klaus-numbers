extends PanelContainer

# Mystical rune card with stone texture and glowing effects

signal card_clicked(card)
signal card_hovered(card)

@export var rune_symbol: String = "ᚠ"
@export var is_active: bool = true
@export var card_value: int = 0
@export var rune_color: Color = Color(0.302, 0.851, 1.0)  # Cyan default

var glow_intensity: float = 0.0
var hover_tween: Tween
var is_hovered: bool = false

# Rune symbols from the HTML
const RUNES = ['ᚠ', 'ᚢ', 'ᚦ', 'ᚨ', 'ᚱ', 'ᚲ', 'ᚷ', 'ᚹ', 'ᚺ', 'ᚾ', 'ᛁ', 'ᛃ', 'ᛇ', 'ᛈ', 'ᛉ', 'ᛊ', 'ᛏ', 'ᛒ', 'ᛖ', 'ᛗ', 'ᛚ', 'ᛜ', 'ᛞ', 'ᛟ']

# Mystical colors from HTML
const RUNE_COLORS = [
	Color(0.302, 0.851, 1.0),    # Cyan-blue #4dd9ff
	Color(0.702, 0.4, 1.0),      # Purple #b366ff
	Color(1.0, 0.549, 0.259),    # Orange #ff8c42
	Color(1.0, 0.302, 0.58),     # Pink #ff4d94
	Color(0.302, 1.0, 0.702),    # Green #4dffb3
]

var rune_label: Label
var texture_overlay: ColorRect
var glow_rect: ColorRect

func _ready():
	# Randomize if needed
	if rune_symbol == "ᚠ":
		randomize_rune()
	
	custom_minimum_size = Vector2(100, 100)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	setup_style()
	setup_content()
	connect_signals()

func randomize_rune():
	rune_symbol = RUNES[randi() % RUNES.size()]
	rune_color = RUNE_COLORS[randi() % RUNE_COLORS.size()]

func setup_style():
	# Stone-like base
	var style = StyleBoxFlat.new()
	
	if is_active:
		# Active card - darker stone
		style.bg_color = Color(0.15, 0.15, 0.18, 1.0)
	else:
		# Inactive card - even darker
		style.bg_color = Color(0.1, 0.1, 0.12, 1.0)
	
	# Border
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	
	if is_active:
		style.border_color = Color(0.3, 0.3, 0.35, 0.8)
	else:
		style.border_color = Color(0.2, 0.2, 0.22, 0.6)
	
	# Slight rounding
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	
	add_theme_stylebox_override("panel", style)

func setup_content():
	# Create layers
	var overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	
	# Stone texture overlay
	texture_overlay = ColorRect.new()
	texture_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_overlay.color = Color(0.2, 0.2, 0.22, 0.3)
	texture_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(texture_overlay)
	
	# Glow effect behind rune (only for active cards)
	if is_active:
		glow_rect = ColorRect.new()
		glow_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		glow_rect.color = Color(rune_color.r, rune_color.g, rune_color.b, 0.0)
		glow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.add_child(glow_rect)
	
	# Rune symbol
	rune_label = Label.new()
	rune_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	rune_label.text = rune_symbol
	rune_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rune_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rune_label.add_theme_font_size_override("font_size", 48)
	
	if is_active:
		rune_label.add_theme_color_override("font_color", rune_color)
		# Add glow to text
		rune_label.add_theme_color_override("font_shadow_color", rune_color)
		rune_label.add_theme_constant_override("shadow_offset_x", 0)
		rune_label.add_theme_constant_override("shadow_offset_y", 0)
		rune_label.add_theme_constant_override("shadow_outline_size", 8)
	else:
		# Inactive cards are dim
		rune_label.add_theme_color_override("font_color", Color(0.29, 0.29, 0.35))
	
	rune_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(rune_label)

func connect_signals():
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_active:
			card_clicked.emit(self)
			play_click_animation()

func _on_mouse_entered():
	if is_active:
		is_hovered = true
		card_hovered.emit(self)
		animate_hover(true)

func _on_mouse_exited():
	is_hovered = false
	animate_hover(false)

func animate_hover(hovering: bool):
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_CUBIC)
	
	if hovering and is_active:
		# Scale up slightly
		hover_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.2)
		
		# Brighten glow
		if glow_rect:
			hover_tween.tween_property(glow_rect, "color:a", 0.2, 0.2)
		
		# Enhance border
		var style = get_theme_stylebox("panel").duplicate()
		style.border_color = Color(rune_color.r, rune_color.g, rune_color.b, 0.8)
		style.shadow_size = 8
		style.shadow_color = Color(rune_color.r, rune_color.g, rune_color.b, 0.4)
		add_theme_stylebox_override("panel", style)
	else:
		# Return to normal
		hover_tween.tween_property(self, "scale", Vector2.ONE, 0.2)
		
		if glow_rect:
			hover_tween.tween_property(glow_rect, "color:a", 0.0, 0.2)
		
		setup_style()

func play_click_animation():
	# Quick pulse animation
	var click_tween = create_tween()
	click_tween.set_ease(Tween.EASE_OUT)
	click_tween.set_trans(Tween.TRANS_BACK)
	
	click_tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1)
	click_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.15)
	
	# Bright flash
	if glow_rect:
		var flash_tween = create_tween()
		flash_tween.tween_property(glow_rect, "color:a", 0.5, 0.1)
		flash_tween.tween_property(glow_rect, "color:a", 0.0, 0.2)

func set_active(active: bool):
	is_active = active
	setup_style()
	
	if rune_label:
		if is_active:
			rune_label.add_theme_color_override("font_color", rune_color)
		else:
			rune_label.add_theme_color_override("font_color", Color(0.29, 0.29, 0.35))

func pulse_glow():
	# Continuous gentle pulse for active cards
	if not is_active or not glow_rect:
		return
	
	var pulse = create_tween()
	pulse.set_loops()
	pulse.set_ease(Tween.EASE_IN_OUT)
	pulse.set_trans(Tween.TRANS_SINE)
	
	pulse.tween_property(glow_rect, "color:a", 0.1, 2.0)
	pulse.tween_property(glow_rect, "color:a", 0.0, 2.0)
