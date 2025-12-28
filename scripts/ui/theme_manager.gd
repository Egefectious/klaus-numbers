extends Node

# Global theme manager for Death's Casino aesthetic
# Attach this to an autoload singleton or call from main scene

const FONT_PRIMARY = "res://fonts/primary_font.ttf"  # You'll need to add fonts
const FONT_DISPLAY = "res://fonts/display_font.ttf"

# Color palette from the HTML
const COLOR_GOLD = Color(0.753, 0.627, 0.502)  # #c0a080
const COLOR_TEXT_LIGHT = Color(0.9, 0.9, 0.95)
const COLOR_TEXT_DIM = Color(0.6, 0.6, 0.7)
const COLOR_BORDER = Color(0.314, 0.353, 0.431, 0.5)
const COLOR_BORDER_HOVER = Color(0.588, 0.588, 0.706, 0.8)

# Rune colors
const COLOR_RUNE_CYAN = Color(0.302, 0.851, 1.0)     # #4dd9ff
const COLOR_RUNE_PURPLE = Color(0.702, 0.4, 1.0)    # #b366ff
const COLOR_RUNE_ORANGE = Color(1.0, 0.549, 0.259)  # #ff8c42
const COLOR_RUNE_PINK = Color(1.0, 0.302, 0.58)     # #ff4d94
const COLOR_RUNE_GREEN = Color(0.302, 1.0, 0.702)   # #4dffb3

# Rarity colors
const COLOR_LEGENDARY = Color(1.0, 0.784, 0.314, 0.6)  # Gold
const COLOR_RARE = Color(0.706, 0.392, 1.0, 0.5)       # Purple
const COLOR_UNCOMMON = Color(0.314, 0.588, 1.0, 0.5)   # Blue
const COLOR_COMMON = Color(0.5, 0.5, 0.6, 0.5)         # Gray

static func get_random_rune_color() -> Color:
	var colors = [COLOR_RUNE_CYAN, COLOR_RUNE_PURPLE, COLOR_RUNE_ORANGE, 
	              COLOR_RUNE_PINK, COLOR_RUNE_GREEN]
	return colors[randi() % colors.size()]

static func create_button_style(is_primary: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	if is_primary:
		# Primary button (like DRAW button)
		style.bg_color = Color(0.2, 0.25, 0.35, 0.9)
		style.border_color = Color(0.4, 0.6, 0.9, 0.8)
	else:
		# Secondary button
		style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
		style.border_color = COLOR_BORDER
	
	# Rounded corners
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	# Border
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	
	# Padding
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	
	return style

static func create_button_hover_style(is_primary: bool = false) -> StyleBoxFlat:
	var style = create_button_style(is_primary)
	
	if is_primary:
		style.border_color = Color(0.5, 0.75, 1.0, 1.0)
		style.shadow_size = 8
		style.shadow_color = Color(0.3, 0.5, 0.8, 0.4)
	else:
		style.border_color = COLOR_BORDER_HOVER
		style.shadow_size = 4
		style.shadow_color = Color(0.4, 0.4, 0.5, 0.3)
	
	return style
