extends Node2D

const TILE_SIZE = 32
const GRID_WIDTH = 30
const GRID_HEIGHT = 30

@onready var camera = $Camera2D
@onready var turn_label = $CanvasLayer/TurnLabel

var current_turn = "player"
var player_units = []
var enemy_units = []
var selected_unit = null
var move_highlights = []
var attack_highlights = []

func _ready():
	setup_camera()
	spawn_units()
	update_turn_label()

func setup_camera():
	camera.position = Vector2(GRID_WIDTH * TILE_SIZE / 2, GRID_HEIGHT * TILE_SIZE / 2)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = GRID_WIDTH * TILE_SIZE
	camera.limit_bottom = GRID_HEIGHT * TILE_SIZE
	camera.zoom = Vector2(1.5, 1.5)

func spawn_units():
	pass

func update_turn_label():
	if current_turn == "player":
		turn_label.text = "Player Turn"
	else:
		turn_label.text = "Enemy Turn"

func end_player_turn():
	current_turn = "enemy"
	update_turn_label()
	selected_unit = null
	clear_highlights()
	await get_tree().create_timer(0.5).timeout
	run_enemy_turn()

func run_enemy_turn():
	await get_tree().create_timer(1.0).timeout
	current_turn = "player"
	for unit in player_units:
		unit.has_acted = false
	update_turn_label()

func clear_highlights():
	for h in move_highlights:
		h.queue_free()
	move_highlights.clear()
	for h in attack_highlights:
		h.queue_free()
	attack_highlights.clear()

func world_to_tile(pos: Vector2) -> Vector2i:
	return Vector2i(int(pos.x / TILE_SIZE), int(pos.y / TILE_SIZE))

func tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * TILE_SIZE + TILE_SIZE / 2, tile.y * TILE_SIZE + TILE_SIZE / 2)
