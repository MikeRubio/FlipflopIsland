extends Node3D

# Peaceful wildlife ambience.
# Crabs get tiny wandering nudges, simple bird placeholders drift in the far
# background, and fish splash markers pulse occasionally in the water.

@export var wildlife_enabled: bool = true
@export var crab_wander_force: float = 0.025
@export var crab_turn_interval: float = 3.5
@export var bird_flight_speed: float = 0.35
@export var fish_splash_interval: float = 7.0

var _time: float = 0.0
var _crabs: Array[RigidBody3D] = []
var _crab_directions: Array[Vector3] = []
var _crab_turn_timer: float = 0.0
var _birds: Array[Node3D] = []
var _fish_splashes: Array[Node3D] = []
var _fish_timer: float = 0.0
var _active_splash_index: int = -1
var _active_splash_time: float = 0.0


func _ready() -> void:
	_collect_nodes(self)
	_reset_crab_directions()
	_fish_timer = fish_splash_interval


func _physics_process(delta: float) -> void:
	if not wildlife_enabled:
		return

	_crab_turn_timer -= delta
	if _crab_turn_timer <= 0.0:
		_reset_crab_directions()

	for index in range(_crabs.size()):
		var crab := _crabs[index]
		if crab == null:
			continue

		crab.sleeping = false
		crab.apply_central_force(_crab_directions[index] * crab_wander_force)


func _process(delta: float) -> void:
	if not wildlife_enabled:
		return

	_time += delta
	_animate_birds(delta)
	_animate_fish_splashes(delta)


func _collect_nodes(node: Node) -> void:
	if node is RigidBody3D and node.name.to_lower().contains("crab"):
		_crabs.append(node as RigidBody3D)

	if node is Node3D and node.name.to_lower().contains("distantbird"):
		_birds.append(node as Node3D)

	if node is Node3D and node.name.to_lower().contains("fishsplash"):
		_fish_splashes.append(node as Node3D)
		(node as Node3D).visible = false

	for child in node.get_children():
		_collect_nodes(child)


func _reset_crab_directions() -> void:
	_crab_directions.clear()

	for crab in _crabs:
		var angle := randf_range(0.0, TAU)
		_crab_directions.append(Vector3(cos(angle), 0.0, sin(angle)).normalized())

	_crab_turn_timer = crab_turn_interval

	if not _crabs.is_empty():
		_play_audio_hook("play_crab_skitter")


func _animate_birds(delta: float) -> void:
	for index in range(_birds.size()):
		var bird := _birds[index]
		if bird == null:
			continue

		bird.position.x += bird_flight_speed * delta * (1.0 + index * 0.25)
		bird.position.y += sin(_time * 1.4 + index) * 0.003

		if bird.position.x > 58.0:
			bird.position.x = -58.0


func _animate_fish_splashes(delta: float) -> void:
	if _fish_splashes.is_empty():
		return

	_fish_timer -= delta

	if _fish_timer <= 0.0 and _active_splash_index == -1:
		_active_splash_index = randi_range(0, _fish_splashes.size() - 1)
		_active_splash_time = 0.0
		_fish_splashes[_active_splash_index].visible = true
		_fish_timer = fish_splash_interval + randf_range(-2.0, 2.0)

	if _active_splash_index == -1:
		return

	var splash := _fish_splashes[_active_splash_index]
	_active_splash_time += delta
	var pulse := clampf(_active_splash_time / 0.8, 0.0, 1.0)
	splash.scale = Vector3.ONE * lerpf(0.25, 1.2, pulse)

	if _active_splash_time >= 0.8:
		splash.visible = false
		splash.scale = Vector3.ONE * 0.25
		_active_splash_index = -1


func _play_audio_hook(method_name: String) -> void:
	var audio: Node = get_tree().get_first_node_in_group("ambience_audio")
	if audio != null and audio.has_method(method_name):
		audio.call(method_name)
