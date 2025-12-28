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
	var stylebox = StyleBoxFlat.new()
	
	# Background colors based on style
	match panel_style:
		PanelStyle.DARK:
			# linear-gradient(135deg, rgba(30, 30, 45, 0.8), rgba(20, 20, 35, 0.8))
			stylebox.bg_color = Color(0.118, 0.118, 0.176, 0.8)
		PanelStyle.DARKER:
			stylebox.bg_color = Color(0.078, 0.078, 0.137, 0.8)
		PanelStyle.ARTIFACT:
			# linear-gradient(135deg, rgba(40, 40, 55, 0.9), rgba(25, 25, 40, 0.9))
			stylebox.bg_color = Color(0.157, 0.157, 0.216, 0.9)
		PanelStyle.STAT:
			stylebox.bg_color = Color(0.118, 0.118, 0.176, 0.85)
	
	# Corner radius
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
	
	# Shadow
	if enable_glow:
		stylebox.shadow_size = 8
		stylebox.shadow_color = Color(0, 0, 0, 0.6)
		stylebox.shadow_offset = Vector2(0, 4)
	
	# Content margin (padding)
	stylebox.content_margin_left = 16
	stylebox.content_margin_right = 16
	stylebox.content_margin_top = 16
	stylebox.content_margin_bottom = 16
	
	# Add subtle inner highlight
	stylebox.draw_center = true
	
	# Apply the style
	add_theme_stylebox_override("panel", stylebox)
