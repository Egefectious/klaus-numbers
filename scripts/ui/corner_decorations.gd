extends Control

# Gothic corner decorations matching the HTML design exactly
const CORNER_SIZE = 150
const BORDER_WIDTH = 2
const ACCENT_LENGTH = 60
const GLOW_COLOR = Color(0.392, 0.471, 0.588, 0.3)  # rgba(100, 120, 150, 0.3)
const ACCENT_COLOR = Color(0.392, 0.471, 0.588, 0.5)  # Brighter accent

func _ready():
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()
	
	# Redraw when window resizes
	get_viewport().size_changed.connect(queue_redraw)

func _draw():
	var viewport_size = get_viewport_rect().size
	
	# Top-left corner
	_draw_corner(Vector2.ZERO, Vector2(1, 1), "top-left")
	
	# Top-right corner  
	_draw_corner(Vector2(viewport_size.x, 0), Vector2(-1, 1), "top-right")
	
	# Bottom-left corner
	_draw_corner(Vector2(0, viewport_size.y), Vector2(1, -1), "bottom-left")
	
	# Bottom-right corner
	_draw_corner(Vector2(viewport_size.x, viewport_size.y), Vector2(-1, -1), "bottom-right")

func _draw_corner(start_pos: Vector2, direction: Vector2, corner_name: String):
	# Main L-shaped border lines
	var h_end = start_pos + Vector2(CORNER_SIZE * direction.x, 0)
	var v_end = start_pos + Vector2(0, CORNER_SIZE * direction.y)
	
	# Draw main border lines
	draw_line(start_pos, h_end, GLOW_COLOR, BORDER_WIDTH, true)
	draw_line(start_pos, v_end, GLOW_COLOR, BORDER_WIDTH, true)
	
	# Draw accent lines (shorter, brighter)
	var h_accent_end = start_pos + Vector2(ACCENT_LENGTH * direction.x, 0)
	var v_accent_end = start_pos + Vector2(0, ACCENT_LENGTH * direction.y)
	
	draw_line(start_pos, h_accent_end, ACCENT_COLOR, BORDER_WIDTH + 1, true)
	draw_line(start_pos, v_accent_end, ACCENT_COLOR, BORDER_WIDTH + 1, true)
	
	# Draw inner accent lines (for more detail)
	var inner_offset = 10 * direction
	var inner_start = start_pos + inner_offset
	var inner_h_end = inner_start + Vector2((ACCENT_LENGTH - 20) * direction.x, 0)
	var inner_v_end = inner_start + Vector2(0, (ACCENT_LENGTH - 20) * direction.y)
	
	draw_line(inner_start, inner_h_end, Color(ACCENT_COLOR.r, ACCENT_COLOR.g, ACCENT_COLOR.b, 0.3), BORDER_WIDTH, true)
	draw_line(inner_start, inner_v_end, Color(ACCENT_COLOR.r, ACCENT_COLOR.g, ACCENT_COLOR.b, 0.3), BORDER_WIDTH, true)
	
	# Draw corner dot
	draw_circle(start_pos, 3, ACCENT_COLOR)
	draw_circle(start_pos, 5, Color(ACCENT_COLOR.r, ACCENT_COLOR.g, ACCENT_COLOR.b, 0.2))
