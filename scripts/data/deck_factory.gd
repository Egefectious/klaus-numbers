extends Node
class_name DeckFactory

# Static function: We can call this without attaching the script to a node
static func create_starter_deck() -> Array[SlabData]:
	var new_deck: Array[SlabData] = []
	var letters = ["L", "I", "M", "B", "O"]
	
	# Create 75 Cards (5 Letters * 15 Numbers)
	for l_type in letters:
		for num in range(1, 16): # 1 to 15
			var slab = SlabData.new()
			
			# Set the data
			slab.id = "slab_%s_%d" % [l_type, num]
			slab.display_name = "%s-%d" % [l_type, num]
			slab.letter_type = l_type
			slab.number_value = num
			slab.base_score = 10 # Standard starting score
			slab.rarity = "Common"
			
			new_deck.append(slab)
			
	return new_deck
