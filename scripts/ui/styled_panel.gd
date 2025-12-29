extends PanelContainer

# Gothic panel styling matching the HTML design
# Apply this script to any PanelContainer you want styled

enum PanelStyle {
	DARK,      # Default dark panel
	DARKER,    # Even darker variant
	ARTIFACT,  # For artifact slots
	STAT       # For stat boxes
}

@export var panel_style: PanelStyle = PanelStyle.DARK
@export var border_color := Color(0.314, 0.353, 0.431, 0.5)  # rgba(80, 90, 110, 0.5)
@export var enable_glow := true

func _ready():
	apply_style()

func apply_style():
	# We use StyleBoxFlat to ensure we get Rounded Corners and Borders.
	# (StyleBoxTexture caused the crash because it doesn't have bg_color or corner_radius)
	var stylebox = StyleBoxFlat.new()
	
	# Background colors based on HTML reference
	match panel_style:
		PanelStyle.DARK:
			# Deep Blue-Black
			stylebox.bg_color = Color("#1e1e2d") 
		PanelStyle.DARKER:
			# Almost Black (for slots)
			stylebox.bg_color = Color("#141423")
		PanelStyle.ARTIFACT:
			# Slightly purple tint
			stylebox.bg_color = Color("#282837")
		PanelStyle.STAT:
			# Lighter contrast
			stylebox.bg_color = Color("#232333")
	
	# Corner radius (Matches HTML rounded feel)
	stylebox.corner_radius_top_left = 12
	stylebox.corner_radius_top_right = 12
	stylebox.corner_radius_bottom_left = 12
	stylebox.corner_radius_bottom_right = 12
	
	# Border
	stylebox.border_width_left = 2
	stylebox.border_width_right = 2
	stylebox.border_width_top = 2
	stylebox.border_width_bottom = 2
	stylebox.border_color = border_color
	
	# Shadow / Glow
	if enable_glow:
		stylebox.shadow_size = 8
		stylebox.shadow_color = Color(0, 0, 0, 0.6)
		stylebox.shadow_offset = Vector2(0, 4)
	
	# Content margin (padding)
	stylebox.content_margin_left = 16
	stylebox.content_margin_right = 16
	stylebox.content_margin_top = 16
	stylebox.content_margin_bottom = 16
	
	# Apply the style
	add_theme_stylebox_override("panel", stylebox)
