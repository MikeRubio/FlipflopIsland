# Flipflop Island PBR Material Audit

Date: 2026-07-02

Scope: Static file audit of `res://assets/materials/pbr/`, `res://assets/textures/pbr/`, the five 3D scenery scenes, and reusable 3D prop scenes that currently use the PBR materials.

Runtime note: Godot was not available on PATH during this audit, so this is a source/resource validation pass rather than an in-editor render test.

## Summary

- Materials found: 12 `StandardMaterial3D` PBR resources.
- Texture files found: 61 PNG files under `res://assets/textures/pbr/`.
- Texture resolution: all audited PNGs are `1024x1024`.
- Disk size: about `55.84 MiB` for the PNG texture files.
- Import sidecars: every audited PNG has a matching `.import` file.
- Broken material texture paths: none found.
- Missing connected maps: none found for albedo, normal, roughness, or AO.
- Height/displacement usage: no height/displacement maps are connected in material resources.
- Gameplay safety: no gameplay scripts, collision shapes, controls, scenery switching, debug UI, prop reset logic, or water physics were changed by this audit.

## Materials Found

| Material | Connected maps | Extra maps | UV scale | Notes |
| --- | --- | --- | --- | --- |
| `sand.tres` | albedo, normal, roughness, AO | height ignored | `Vector3(24, 24, 1)` | High roughness, appropriate for island and beach sand. |
| `ocean_water.tres` | albedo, normal, roughness, AO | height ignored | `Vector3(10, 10, 1)` | Transparent blue water material. Visible, not a collider. |
| `rock.tres` | albedo, normal, roughness, AO | height ignored | `Vector3(4, 4, 1)` | High roughness, good for boulders and loose rocks. |
| `palm_bark.tres` | albedo, normal, roughness, AO | height ignored | `Vector3(5, 5, 1)` | Used on island palm trunks. |
| `wood_planks.tres` | albedo, normal, roughness, AO | metallic connected, height ignored | `Vector3(10, 10, 1)` | Used on large boardwalk/deck surfaces. Metallic scalar is `0.0`, so it should remain visually non-metallic. |
| `wood.tres` | albedo, normal, roughness, AO | height ignored | `Vector3(5, 5, 1)` | General wood for benches, tables, railings, signs. |
| `old_wood.tres` | albedo, normal, roughness, AO | height ignored | `Vector3(5, 5, 1)` | Weathered wood for crates, driftwood, old planks. |
| `dry_tile.tres` | albedo, normal, roughness, AO | height ignored | `Vector3(9, 9, 1)` | Medium roughness for dry tile. |
| `wet_tile.tres` | albedo, normal, roughness, AO | height ignored | `Vector3(9, 9, 1)` | Lower roughness than dry tile, should read as wetter/slipperier. |
| `rubber_mat.tres` | albedo, normal, roughness, AO | height ignored | `Vector3(7, 7, 1)` | Dark, high-roughness rubber. |
| `plastic.tres` | albedo, normal, roughness, AO | height ignored | `Vector3(3, 3, 1)` | Shared by many bottles, cups, toys, props. |
| `glass.tres` | albedo, normal, roughness, AO | height ignored, transmissive ignored | `Vector3(2, 2, 1)` | Transparent with alpha around `0.52`; not invisible. |

## Texture Import Status

- All material texture references point to existing PNG files.
- Every PNG has a matching `.png.import` sidecar.
- All checked textures are `1024x1024`; no 4K textures are present.
- Height maps are present in the texture folders but intentionally unused.
- No expensive custom shader resources were added for this PBR pass.

## Material Usage By Scenery

| PBR material | Current usage |
| --- | --- |
| `sand.tres` | Deserted Island terrain, dunes, sand ripples, sand mounds, sandcastle chunk prop, Boardwalk sand areas. |
| `ocean_water.tres` | Island ocean plane and tide pools, Resort Pool water and wet glints, Boardwalk ocean plane, Cruise Ship ocean/pool water, Locker Room shower water visuals. |
| `rock.tres` | Island boulders, reusable `Rock3D`, reusable `LooseRock3D`. |
| `palm_bark.tres` | Island palm trunk and palm sprout trunk meshes. |
| `wood_planks.tres` | Boardwalk deck/stairs/ramps, Cruise Ship deck/stairs/ramp. |
| `wood.tres` | Boardwalk railings/benches/signs/food stand, Resort lounge chairs/tables, Cruise lounge chairs/tables, Locker Room bench. |
| `old_wood.tres` | Island broken sign and washed-up crates, reusable `Driftwood3D`, Boardwalk weathered planks/crates/boxes. |
| `dry_tile.tres` | Resort dry pool deck, pool edge, tile seams, Locker Room dry tile floor/walls/step. |
| `wet_tile.tres` | Resort wet tile/puddles, Cruise wet deck patches, Locker Room wet tile and soap slick visuals. |
| `rubber_mat.tres` | Cruise rubber mat and Locker Room rubber mats. |
| `plastic.tres` | Beach ball prop, Resort bottles/cups/pool toys/signs/planters, Boardwalk bottles/trash/sandals, Cruise cups/bottles/floats/crates, Locker Room bottles/buckets/sign/sandals. |
| `glass.tres` | Island stranded bottle and message bottle. |

## Assignment Counts

These counts are from `surface_material_override/0 = ExtResource(...)` assignments to PBR materials.

| Scene/resource | PBR assignments |
| --- | ---: |
| `scenes/island/Island3D.tscn` | 43 |
| `scenes/scenery/ResortPoolScenery3D.tscn` | 62 |
| `scenes/scenery/BoardwalkScenery3D.tscn` | 47 |
| `scenes/scenery/CruiseShipDeckScenery3D.tscn` | 41 |
| `scenes/scenery/LockerRoomScenery3D.tscn` | 42 |
| `scenes/props/Driftwood3D.tscn` | 1 |
| `scenes/props/Rock3D.tscn` | 1 |
| `scenes/props/LooseRock3D.tscn` | 1 |
| `scenes/props/SandCastleChunk3D.tscn` | 1 |
| `scenes/props/BeachBall3D.tscn` | 2 |

## Placeholder Materials Still Remaining

These are intentional for now because there is no matching PBR material yet or because the placeholder color is important for readability.

| File | Remaining placeholders |
| --- | --- |
| `Island3D.tscn` | birds, dry leaves, foam, grass, palm leaves, seaweed, shells, splashes. |
| `Coconut3D.tscn` | coconut material. |
| `PalmLeaf3D.tscn` | palm leaf material. |
| `Shell3D.tscn` | shell material. |
| `BoardwalkScenery3D.tscn` | awnings, birds, cans, cones, foam, metal, umbrellas. |
| `CruiseShipDeckScenery3D.tscn` | birds, metal, railings, towels, umbrellas. |
| `LockerRoomScenery3D.tscn` | dark drain material, lockers, metal, sponge, towels. |
| `ResortPoolScenery3D.tscn` | metal, plants, shower fixtures, towels, umbrellas. |

## Water And Physics Safety

- Water visuals use `MeshInstance3D` nodes with `ocean_water.tres`.
- Gameplay water zones remain `Area3D`-based:
  - Island ocean uses `wave_push_zone_3d.gd`.
  - Pool, Boardwalk, Cruise, and Locker Room water zones use `pool_water_zone_3d.gd`.
- Island `Water/OceanFloor` has a `StaticBody3D`, but its collision shape remains `disabled = true`.
- No water material assignment creates physical collision.
- No `PhysicsMaterial`, `CollisionShape3D`, player script, camera script, scenery manager, debug panel, prop reset, or movement preset logic was changed by this audit.

## Visual Quality Notes

- Sand uses high material UV tiling and should avoid the worst stretching on large island/beach surfaces.
- Dry and wet tile share scale but differ strongly in roughness (`dry_tile` around `0.55`, `wet_tile` around `0.24`), so wet areas should read shinier.
- Boardwalk and cruise deck planks use `wood_planks.tres` with higher UV tiling for larger surfaces.
- Props remain readable, but shared `plastic.tres` makes many plastic objects visually similar until object-specific colors/material instances are added.
- Water remains simple but visible: transparent blue material plus existing water ambience bob/color pulse script.
- Player visibility should remain acceptable because sand/tile/wood are mid-value materials and the flipflop player material was not changed.

## Problems Found

- No broken texture references found.
- No missing `.import` sidecars found.
- No missing albedo/normal/roughness/AO connections found.
- No height/displacement maps are connected, which is safe for this prototype.
- No 4K texture memory issue found; all PBR PNGs are 1K.
- Known visual limitation: placeholder primitive meshes can still show texture stretching on cylinders, spheres, ramps, and very thin boxes because they do not have authored UVs.
- Known visual limitation: `plastic.tres` is used broadly, so cups, bottles, pool toys, signs, and buckets may look too samey.
- Known visual limitation: metal, cloth/towel, foliage, shell, coconut, foam, and locker-specific PBR materials do not exist yet.
- Runtime render validation was not performed because the Godot executable was not available in the shell environment.

## Recommended Fixes

1. Do an in-editor visual pass through each scenery and adjust `uv1_scale` or create material instances for any visibly stretched object.
2. Add dedicated PBR materials later for cloth/towel, metal, painted metal, foliage, shells, coconuts, foam, and colored plastic variants.
3. Consider removing the `metallic_texture` from `wood_planks.tres` if it produces any unexpected shimmer, even though `metallic = 0.0` should keep it safe.
4. Add object-specific color variation for plastic props so bottles, cups, toys, signs, and buckets remain distinguishable.
5. Keep height/displacement disabled until mesh UVs, collision scale, and performance are tested in Godot.
6. When Godot is available, run each scenery and verify: water visibility, tile sheen, boardwalk plank direction, sand repetition, prop readability, and player contrast.

## Readiness

The texture/material set is ready for the menu visual pass from a file integrity and performance standpoint. The main remaining work is art polish, not stability: better authored UVs, more material variety, and a live in-editor visual review.
