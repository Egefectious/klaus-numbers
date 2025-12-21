extends Node

# --- DATA DEFINITIONS ---

# 1. SLABS (Cards)
# Structure: ID : { Name, Type, BasePrice, Rarity, UnlockBoss (0=Default), EffectDescription }
var slabs_db = {
	# -- STARTER (Unlock 0) --
	"slab_coal": { "name": "Coal Slab", "cost": 5, "rarity": "Common", "unlock_boss": 0, "desc": "Gains +2 Value when played." },
	"slab_stone": { "name": "Stone Slab", "cost": 3, "rarity": "Common", "unlock_boss": 0, "desc": "Standard Slab." },
	
	# -- CALLER 1 (Adjacency) --
	"slab_teacher": { "name": "Teacher Slab", "cost": 8, "rarity": "Uncommon", "unlock_boss": 1, "desc": "Adjacent slabs +5 Value." },
	"slab_support": { "name": "Support Slab", "cost": 8, "rarity": "Uncommon", "unlock_boss": 1, "desc": "Adjacent slabs x1.2 Value." },
	
	# -- CALLER 2 (Economy) --
	"slab_thief": { "name": "Thief Slab", "cost": 10, "rarity": "Uncommon", "unlock_boss": 2, "desc": "Steals points from neighbors, gains Obols." },
	"slab_merchant": { "name": "Merchant Slab", "cost": 12, "rarity": "Rare", "unlock_boss": 2, "desc": "Sells for 10x Price." },
	
	# -- CALLER 3 (Shapes) --
	"slab_conductor": { "name": "Conductor Slab", "cost": 15, "rarity": "Rare", "unlock_boss": 3, "desc": "Buffs Diagonal Lines from Center." },
	"slab_bridge": { "name": "Bridge Slab", "cost": 15, "rarity": "Rare", "unlock_boss": 3, "desc": "Connects non-adjacent lines." },
	
	# -- CALLER 4 (Multipliers) --
	"slab_glass": { "name": "Glass Slab", "cost": 10, "rarity": "Rare", "unlock_boss": 4, "desc": "x4 Score, 25% Break chance." },
	"slab_heavy": { "name": "Heavy Slab", "cost": 8, "rarity": "Uncommon", "unlock_boss": 4, "desc": "+20 Value, -0.5x Line Mult." },
	
	# -- CALLER 5 (Wilds) --
	"slab_wild_l": { "name": "Wild Letter", "cost": 20, "rarity": "Legendary", "unlock_boss": 5, "desc": "Matches any Letter." },
	"slab_copycat": { "name": "Copycat Slab", "cost": 18, "rarity": "Rare", "unlock_boss": 5, "desc": "Copies slab to the left." },
	
	# -- CALLER 6 (Manipulation) --
	"slab_magnet": { "name": "Magnet Slab", "cost": 12, "rarity": "Rare", "unlock_boss": 6, "desc": "Pulls slabs towards it." },
	"slab_eraser": { "name": "Eraser Slab", "cost": 15, "rarity": "Legendary", "unlock_boss": 6, "desc": "Removes Target Requirement from slot." },

	# -- CALLER 7 (Death/Risk) --
	"slab_vampire": { "name": "Vampire Slab", "cost": 25, "rarity": "Legendary", "unlock_boss": 7, "desc": "Absorbs value from board." },
	"slab_blood": { "name": "Blood Slab", "cost": 20, "rarity": "Rare", "unlock_boss": 7, "desc": "Gains power when you lose a round." },
	
	# -- CALLER 8 (God Tier) --
	"slab_void": { "name": "Void Slab", "cost": 50, "rarity": "Legendary", "unlock_boss": 8, "desc": "A curse or a blessing?" }
}

# 2. ARTIFACTS (Passive Items)
var artifacts_db = {
	# -- STARTER --
	"art_chalk": { "name": "Chalk of Tallying", "cost": 15, "rarity": "Common", "unlock_boss": 0, "desc": "Lines gain +0.1 Mult when scored." },
	"art_odd": { "name": "Odd Totem", "cost": 15, "rarity": "Common", "unlock_boss": 0, "desc": "Odd numbers +5 Score." },
	
	# -- UNLOCKS --
	"art_h_beam": { "name": "H-Beam", "cost": 30, "rarity": "Rare", "unlock_boss": 3, "desc": "H-Shape easier to trigger." },
	"art_midas": { "name": "Midas Abacus", "cost": 40, "rarity": "Legendary", "unlock_boss": 2, "desc": "Gain Obols based on Score Multiplier." },
	"art_piston": { "name": "Vertical Piston", "cost": 25, "rarity": "Rare", "unlock_boss": 4, "desc": "Vertical Lines scale faster." }
}

# 3. DEATH GIFTS (Meta Upgrades)
var death_gifts_db = {
	"gift_pocket": { "name": "Extra Pocket", "cost": 50, "type": "Rules", "desc": "+1 Draw per turn." },
	"gift_bias_low": { "name": "Low Bias", "cost": 30, "type": "RNG", "desc": "More 1-5 Numbers appear." },
	"gift_uncapped": { "name": "Uncapped Potential", "cost": 100, "type": "Rules", "desc": "Remove score limits." }
}
