extends Node3D

# Simple wind motion for visual-only island dressing.
# It scans for leaf and grass MeshInstance3D nodes, remembers their starting
# transforms, and applies a subtle rotation. Collision shapes are not moved.

@export var wind_enabled: bool = true
@export var wind_speed: float = 0.75
@export var leaf_sway_degrees: float = 2.0
@export var grass_sway_degrees: float = 1.2
@export var scan_root_path: NodePath = NodePath("..")

var _time: float = 0.0
var _sway_nodes: Array[Dictionary] = []


func _ready() -> void:
	var scan_root := get_node_or_null(scan_root_path)
	if scan_root == null:
		scan_root = get_parent()

	if scan_root != null:
		_collect_sway_nodes(scan_root)


func _process(delta: float) -> void:
	if not wind_enabled:
		return

	_time += delta * wind_speed

	for entry in _sway_nodes:
		var node := entry["node"] as Node3D
		if node == null:
			continue

		var start_transform: Transform3D = entry["start_transform"]
		var amount: float = entry["amount"]
		var phase: float = entry["phase"]
		var sway := deg_to_rad(sin(_time + phase) * amount)
		node.transform = start_transform * Transform3D(Basis(Vector3.FORWARD, sway), Vector3.ZERO)


func _collect_sway_nodes(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_node := node as MeshInstance3D
		var lower_name := mesh_node.name.to_lower()
		var should_sway := lower_name.contains("leaves") or lower_name.contains("grasspatch")

		if should_sway:
			var amount := grass_sway_degrees if lower_name.contains("grass") else leaf_sway_degrees
			_sway_nodes.append({
				"node": mesh_node,
				"start_transform": mesh_node.transform,
				"amount": amount,
				"phase": float(_sway_nodes.size()) * 0.67,
			})

	for child in node.get_children():
		_collect_sway_nodes(child)
