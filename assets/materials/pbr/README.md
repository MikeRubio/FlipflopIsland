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
