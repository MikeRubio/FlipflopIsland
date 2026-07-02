# PBR Material Resources

These `StandardMaterial3D` resources wrap the downloaded 3DTextures.me maps in `res://assets/textures/pbr/`.

## Materials

- `sand.tres` uses `res://assets/textures/pbr/sand/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `ocean_water.tres` uses `res://assets/textures/pbr/ocean_water/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `rock.tres` uses `res://assets/textures/pbr/rock/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `palm_bark.tres` uses `res://assets/textures/pbr/palm_bark/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `wood_planks.tres` uses `res://assets/textures/pbr/wood_planks/`
  - Connected: albedo, normal, roughness, AO, metallic.
  - Ignored for now: height.
- `wood.tres` uses `res://assets/textures/pbr/wood/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `old_wood.tres` uses `res://assets/textures/pbr/old_wood/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `dry_tile.tres` uses `res://assets/textures/pbr/dry_tile/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `wet_tile.tres` uses `res://assets/textures/pbr/wet_tile/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `rubber_mat.tres` uses `res://assets/textures/pbr/rubber_mat/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `plastic.tres` uses `res://assets/textures/pbr/plastic/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `glass.tres` uses `res://assets/textures/pbr/glass/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height and transmissive.

## Expansion 02 Materials

- `wet_ground.tres` uses `res://assets/textures/pbr/wet_ground/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
  - UV scale: `Vector3(12, 12, 1)` for shoreline, puddles, and damp ground patches.
- `wet_pebbles.tres` uses `res://assets/textures/pbr/wet_pebbles/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
  - UV scale: `Vector3(10, 10, 1)` for tide pool stones and pebble patches.
- `fabric_polyester.tres` uses `res://assets/textures/pbr/fabric_polyester/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
  - Note: the downloaded opacity map is preserved in originals but is not connected to this opaque towel/chair fabric material.
- `fabric_mesh.tres` uses `res://assets/textures/pbr/fabric_mesh/`
  - Connected: albedo, normal, roughness, AO.
  - Missing: opacity.
  - Ignored for now: height.
  - Note: kept opaque because no opacity map was available in the public free download.
- `padded_leather.tres` uses `res://assets/textures/pbr/padded_leather/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `rope.tres` uses `res://assets/textures/pbr/rope/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
  - Uses a stronger normal scale for rope fiber detail.
- `weathered_metal.tres` uses `res://assets/textures/pbr/weathered_metal/`
  - Connected: albedo, normal, roughness, AO, metallic.
  - Ignored for now: height.
- `metal_plate.tres` uses `res://assets/textures/pbr/metal_plate/`
  - Connected: albedo, normal, roughness, AO, metallic.
  - Ignored for now: height and emissive.
  - Note: the emissive map is preserved but not enabled because ship panels, lockers, and trash cans should not glow by default.
- `metal_grill.tres` uses `res://assets/textures/pbr/metal_grill/`
  - Connected: albedo, normal, roughness, AO, metallic.
  - Ignored for now: height and opacity.
  - Note: the opacity map is preserved but not connected to avoid alpha sorting artifacts on drains and grates.
- `concrete_wall.tres` uses `res://assets/textures/pbr/concrete_wall/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `subway_tile.tres` uses `res://assets/textures/pbr/subway_tile/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `terracotta_tile.tres` uses `res://assets/textures/pbr/terracotta_tile/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
- `wicker.tres` uses `res://assets/textures/pbr/wicker/`
  - Connected: albedo, normal, roughness, AO.
  - Ignored for now: height.
  - Uses a stronger normal scale for woven detail.
- `foam.tres` uses `res://assets/textures/pbr/foam/`
  - Connected: albedo, normal, roughness, AO.
  - Missing: opacity.
  - Ignored for now: height.
  - Note: kept opaque because no opacity map was available in the public free download.

## Replacing Textures

Keep the same filenames inside each texture folder if possible. The material resources reference those paths directly, so replacing `sand_albedo.png` with a new texture at the same path updates `sand.tres` automatically.

## UV Tiling

Adjust `uv1_scale` inside each `.tres` file to change tiling:

- Increase `uv1_scale` for more repeated texture detail on large surfaces.
- Decrease `uv1_scale` if the pattern looks too busy or obviously repeated.

Large terrain materials like sand and water use higher UV scale. Small prop materials like plastic and glass use lower UV scale.

Scene assignment note: large placeholder primitives now share these material-level UV scales. If a specific mesh still looks stretched, especially cylinders, spheres, ramps, or very thin boxes, give that mesh proper UVs or create a dedicated material instance with adjusted `uv1_scale`.

## Avoiding Overly Shiny Surfaces

If a material looks too shiny, raise its `roughness` value or reduce the contrast of the roughness texture. Sand, rock, bark, old wood, and rubber should stay high roughness. Wet tile, water, glass, and some plastic can be lower roughness, but avoid pushing them so low that they become mirror-like.

Height maps are intentionally not connected yet. Add parallax or displacement later only after testing mesh scale, UVs, and performance in Godot.

## Transparency / Opacity Notes

Only `ocean_water.tres` and `glass.tres` use transparency right now. The expansion materials are opaque on purpose:

- `metal_grill_opacity.png` exists but is not connected yet, because alpha grates can produce sorting artifacts on overlapping placeholder geometry.
- `fabric_mesh_opacity.png` and `foam_opacity.png` were not present in the public free downloads.
- `fabric_polyester` and `metal_plate` had extra opacity maps preserved in the download folders, but the current material use cases read better as opaque.

If opacity is needed later, duplicate the material first, enable transparency on the duplicate, test it in each scenery, and keep the opaque version as the fallback.
