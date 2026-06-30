extends Node3D

# Scale notes for the placeholder 3D island.
# Treat 1 Godot unit as roughly 1 meter.
#
# These exported values are documentation/tuning notes for the scene. The actual
# placeholder geometry is still edited in Island3D.tscn so beginners can inspect
# the meshes and collision shapes directly.
@export var island_radius: float = 45.0
@export var beach_size: Vector2 = Vector2(90.0, 65.0)
@export var prop_scale: float = 1.0
@export var water_size: float = 150.0
@export var boundary_size: float = 75.0
#
# Main playable island size is controlled in Island3D.tscn by:
# - CylinderMesh_island top_radius/bottom_radius
# - CylinderShape3D_island radius
# - SandIsland transform scale, especially the Z scale for the oval beach
#
# Prop scale is controlled in the individual prop scenes:
# - scenes/props/Coconut3D.tscn
# - scenes/props/Shell3D.tscn
# - scenes/props/Driftwood3D.tscn
# - scenes/props/BeachBall3D.tscn
# - scenes/props/Rock3D.tscn
# - scenes/props/Crab3D.tscn
#
# Movable props use scripts/props/simple_prop_3d.gd. Tune prop_mass, bounce,
# friction, prop_linear_damp, and prop_angular_damp there or on each prop scene.
#
# This script intentionally has no gameplay logic. It is attached only so a
# beginner can quickly find the sizing notes from the Island3D root node.
