extends Control
class_name SlabUI

@onready var number_label: Label = $NumberLabel
@onready var letter_label: Label = $LetterLabel
@onready var background: Panel = $Background
@onready var glow: Control = $Glow

var slab_data: SlabData

# Colors for L-I-M-B-O
const COLORS = {
	"L": Color("#ff5555"),
	"I": Color("#ff9955"),
	"M": Color("#ffff55"),
	"B": Color("#55ff55"),
	"O": Color("#aa55ff"),
	"WILD": Color.WHITE
}

func setup(data: SlabData):
	slab_data = data
	number_label.text = str(data.number_value)
	letter_label.text = data.letter_type
	
	# Apply Color Identity
	var col = COLORS.get(data.letter_type, Color.WHITE)
	letter_label.add_theme_color_override("font_color", col)
	
	# Optional: Tint background slightly based on rarity or type
	if data.rarity == "Legendary":

		var new_style = background.get_theme_stylebox("panel").duplicate()
		new_style.border_color = Color.GOLD
		background.add_theme_stylebox_override("panel", new_style)

func set_highlight(active: bool):
	glow.visible = active
