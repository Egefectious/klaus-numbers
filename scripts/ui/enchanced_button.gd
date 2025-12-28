extends Button

# Enhanced button with glow effects and smooth transitions

@export var is_primary: bool = false
@export var glow_intensity: float = 0.0

var glow_tween: Tween
var base_scale: Vector2 = Vector2.ONE

func _ready():
	setup_styles()
	connect_signals()
	pivot_offset = size / 2

func connect_signals():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func setup_styles():
	# Normal style
	var normal_style = StyleBoxFlat.new()
	if is_primary:
		normal_style.bg_color = Color(0.2, 0.25, 0.35, 0.9)
		normal_style.border_color = Color(0.4, 0.6, 0.9, 0.8)
	else:
		normal_style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
		normal_style.border_color = Color(0.314, 0.353, 0.431, 0.5)
	
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8
	
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.border_width_bottom = 2
	
	normal_style.content_margin_left = 24
	normal_style.content_margin_right = 24
	normal_style.content_margin_top = 14
	normal_style.content_margin_bottom = 14
	
	add_theme_stylebox_override("normal", normal_style)
	
	# Hover style
	var hover_style = normal_style.duplicate()
	if is_primary:
		hover_style.border_color = Color(0.5, 0.75, 1.0, 1.0)
		hover_style.shadow_size = 12
		hover_style.shadow_color = Color(0.3, 0.5, 0.8, 0.5)
	else:
		hover_style.border_color = Color(0.588, 0.588, 0.706, 0.8)
		hover_style.shadow_size = 8
		hover_style.shadow_color = Color(0.4, 0.4, 0.5, 0.4)
	
	add_theme_stylebox_override("hover", hover_style)
	
	# Pressed style
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(pressed_style.bg_color.r * 0.8, 
								   pressed_style.bg_color.g * 0.8, 
								   pressed_style.bg_color.b * 0.8, 
								   pressed_style.bg_color.a)
	add_theme_stylebox_override("pressed", pressed_style)
	
	# Font settings
	add_theme_font_size_override("font_size", 16)
	add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	add_theme_color_override("font_pressed_color", Color(0.8, 0.8, 0.85))

func _on_mouse_entered():
	animate_hover(true)

func _on_mouse_exited():
	animate_hover(false)

func _on_button_down():
	animate_press(true)

func _on_button_up():
	animate_press(false)

func animate_hover(is_hovering: bool):
	if glow_tween:
		glow_tween.kill()
	
	glow_tween = create_tween()
	glow_tween.set_ease(Tween.EASE_OUT)
	glow_tween.set_trans(Tween.TRANS_CUBIC)
	
	if is_hovering:
		glow_tween.tween_property(self, "scale", Vector2(1.02, 1.02), 0.2)
	else:
		glow_tween.tween_property(self, "scale", Vector2.ONE, 0.2)

func animate_press(is_pressed: bool):
	if glow_tween:
		glow_tween.kill()
	
	glow_tween = create_tween()
	glow_tween.set_ease(Tween.EASE_OUT)
	glow_tween.set_trans(Tween.TRANS_QUAD)
	
	if is_pressed:
		glow_tween.tween_property(self, "scale", Vector2(0.97, 0.97), 0.1)
	else:
		glow_tween.tween_property(self, "scale", Vector2.ONE, 0.15)
