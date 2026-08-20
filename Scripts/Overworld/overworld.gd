extends Node2D

const TILE_SIZE = 32
const MAP_WIDTH = 100
const MAP_HEIGHT = 100

const PlayerSquadScene = preload("res://Scenes/Overworld/PlayerSquad.tscn")
const EnemySquadScene = preload("res://Scenes/Overworld/EnemySquad.tscn")

@onready var camera = $Camera2D

var selected_squad = null
var player_squads = []
var enemy_squads = []

# Camera panning variables
var is_panning = false
var pan_start_mouse = Vector2.ZERO
var pan_start_camera = Vector2.ZERO
const CAMERA_PAN_BUTTON = MOUSE_BUTTON_RIGHT
const KEYBOARD_PAN_SPEED = 400.0

var squad_start_positions = [
	Vector2(2, 2),
	Vector2(4, 2),
	Vector2(6, 2),
	Vector2(2, 4),
	Vector2(4, 4),
	Vector2(6, 4),
]

var enemy_patrol_points = [
	[Vector2(20, 20), Vector2(30, 20)],
	[Vector2(40, 10), Vector2(40, 25)],
	[Vector2(60, 15), Vector2(70, 25)],
	[Vector2(25, 50), Vector2(40, 50)],
	[Vector2(55, 45), Vector2(65, 55)],
	[Vector2(15, 70), Vector2(30, 70)],
	[Vector2(50, 70), Vector2(60, 80)],
	[Vector2(75, 30), Vector2(85, 45)],
]

func _ready():
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = MAP_WIDTH * TILE_SIZE
	camera.limit_bottom = MAP_HEIGHT * TILE_SIZE
	camera.zoom = Vector2(2, 2)
	camera.position = Vector2(200, 200)
	spawn_player_squads()
	spawn_enemy_squads()

func spawn_player_squads():
	for i in range(6):
		var squad = PlayerSquadScene.instantiate()
		add_child(squad)
		squad.global_position = squad_start_positions[i] * TILE_SIZE
		squad.squad_id = i
		player_squads.append(squad)

func spawn_enemy_squads():
	for i in range(8):
		var squad = EnemySquadScene.instantiate()
		add_child(squad)
		squad.name = "EnemySquad" + str(i)
		squad.enemy_id = i
		squad.global_position = enemy_patrol_points[i][0] * TILE_SIZE
		var points = []
		for p in enemy_patrol_points[i]:
			points.append(p * TILE_SIZE)
		squad.patrol_points = points
		enemy_squads.append(squad)

func _input(event):
	# Right click to pan
	if event is InputEventMouseButton:
		if event.button_index == CAMERA_PAN_BUTTON:
			if event.pressed:
				is_panning = true
				pan_start_mouse = event.position
				pan_start_camera = camera.position
			else:
				is_panning = false

	# Mouse drag panning
	if event is InputEventMouseMotion and is_panning:
		var offset = (event.position - pan_start_mouse) / camera.zoom
		camera.position = pan_start_camera - offset
		clamp_camera()

	# Left click for squad selection and movement
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_pos = get_global_mouse_position()
		var clicked_squad = get_squad_at(click_pos)
		if clicked_squad:
			if selected_squad:
				selected_squad.deselect()
			selected_squad = clicked_squad
			selected_squad.select()
		elif selected_squad:
			selected_squad.move_to(click_pos)

	# Scroll wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom = camera.zoom * 1.1
			camera.zoom = camera.zoom.clamp(Vector2(0.5, 0.5), Vector2(4, 4))
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom = camera.zoom * 0.9
			camera.zoom = camera.zoom.clamp(Vector2(0.5, 0.5), Vector2(4, 4))

func _process(delta):
	# Keyboard camera panning with WASD
	var pan_dir = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		pan_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		pan_dir.x += 1
	if Input.is_action_pressed("ui_up"):
		pan_dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		pan_dir.y += 1
	if pan_dir != Vector2.ZERO:
		camera.position += pan_dir * KEYBOARD_PAN_SPEED * delta / camera.zoom
		clamp_camera()

func clamp_camera():
	camera.position.x = clamp(camera.position.x, 0, MAP_WIDTH * TILE_SIZE)
	camera.position.y = clamp(camera.position.y, 0, MAP_HEIGHT * TILE_SIZE)

func get_squad_at(pos: Vector2) -> CharacterBody2D:
	for squad in player_squads:
		if squad.global_position.distance_to(pos) < TILE_SIZE:
			return squad
	return null
