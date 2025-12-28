extends PanelContainer

# Bench card with slight rotation and shine effects

signal bench_card_clicked(card)

@export var rune_symbol: String = "ᚠ"
@export var card_value: int = 0
@export var rune_color: Color = Color(0.302, 0.851, 1.0)
@export var rotation_angle: float = 0.0

const RUNES = ['ᚠ', 'ᚢ', 'ᚦ', 'ᚨ', 'ᚱ', 'ᚲ', 'ᚷ', 'ᚹ', 'ᚺ', 'ᚾ', 'ᛁ', 'ᛃ', 'ᛇ', 'ᛈ', 'ᛉ', 'ᛊ', 'ᛏ', 'ᛒ', 'ᛖ', 'ᛗ', 'ᛚ', 'ᛜ', 'ᛞ', 'ᛟ']

const RUNE_COLORS = [
	Color(0.302, 0.851, 1.0),
	Color(0.702, 0.4, 1.0),
	Color(1.0, 0.549, 0.259),
	Color(1.0, 0.302, 0.58),
	Color(0.302, 1.0, 0.702),
]

var rune_label: Label
var shine_overlay: ColorRect
var hover_tween: Tween

func _ready():
	if rune_symbol == "ᚠ":
		randomize_rune()
	
	custom_minimum_size = Vector2(80, 110)
	mouse_filter = Control.MOUSE_FILTER_STOP
	pivot_offset = custom_minimum_size / 2
	rotation_degrees = rotation_angle
	
	setup_style()
	setup_content()
	connect_signals()

func randomize_rune():
	rune_symbol = RUNES[randi() % RUNES.size()]
	rune_color = RUNE_COLORS[randi() % RUNE_COLORS.size()]

func setup_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.15, 0.95)
	
	# Border with card's rune color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(rune_color.r, rune_color.g, rune_color.b, 0.6)
	
	# Rounded corners
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	
	# Glow
	style.shadow_size = 6
	style.shadow_color = Color(rune_color.r, rune_color.g, rune_color.b, 0.3)
	
	add_theme_stylebox_override("panel", style)

func setup_content():
	var overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	
	# Stone texture
	var texture = ColorRect.new()
	texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture.color = Color(0.18, 0.18, 0.2, 0.4)
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(texture)
	
	# Glass shine effect
	shine_overlay = ColorRect.new()
	shine_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	shine_overlay.color = Color(1.0, 1.0, 1.0, 0.05)
	shine_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(shine_overlay)
	
	# Rune symbol
	rune_label = Label.new()
	rune_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	rune_label.text = rune_symbol
	rune_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rune_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rune_label.add_theme_font_size_override("font_size", 40)
	rune_label.add_theme_color_override("font_color", rune_color)
	
	# Glow effect on text
	rune_label.add_theme_color_override("font_shadow_color", rune_color)
	rune_label.add_theme_constant_override("shadow_offset_x", 0)
	rune_label.add_theme_constant_override("shadow_offset_y", 0)
	rune_label.add_theme_constant_override("shadow_outline_size", 6)
	
	rune_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(rune_label)

func connect_signals():
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		bench_card_clicked.emit(self)
		play_select_animation()

func _on_mouse_entered():
	animate_hover(true)

func _on_mouse_exited():
	animate_hover(false)

func animate_hover(hovering: bool):
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_CUBIC)
	
	if hovering:
		# Lift up and straighten slightly
		hover_tween.tween_property(self, "position:y", position.y - 15, 0.2)
		hover_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
		
		# Brighten shine
		if shine_overlay:
			hover_tween.tween_property(shine_overlay, "color:a", 0.15, 0.2)
		
		# Enhance glow
		var style = get_theme_stylebox("panel").duplicate()
		style.shadow_size = 12
		style.shadow_color = Color(rune_color.r, rune_color.g, rune_color.b, 0.6)
		add_theme_stylebox_override("panel", style)
	else:
		# Return to fan position
		var target_y = position.y + (15 if position.y < 0 else 0)
		hover_tween.tween_property(self, "position:y", target_y, 0.2)
		hover_tween.tween_property(self, "scale", Vector2.ONE, 0.2)
		
		if shine_overlay:
			hover_tween.tween_property(shine_overlay, "color:a", 0.05, 0.2)
		
		setup_style()

func play_select_animation():
	var select_tween = create_tween()
	select_tween.set_ease(Tween.EASE_OUT)
	select_tween.set_trans(Tween.TRANS_BACK)
	
	select_tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1)
	select_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15)
	
	# Flash
	if shine_overlay:
		var flash = create_tween()
		flash.tween_property(shine_overlay, "color:a", 0.4, 0.1)
		flash.tween_property(shine_overlay, "color:a", 0.05, 0.2)
