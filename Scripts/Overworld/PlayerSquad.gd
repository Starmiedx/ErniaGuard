extends CharacterBody2D

const SPEED = 160.0

var is_selected = false
var target_position = Vector2.ZERO
var is_moving = false
var squad_id = 0

@onready var nav_agent = $NavigationAgent2D
@onready var sprite = $Sprite2D

func _ready():
	# Wait one frame for navigation to initialize
	await get_tree().physics_frame
	target_position = global_position

func _physics_process(_delta):
	if is_moving:
		if nav_agent.is_navigation_finished():
			is_moving = false
			velocity = Vector2.ZERO
			move_and_slide()
			return
		var next = nav_agent.get_next_path_position()
		var direction = (next - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func move_to(pos: Vector2):
	target_position = pos
	is_moving = true
	# Wait one frame then set target
	await get_tree().physics_frame
	nav_agent.target_position = pos

func select():
	is_selected = true
	sprite.modulate = Color(1.5, 1.5, 0.5)

func deselect():
	is_selected = false
	sprite.modulate = Color(1, 1, 1)
