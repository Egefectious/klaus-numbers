extends Control

# Gothic corner decorations matching the HTML design
const CORNER_SIZE = 150
const BORDER_WIDTH = 2
const GLOW_COLOR = Color(0.4, 0.47, 0.59, 0.3)  # rgba(100, 120, 150, 0.3)

func _ready():
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _draw():
	var viewport_size = get_viewport_rect().size
	
	# Top-left corner
	draw_corner(Vector2(0, 0), Vector2(1, 1))
	
	# Top-right corner  
	draw_corner(Vector2(viewport_size.x, 0), Vector2(-1, 1))
	
	# Bottom-left corner
	draw_corner(Vector2(0, viewport_size.y), Vector2(1, -1))
	
	# Bottom-right corner
	draw_corner(Vector2(viewport_size.x, viewport_size.y), Vector2(-1, -1))

func draw_corner(start_pos: Vector2, direction: Vector2):
	# Draw the L-shaped border
	var horizontal_end = start_pos + Vector2(CORNER_SIZE * direction.x, 0)
	var vertical_end = start_pos + Vector2(0, CORNER_SIZE * direction.y)
	
	# Draw lines with glow effect
	draw_line(start_pos, horizontal_end, GLOW_COLOR, BORDER_WIDTH)
	draw_line(start_pos, vertical_end, GLOW_COLOR, BORDER_WIDTH)
	
	# Draw subtle accent lines (shorter, brighter)
	var accent_color = Color(0.4, 0.47, 0.59, 0.5)
	var accent_length = 60
	draw_line(start_pos, start_pos + Vector2(accent_length * direction.x, 0), accent_color, BORDER_WIDTH)
	draw_line(start_pos, start_pos + Vector2(0, accent_length * direction.y), accent_color, BORDER_WIDTH)
