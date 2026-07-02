# Materials

Reusable visual material resources for Flipflop Island.

These are lightweight Godot StandardMaterial3D resources intended as the first realistic style pass. They use simple colors, roughness, metallic, and transparency values so they stay cheap and easy to replace later with texture-backed materials.

Suggested future workflow:
- Put shared `.tres` materials in this folder.
- Put texture maps in `res://assets/textures/`.
- Keep scenery-specific experimental materials inside scenes only until they are worth reusing.
