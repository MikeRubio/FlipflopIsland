# Flipflop Island PBR Material Audit - Expansion 02

Date: 2026-07-02

Scope: second 3DTextures.me texture expansion pack only. This audit checks the downloaded files, organized texture copies, Godot `StandardMaterial3D` resources, scene assignments, and gameplay safety risks.

## Summary

- The second expansion download set is preserved in `downloads/3dtextures/originals_expansion_02/`.
- Extracted/intermediate files are preserved in `downloads/3dtextures/extracted_expansion_02/`.
- Normalized project texture copies exist under `res://assets/textures/pbr/`.
- All 14 requested second-expansion material resources exist in `res://assets/materials/pbr/`.
- Material texture references resolve to existing files.
- The new scene assignments are visual-only material overrides.
- No gameplay scripts, player controls, physics scripts, collision shapes, water logic, scenery switching logic, debug panel code, or prop reset scripts were changed as part of the material assignment pass.
- No Patreon-only files, SBS files, SBSAR files, source-tier files, or zero-byte files were found in the checked download/extracted/project texture folders.

Static verdict: stable enough to continue toward menu visual design, with an editor reimport and screenshot pass recommended before treating the texture pass as final.

## Download Audit

Source report: `downloads/3dtextures/download_report_expansion_02.md`

| Texture set | Originals preserved | Extracted preserved | Project copies | Download status | Notes |
|---|---:|---:|---:|---|---|
| `wet_ground` | 5 | 5 | 5 | Succeeded | Public map files only. |
| `wet_pebbles` | 5 | 5 | 5 | Succeeded | Public map files only. |
| `fabric_polyester` | 6 | 6 | 5 | Succeeded | Original opacity map preserved but not copied/used. |
| `fabric_mesh` | 5 | 5 | 5 | Succeeded | Opacity map missing from public files. |
| `padded_leather` | 5 | 5 | 5 | Succeeded | Public map files only. |
| `rope` | 5 | 5 | 5 | Succeeded | Public map files only. |
| `weathered_metal` | 6 | 6 | 6 | Succeeded | Includes metallic map. |
| `metal_plate` | 8 | 8 | 7 | Succeeded | Original opacity map preserved but not copied/used; emissive copied but unused. |
| `metal_grill` | 7 | 7 | 7 | Succeeded | Opacity copied but unused for stability. |
| `concrete_wall` | 5 | 5 | 5 | Succeeded | Public map files only. |
| `subway_tile` | 5 | 5 | 5 | Succeeded | Public map files only. |
| `terracotta_tile` | 5 | 5 | 5 | Succeeded | Public map files only. |
| `wicker` | 5 | 5 | 5 | Succeeded | Public map files only. |
| `foam` | 5 | 5 | 5 | Succeeded | Opacity map missing from public files. |

Skipped content:

- Patreon/Ko-fi/source-tier links were ignored.
- SBS/SBSAR/source files were not downloaded.
- Preview renders named like `Material_*` were skipped.
- Failed downloads: none reported.

Import sidecar note:

- The second-expansion PNG files do not currently have `.import` sidecar files in `res://assets/textures/pbr/`.
- Godot normally generates these when the project is opened or reimported in the editor.
- This is not a broken resource path issue, but it should be verified in the Godot editor before release screenshots or builds.

## New Textures Found

| Texture set | Maps present in `res://assets/textures/pbr/` | Missing maps |
|---|---|---|
| `wet_ground` | albedo, ao, height, normal, roughness | none |
| `wet_pebbles` | albedo, ao, height, normal, roughness | none |
| `fabric_polyester` | albedo, ao, height, normal, roughness | opacity not in final project copy |
| `fabric_mesh` | albedo, ao, height, normal, roughness | opacity |
| `padded_leather` | albedo, ao, height, normal, roughness | none |
| `rope` | albedo, ao, height, normal, roughness | none |
| `weathered_metal` | albedo, ao, height, metallic, normal, roughness | none |
| `metal_plate` | albedo, ao, emissive, height, metallic, normal, roughness | opacity not in final project copy |
| `metal_grill` | albedo, ao, height, metallic, normal, opacity, roughness | none |
| `concrete_wall` | albedo, ao, height, normal, roughness | none |
| `subway_tile` | albedo, ao, height, normal, roughness | none |
| `terracotta_tile` | albedo, ao, height, normal, roughness | none |
| `wicker` | albedo, ao, height, normal, roughness | none |
| `foam` | albedo, ao, height, normal, roughness | opacity |

## New Materials Created

| Material | Connected maps | Ignored maps | Key settings |
|---|---|---|---|
| `wet_ground.tres` | albedo, normal, roughness, ao | height | roughness 0.48, UV scale 12x12 |
| `wet_pebbles.tres` | albedo, normal, roughness, ao | height | roughness 0.42, UV scale 10x10 |
| `fabric_polyester.tres` | albedo, normal, roughness, ao | height, original opacity | roughness 0.90, UV scale 4x4 |
| `fabric_mesh.tres` | albedo, normal, roughness, ao | height | roughness 0.84, UV scale 6x6, opaque for stability |
| `padded_leather.tres` | albedo, normal, roughness, ao | height | roughness 0.60, UV scale 3x3 |
| `rope.tres` | albedo, normal, roughness, ao | height | roughness 0.92, UV scale 8x8 |
| `weathered_metal.tres` | albedo, metallic, normal, roughness, ao | height | metallic 0.80, roughness 0.56, UV scale 4x4 |
| `metal_plate.tres` | albedo, metallic, normal, roughness, ao | height, emissive, original opacity | metallic 0.90, roughness 0.52, UV scale 5x5 |
| `metal_grill.tres` | albedo, metallic, normal, roughness, ao | height, opacity | metallic 0.85, roughness 0.58, UV scale 5x5, opaque for stability |
| `concrete_wall.tres` | albedo, normal, roughness, ao | height | roughness 0.88, UV scale 8x8 |
| `subway_tile.tres` | albedo, normal, roughness, ao | height | roughness 0.50, UV scale 8x8 |
| `terracotta_tile.tres` | albedo, normal, roughness, ao | height | roughness 0.74, UV scale 8x8 |
| `wicker.tres` | albedo, normal, roughness, ao | height | roughness 0.86, UV scale 5x5 |
| `foam.tres` | albedo, normal, roughness, ao | height | roughness 0.78, UV scale 4x4, opaque for stability |

Opacity/transparency cleanup:

- `metal_grill_opacity.png` exists, but it is intentionally not connected to avoid sorting artifacts on grates.
- `fabric_mesh` and `foam` remain opaque because their requested opacity maps are not present in the public final map set.
- `fabric_polyester` and `metal_plate` had opacity maps in the original downloads, but these were not copied to the normalized project set and are intentionally unused.
- No second-expansion material enables transparency. This avoids unexpected invisible props.

Height/displacement cleanup:

- Height maps are preserved for every set that provided them.
- No height/displacement maps are connected yet.
- This keeps the materials safe on placeholder geometry and avoids accidental expensive/parallax behavior.

Metallic cleanup:

- Metallic maps are connected only on metal materials: `weathered_metal.tres`, `metal_plate.tres`, and `metal_grill.tres`.
- Non-metal materials do not connect metallic maps.

## Scene Assignment Audit

Detailed assignment report: `res://assets/materials/pbr/material_assignment_report_expansion_02.md`

### Deserted Island

Second-expansion assignments found:

- `wet_ground`: 1 shoreline/wet ground surface
- `wet_pebbles`: 2 tide pool pebble surfaces
- `fabric_mesh`: 2 broken net surfaces
- `weathered_metal`: 1 metal debris/sign surface

Coverage status:

- Wet shoreline, tide pool pebbles, broken fishing net, and metal debris/sign visuals are improved.
- No distinct rope mesh/node was found in this scenery, so `rope.tres` is not assigned on the island yet.
- Existing sand, rock, palm, wood, plastic, glass, and water materials are from the first PBR pass.

### Resort Pool

Second-expansion assignments found:

- `wet_ground`: 6 puddle/wet patch surfaces
- `fabric_polyester`: 4 towel/cloth surfaces
- `padded_leather`: 4 lounge chair cushion surfaces
- `weathered_metal`: 14 metal fixture/pole/sign surfaces
- `terracotta_tile`: 1 patio/decorative tile surface
- `foam`: 6 pool noodle/foam mat surfaces

Coverage status:

- Towels, foam props, lounge chair cushions, wet patches, patio tile, and metal fixtures are improved.
- No actual drain/grate mesh was found in Resort Pool; objects with "Drain" in nearby names were not treated as grates unless they were actual drain meshes.

### Boardwalk

Second-expansion assignments found:

- `wet_ground`: 2 wet boardwalk/wet patch surfaces
- `weathered_metal`: 5 metal sign/can/fixture surfaces
- `metal_plate`: 8 trash can/metal plate/bin surfaces
- `concrete_wall`: 1 food stand/foundation surface

Coverage status:

- Wet patches, metal signs/trash, and concrete/foundation visuals are improved.
- No explicit rope barrier, fishing net, or wicker object nodes were found in this scene, so `rope.tres`, `fabric_mesh.tres`, and `wicker.tres` are not assigned here yet.
- Boardwalk wood and sand continue to use the first PBR material pass.

### Cruise Ship Deck

Second-expansion assignments found:

- `wet_ground`: 2 wet deck patch surfaces
- `fabric_polyester`: 3 towel/cloth surfaces
- `padded_leather`: 3 lounge chair cushion surfaces
- `rope`: 1 lifebuoy/rope placeholder surface
- `weathered_metal`: 14 rail/fixture surfaces
- `metal_plate`: 10 deck panel/metal prop surfaces
- `foam`: 1 pool float/foam surface

Coverage status:

- Deck metal, railings/fittings, wet patches, cushions, towels, lifebuoy rope placeholder, and foam props are improved.
- No separate grate/drain mesh was found in Cruise Ship Deck, so `metal_grill.tres` is not assigned in this scenery yet.

### Locker Room / Public Shower

Second-expansion assignments found:

- `wet_ground`: 5 shower wet patch surfaces
- `fabric_polyester`: 3 towel/cloth surfaces
- `weathered_metal`: 4 metal fixture surfaces
- `metal_plate`: 5 locker/metal panel surfaces
- `metal_grill`: 5 drain/grate surfaces
- `subway_tile`: 5 wall tile surfaces
- `wicker`: 2 laundry basket surfaces
- `foam`: 4 rubber/foam mat or sponge surfaces

Coverage status:

- Subway tile walls, lockers, drains/grates, towels, wet patches, fixtures, wicker baskets, and foam/rubber-like props are improved.
- No distinct concrete/foundation mesh was found in this scene; wall/floor readability is currently handled by tile materials.

## Objects And Sceneries Using Each New Material

| Material | Sceneries using it | Typical object usage |
|---|---|---|
| `wet_ground.tres` | Island, Resort Pool, Boardwalk, Cruise Ship Deck, Locker Room | shoreline wet ground, puddles, wet deck/tile patches, shower wet patches |
| `wet_pebbles.tres` | Island | tide pool pebble patches |
| `fabric_polyester.tres` | Resort Pool, Cruise Ship Deck, Locker Room | towels, cloth placeholders |
| `fabric_mesh.tres` | Island | broken beach/fishing net |
| `padded_leather.tres` | Resort Pool, Cruise Ship Deck | lounge chair cushions |
| `rope.tres` | Cruise Ship Deck | lifebuoy/rope placeholder |
| `weathered_metal.tres` | Island, Resort Pool, Boardwalk, Cruise Ship Deck, Locker Room | worn signs, poles, rails, fixtures, small metal props |
| `metal_plate.tres` | Boardwalk, Cruise Ship Deck, Locker Room | trash cans, deck metal panels, lockers |
| `metal_grill.tres` | Locker Room | drains and grates |
| `concrete_wall.tres` | Boardwalk | food stand/foundation surface |
| `subway_tile.tres` | Locker Room | shower/locker room wall tile |
| `terracotta_tile.tres` | Resort Pool | decorative patio tile |
| `wicker.tres` | Locker Room | laundry basket placeholders |
| `foam.tres` | Resort Pool, Cruise Ship Deck, Locker Room | pool noodles, foam mats, sponge/soft props |

## Gameplay Safety

Checked areas:

- Player controls: no player scripts were modified by this pass.
- Physics: no physics scripts were modified by this pass.
- Collisions: no collision shapes were modified by this pass.
- Water behavior: no water scripts or water collision setup were modified by this pass.
- Scenery switching: no scenery manager scripts were modified by this pass.
- Debug panel: no debug UI scripts were modified by this pass.
- Prop reset: no prop reset scripts were modified by this pass.

Scene changes are limited to:

- `load_steps` updates
- material `ext_resource` entries
- `surface_material_override/0` assignments

Validation limits:

- `godot` and `godot4` were not available on PATH in this shell, so an editor import/run could not be executed here.
- A Godot editor reimport and in-game screenshot pass should still be done manually.

## Visual Quality Audit

Passes:

- No new second-expansion material uses transparency, so no new invisible-object risk was introduced.
- Metals use metallic maps only on metal materials and keep medium roughness values, so they should not be mirror-like by default.
- Cloth/fabric materials use high roughness values, so towels and mesh should not read as shiny plastic.
- Wet materials have lower roughness than dry ground/fabric/rope, so wet areas should read wetter than dry surfaces.
- Rope, wicker, metal grill, and foam all have normal maps connected for readability.

Needs in-editor confirmation:

- Large primitive surfaces may still stretch textures because placeholder meshes do not have authored UV unwraps.
- Boardwalk/floor tile alignment is only controlled by material UV scale for now.
- The flipflop readability against every surface still needs a gameplay screenshot pass.
- Glass from the first pass was not changed here; confirm it still reads translucent but not invisible.
- Ocean/water visuals from the first pass were not changed here; confirm water remains visible and non-solid in game.

## Placeholder Materials Still Remaining

The second expansion improves targeted surfaces, but several placeholder categories remain:

- Palm leaves, beach grass, seaweed, birds, sea foam, water glints, and other organic/ambience placeholders.
- Umbrella fabrics, awnings, sign graphics, labels, and resort/boardwalk branding details.
- Plastic bottles, cups, toys, buckets, and generic plastic props still use the first-pass `plastic.tres`.
- Some materials are assigned to whole placeholder meshes because the meshes do not have separate surfaces for subparts.
- Some requested categories are not present as explicit geometry yet, including Boardwalk rope barriers/nets/wicker and Cruise grates/drains.
- Primitive floors, walls, and ramps still need proper UV unwraps or mesh-specific material instances for final visual quality.

## Problems Found

1. Expansion 02 `.import` sidecars are not present yet in `res://assets/textures/pbr/`.
   - Impact: Godot should generate these on editor import, but this needs an editor check before a build.

2. Requested opacity maps are unavailable or intentionally skipped.
   - `fabric_mesh`: opacity missing from public final maps.
   - `foam`: opacity missing from public final maps.
   - `metal_grill`: opacity exists but is intentionally not connected to avoid sorting artifacts.

3. Some requested object categories do not exist as distinct nodes in the current placeholder scenes.
   - Island: no explicit rope mesh.
   - Resort Pool: no actual drain/grate mesh.
   - Boardwalk: no explicit rope barrier, fishing net, or wicker basket/chair mesh.
   - Cruise Ship Deck: no separate grate/drain mesh.
   - Locker Room: no distinct concrete/foundation mesh.

4. Visual quality has not been verified in a live Godot viewport from this shell.
   - Impact: no static resource problem is visible, but texture stretching, material brightness, and readability need a screenshot pass.

5. Git reports CRLF normalization warnings for edited scene files.
   - Impact: this is line-ending hygiene, not a material or gameplay issue.

## Recommended Fixes

Short-term before menu visual design:

- Open the project in Godot and let it import the second-expansion PNG files.
- Check the Import dock or FileSystem dock for missing texture warnings.
- Play through each scenery and confirm there are no invisible surfaces.
- Capture quick screenshots of Island, Resort Pool, Boardwalk, Cruise Ship Deck, and Locker Room.
- Tune material brightness/roughness if any surface is too shiny or too dark.

Medium-term visual polish:

- Add distinct mesh pieces for rope barriers, fishing nets, wicker baskets/chairs, grates, drains, and concrete foundations where missing.
- Split multi-part placeholder meshes into separate surfaces so material overrides can target only the intended object parts.
- Add proper UV unwraps or mesh-specific material instances for large floors, walls, boardwalk planks, and terrain patches.
- Create labeled/signage textures later instead of plain material-only signs.
- Add dedicated cloth/umbrella variants if towels, umbrellas, and awnings need stronger visual separation.

## Ready For Menu Visual Design

Yes, this texture pass is stable enough to start menu visual design.

The remaining work is mostly visual verification and asset fidelity, not a blocker for menu flow. Before final screenshots, trailers, or store assets, run the project in Godot, allow texture imports, and do an in-game visual pass through all five sceneries.
