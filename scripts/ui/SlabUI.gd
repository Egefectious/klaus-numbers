extends Control
class_name SlabUI

@onready var background: Panel = $Background
@onready var number_label: Label = $NumberLabel
@onready var letter_label: Label = $LetterLabel
@onready var glow_effect: Control = $GlowEffect

var slab_data: SlabData

# Rune colors matching HTML design
const COLORS = {
	"L": Color("#ac1444"),  # Red
	"I": Color("#9b581a"),  # Orange  
	"M": Color("#ffff07"),  # Yellow
	"B": Color("#33ff00"),  # Green
	"O": Color("#a40dc8"),  # Purple
	"WILD": Color.WHITE
}

# Rarity colors
const RARITY_COLORS = {
	"Common": Color(0.5, 0.5, 0.6, 0.5),
	"Uncommon": Color(0.314, 0.588, 1.0, 0.6),
	"Rare": Color(0.706, 0.392, 1.0, 0.6),
	"Legendary": Color(1.0, 0.784, 0.314, 0.7)
}

func _ready():
	custom_minimum_size = Vector2(100, 120)

func setup(data: SlabData):
	slab_data = data
	
	# Setup background style
	_setup_background()
	
	# Setup number display
	number_label.text = str(data.number_value)
	number_label.add_theme_font_size_override("font_size", 56)
	number_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Setup letter display
	letter_label.text = data.letter_type
	var letter_color = COLORS.get(data.letter_type, Color.WHITE)
	letter_label.add_theme_color_override("font_color", letter_color)
	letter_label.add_theme_font_size_override("font_size", 24)
	
	# Add glow effect to letter
	letter_label.add_theme_color_override("font_shadow_color", letter_color)
	letter_label.add_theme_constant_override("shadow_offset_x", 0)
	letter_label.add_theme_constant_override("shadow_offset_y", 0)
	letter_label.add_theme_constant_override("shadow_outline_size", 8)
	
	# Add subtle glow based on rarity
	if data.rarity in RARITY_COLORS:
		_add_rarity_glow(data.rarity)
	
	# Special effects for legendary
	if data.rarity == "Legendary":
		_add_legendary_effects()

func _setup_background():
	var style = StyleBoxFlat.new()
	
	# Stone-like base with slight gradient feel
	style.bg_color = Color(0.15, 0.15, 0.18, 1.0)
	
	# Border
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.28, 0.28, 0.32, 1.0)
	
	# Rounded corners
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	
	# Shadow
	style.shadow_size = 8
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_offset = Vector2(0, 4)
	
	background.add_theme_stylebox_override("panel", style)
	
	# Add stone texture overlay
	var texture_overlay = ColorRect.new()
	texture_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_overlay.color = Color(0.18, 0.18, 0.20, 0.3)
	texture_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_child(texture_overlay)

func _add_rarity_glow(rarity: String):
	var glow_color = RARITY_COLORS.get(rarity, Color.TRANSPARENT)
	
	if glow_color.a > 0:
		var style = background.get_theme_stylebox("panel").duplicate()
		style.border_color = glow_color
		style.shadow_size = 10
		style.shadow_color = Color(glow_color.r, glow_color.g, glow_color.b, 0.4)
		background.add_theme_stylebox_override("panel", style)

func _add_legendary_effects():
	# Pulse animation for legendary cards
	var tween = create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Pulse the glow
	if glow_effect:
		glow_effect.visible = true
		var glow_rect = ColorRect.new()
		glow_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		glow_rect.color = Color(1.0, 0.784, 0.314, 0.0)
		glow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow_effect.add_child(glow_rect)
		
		tween.tween_property(glow_rect, "color:a", 0.15, 1.5)
		tween.tween_property(glow_rect, "color:a", 0.0, 1.5)

func set_highlight(active: bool):
	if glow_effect:
		glow_effect.visible = active
		
	if active:
		# Scale up slightly
		var hover_tween = create_tween()
		hover_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.2)
		
		# Brighten
		modulate = Color(1.1, 1.1, 1.15, 1.0)
	else:
		var hover_tween = create_tween()
		hover_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
		modulate = Color.WHITE

# Hover effects
func _on_mouse_entered():
	set_highlight(true)

func _on_mouse_exited():
	set_highlight(false)
