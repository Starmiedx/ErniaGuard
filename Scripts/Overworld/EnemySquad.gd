extends CharacterBody2D

const SPEED = 60.0
const PATROL_WAIT_TIME = 2.0

var enemy_id = 0
var patrol_points = []
var current_patrol_index = 0
var is_moving = false
var wait_timer = 0.0
var is_waiting = false

@onready var nav_agent = $NavigationAgent2D
@onready var area = $Area2D

func _ready():
	await get_tree().physics_frame
	area.body_entered.connect(_on_body_entered)
	if patrol_points.size() > 0:
		move_to_next_patrol()

func _physics_process(delta):
	if is_waiting:
		wait_timer -= delta
		if wait_timer <= 0:
			is_waiting = false
			move_to_next_patrol()
		return

	if is_moving:
		if nav_agent.is_navigation_finished():
			is_moving = false
			velocity = Vector2.ZERO
			move_and_slide()
			is_waiting = true
			wait_timer = PATROL_WAIT_TIME
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
			return
		var next = nav_agent.get_next_path_position()
		var direction = (next - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func move_to_next_patrol():
	if patrol_points.size() == 0:
		return
	is_moving = true
	await get_tree().physics_frame
	nav_agent.target_position = patrol_points[current_patrol_index]

func _on_body_entered(body):
	print("something entered: ", body.name)
	if body is CharacterBody2D and body.name.begins_with("PlayerSquad"):
		print("Battle triggering!")
		GameState.active_enemy_id = enemy_id
		call_deferred("_start_battle")

func _start_battle():
	get_tree().change_scene_to_file("res://Scenes/Battle/Battle.tscn")
