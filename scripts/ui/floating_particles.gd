extends Node2D

# Floating particle system for atmospheric effects
const PARTICLE_COUNT = 40
var particles = []

class Particle:
	var position: Vector2
	var velocity: Vector2
	var size: float
	var lifetime: float
	var max_lifetime: float
	var color: Color
	var alpha: float
	
	func _init():
		reset()
	
	func reset():
		position = Vector2(randf() * 1920, 1080 + 100)  # Start below screen
		velocity = Vector2(randf_range(-10, 10), -randf_range(20, 60))
		size = randf_range(1, 3)
		max_lifetime = randf_range(4, 10)
		lifetime = 0
		
		# Mystical blue/purple particle colors
		var colors = [
			Color(0.3, 0.6, 1.0),    # Cyan-blue
			Color(0.7, 0.4, 1.0),    # Purple
			Color(0.5, 0.8, 1.0),    # Light blue
			Color(1.0, 0.5, 0.8),    # Pink
		]
		color = colors[randi() % colors.size()]
		alpha = 0.0

func _ready():
	# Create all particles
	for i in range(PARTICLE_COUNT):
		var particle = Particle.new()
		particle.lifetime = randf() * particle.max_lifetime  # Stagger start times
		particles.append(particle)
	
	# Make sure we redraw every frame
	set_process(true)

func _process(delta):
	for particle in particles:
		# Update lifetime
		particle.lifetime += delta
		
		# Reset if lifetime exceeded
		if particle.lifetime >= particle.max_lifetime:
			particle.reset()
			particle.lifetime = 0
		
		# Update position
		particle.position += particle.velocity * delta
		
		# Calculate alpha based on lifetime (fade in and out)
		var life_ratio = particle.lifetime / particle.max_lifetime
		if life_ratio < 0.1:
			particle.alpha = life_ratio / 0.1 * 0.8
		elif life_ratio > 0.9:
			particle.alpha = (1.0 - life_ratio) / 0.1 * 0.8
		else:
			particle.alpha = 0.6
	
	queue_redraw()

func _draw():
	for particle in particles:
		var color_with_alpha = particle.color
		color_with_alpha.a = particle.alpha
		
		# Draw a glowing circle
		draw_circle(particle.position, particle.size, color_with_alpha)
		
		# Draw an outer glow
		var glow_color = particle.color
		glow_color.a = particle.alpha * 0.3
		draw_circle(particle.position, particle.size * 2, glow_color)
