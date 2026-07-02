# PBR Material Assignment Report - Expansion 02

This pass only changed visual material assignments on `MeshInstance3D` nodes and added material `ext_resource` entries to scenery files. Gameplay scripts, physics bodies, collision shapes, water behavior, player controls, prop reset logic, and scenery switching were not edited.

## Materials Applied

- `concrete_wall.tres`: 1 node(s)
- `fabric_mesh.tres`: 2 node(s)
- `fabric_polyester.tres`: 10 node(s)
- `foam.tres`: 11 node(s)
- `metal_grill.tres`: 5 node(s)
- `metal_plate.tres`: 23 node(s)
- `padded_leather.tres`: 7 node(s)
- `rope.tres`: 1 node(s)
- `subway_tile.tres`: 5 node(s)
- `terracotta_tile.tres`: 1 node(s)
- `weathered_metal.tres`: 38 node(s)
- `wet_ground.tres`: 16 node(s)
- `wet_pebbles.tres`: 2 node(s)
- `wicker.tres`: 2 node(s)

## Deserted Island

- Scene file: `res://scenes/island/Island3D.tscn`
- Note: Added 4 material ext_resource entries.
- Assignments: 6

| Object / Node | Material Assigned | Reason | Previous Material |
| --- | --- | --- | --- |
| `Terrain/WetSandShoreline` | `wet_ground.tres` | wet shoreline/damp sand | `surface_material_override/0 = ExtResource("pbr_sand")` |
| `StaticProps/TidePoolNorth` | `wet_pebbles.tres` | tide pool pebble patch | `surface_material_override/0 = ExtResource("pbr_ocean_water")` |
| `StaticProps/TidePoolSouthWest` | `wet_pebbles.tres` | tide pool pebble patch | `surface_material_override/0 = ExtResource("pbr_ocean_water")` |
| `StaticProps/BrokenFishingNet/NetMeshA` | `fabric_mesh.tres` | fishing/beach net mesh | `surface_material_override/0 = SubResource("StandardMaterial3D_seaweed")` |
| `StaticProps/BrokenFishingNet/NetMeshB` | `fabric_mesh.tres` | fishing/beach net mesh | `surface_material_override/0 = SubResource("StandardMaterial3D_seaweed")` |
| `PhysicsProps/ShovelPlaceholder/Mesh` | `weathered_metal.tres` | small washed-up metal prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |

### Objects Skipped

- No targeted objects were skipped for missing materials.

### Remaining Placeholder Materials

- No high-priority targeted placeholder materials remain from this pass.

### UV / Stretching Concerns

- Placeholder box, cylinder, torus, and plane meshes still rely on material-level `uv1_scale`. Large floor/wall/terrain pieces may need real UV unwraps or per-mesh material instances later if repeated patterns stretch or rotate visibly.

## Resort Pool

- Scene file: `res://scenes/scenery/ResortPoolScenery3D.tscn`
- Note: Added 6 material ext_resource entries.
- Assignments: 35

| Object / Node | Material Assigned | Reason | Previous Material |
| --- | --- | --- | --- |
| `Terrain/PoolDeck/Mesh` | `terracotta_tile.tres` | resort patio/decorative tile area | `surface_material_override/0 = ExtResource("pbr_dry_tile")` |
| `Terrain/WetTilePatchWest` | `wet_ground.tres` | wet tile visual patch | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `Terrain/WetTilePatchShower` | `wet_ground.tres` | wet tile visual patch | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `Terrain/WetPuddleByChairs` | `wet_ground.tres` | wet puddle visual patch | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `Terrain/WetTileGlintWest` | `wet_ground.tres` | wet tile visual patch | `surface_material_override/0 = ExtResource("pbr_ocean_water")` |
| `Terrain/WetTileGlintChairs` | `wet_ground.tres` | wet tile visual patch | `surface_material_override/0 = ExtResource("pbr_ocean_water")` |
| `Terrain/WetPuddleSouthDeck` | `wet_ground.tres` | wet puddle visual patch | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `StaticProps/LoungeChairNorth/Mesh` | `padded_leather.tres` | lounge chair cushion/fabric | `surface_material_override/0 = ExtResource("pbr_wood")` |
| `StaticProps/LoungeChairSouth/Mesh` | `padded_leather.tres` | lounge chair cushion/fabric | `surface_material_override/0 = ExtResource("pbr_wood")` |
| `StaticProps/Umbrella/Pole/Mesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `StaticProps/UmbrellaSouth/Pole/Mesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `StaticProps/SmallTableNorth/PoleMesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `StaticProps/SmallTableSouth/PoleMesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `StaticProps/TowelNorth/Mesh` | `fabric_polyester.tres` | cloth/towel surface | `surface_material_override/0 = SubResource("StandardMaterial3D_towel")` |
| `StaticProps/TowelSouth/Mesh` | `fabric_polyester.tres` | cloth/towel surface | `surface_material_override/0 = SubResource("StandardMaterial3D_towel")` |
| `StaticProps/WetFloorSign/BoardMesh` | `weathered_metal.tres` | small weathered sign surface | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `StaticProps/WetFloorSign/WarningStripe` | `weathered_metal.tres` | small weathered sign surface | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `StaticProps/ShowerCorner/ShowerPost/PostMesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_shower")` |
| `StaticProps/ShowerCorner/ShowerHead` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_shower")` |
| `StaticProps/LoungeChairWest/Mesh` | `padded_leather.tres` | lounge chair cushion/fabric | `surface_material_override/0 = ExtResource("pbr_wood")` |
| `StaticProps/LoungeChairFarSouth/Mesh` | `padded_leather.tres` | lounge chair cushion/fabric | `surface_material_override/0 = ExtResource("pbr_wood")` |
| `StaticProps/UmbrellaWest/Pole/Mesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `StaticProps/SmallTableWest/PoleMesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `StaticProps/TowelWest/Mesh` | `fabric_polyester.tres` | cloth/towel surface | `surface_material_override/0 = SubResource("StandardMaterial3D_towel")` |
| `StaticProps/TowelOpenDeck/Mesh` | `fabric_polyester.tres` | cloth/towel surface | `surface_material_override/0 = SubResource("StandardMaterial3D_towel")` |
| `StaticProps/WetFloorSignShower/BoardMesh` | `weathered_metal.tres` | small weathered sign surface | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `StaticProps/WetFloorSignShower/WarningStripe` | `weathered_metal.tres` | small weathered sign surface | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/PoolNoodle/Mesh` | `foam.tres` | soft foam prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/PoolFloatRing/Mesh` | `foam.tres` | soft inflatable/float prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/FloatingPoolToy/Mesh` | `foam.tres` | soft inflatable/float prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/PoolFloatRingSouth/Mesh` | `foam.tres` | soft inflatable/float prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/PoolNoodleSouth/Mesh` | `foam.tres` | soft foam prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/PoolNoodleWest/Mesh` | `foam.tres` | soft foam prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/WetFloorSignLooseA/Mesh` | `weathered_metal.tres` | small weathered sign surface | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/WetFloorSignLooseB/Mesh` | `weathered_metal.tres` | small weathered sign surface | `surface_material_override/0 = ExtResource("pbr_plastic")` |

### Objects Skipped

- No targeted objects were skipped for missing materials.

### Remaining Placeholder Materials

- No high-priority targeted placeholder materials remain from this pass.

### UV / Stretching Concerns

- Placeholder box, cylinder, torus, and plane meshes still rely on material-level `uv1_scale`. Large floor/wall/terrain pieces may need real UV unwraps or per-mesh material instances later if repeated patterns stretch or rotate visibly.

## Boardwalk

- Scene file: `res://scenes/scenery/BoardwalkScenery3D.tscn`
- Note: Added 4 material ext_resource entries.
- Assignments: 16

| Object / Node | Material Assigned | Reason | Previous Material |
| --- | --- | --- | --- |
| `Terrain/WetBoardwalkPatchA` | `wet_ground.tres` | wet boardwalk patch | `surface_material_override/0 = ExtResource("pbr_old_wood")` |
| `Terrain/WetBoardwalkPatchB` | `wet_ground.tres` | wet boardwalk patch | `surface_material_override/0 = ExtResource("pbr_old_wood")` |
| `StaticProps/FoodStand/Base` | `concrete_wall.tres` | shop/foundation-style solid base | `surface_material_override/0 = ExtResource("pbr_wood")` |
| `StaticProps/BigTrashBinWest/Mesh` | `metal_plate.tres` | trash can/can metal surface | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `StaticProps/BeachTownSign/Board` | `weathered_metal.tres` | small weathered sign surface | `surface_material_override/0 = ExtResource("pbr_wood")` |
| `StaticProps/UmbrellaSandA/Pole/Mesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `StaticProps/UmbrellaSandB/Pole/Mesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `PhysicsProps/SodaCanA/Mesh` | `metal_plate.tres` | trash can/can metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_can")` |
| `PhysicsProps/SodaCanB/Mesh` | `metal_plate.tres` | trash can/can metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_can")` |
| `PhysicsProps/SodaCanC/Mesh` | `metal_plate.tres` | trash can/can metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_can")` |
| `PhysicsProps/RollingTrashA/Mesh` | `metal_plate.tres` | trash can/can metal surface | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/RollingTrashB/Mesh` | `metal_plate.tres` | trash can/can metal surface | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/LightweightSign/Mesh` | `weathered_metal.tres` | small weathered sign surface | `surface_material_override/0 = ExtResource("pbr_wood")` |
| `PhysicsProps/SodaCanD/Mesh` | `metal_plate.tres` | trash can/can metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_can")` |
| `PhysicsProps/SodaCanE/Mesh` | `metal_plate.tres` | trash can/can metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_can")` |
| `PhysicsProps/LightweightSignB/Mesh` | `weathered_metal.tres` | small weathered sign surface | `surface_material_override/0 = ExtResource("pbr_wood")` |

### Objects Skipped

- No targeted objects were skipped for missing materials.

### Remaining Placeholder Materials

- No high-priority targeted placeholder materials remain from this pass.

### UV / Stretching Concerns

- Placeholder box, cylinder, torus, and plane meshes still rely on material-level `uv1_scale`. Large floor/wall/terrain pieces may need real UV unwraps or per-mesh material instances later if repeated patterns stretch or rotate visibly.

## Cruise Ship Deck

- Scene file: `res://scenes/scenery/CruiseShipDeckScenery3D.tscn`
- Note: Added 7 material ext_resource entries.
- Assignments: 34

| Object / Node | Material Assigned | Reason | Previous Material |
| --- | --- | --- | --- |
| `Terrain/ShipDeckFloor/Mesh` | `metal_plate.tres` | ship deck metal panel/seam | `surface_material_override/0 = ExtResource("pbr_wood_planks")` |
| `Terrain/DeckSeamCenter` | `metal_plate.tres` | ship deck metal panel/seam | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `Terrain/DeckSeamPort` | `metal_plate.tres` | ship deck metal panel/seam | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `Terrain/DeckSeamStarboard` | `metal_plate.tres` | ship deck metal panel/seam | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `Terrain/WetDeckPatchPool` | `wet_ground.tres` | wet deck patch | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `Terrain/WetDeckPatchStairs` | `wet_ground.tres` | wet deck patch | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `Terrain/PoolWallNorth/Mesh` | `weathered_metal.tres` | ship railing/fitting | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `Terrain/PoolWallSouth/Mesh` | `weathered_metal.tres` | ship railing/fitting | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `Terrain/PoolWallWest/Mesh` | `weathered_metal.tres` | ship railing/fitting | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `Terrain/PoolWallEast/Mesh` | `weathered_metal.tres` | ship railing/fitting | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `StaticProps/NorthRailing/Rail` | `weathered_metal.tres` | ship railing/fitting | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `StaticProps/SouthRailing/Rail` | `weathered_metal.tres` | ship railing/fitting | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `StaticProps/EastRailing/Rail` | `weathered_metal.tres` | ship railing/fitting | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `StaticProps/WestRailing/Rail` | `weathered_metal.tres` | ship railing/fitting | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `StaticProps/RailingPostA` | `weathered_metal.tres` | ship railing/fitting | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `StaticProps/RailingPostB` | `weathered_metal.tres` | ship railing/fitting | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `StaticProps/RailingPostC` | `weathered_metal.tres` | ship railing/fitting | `surface_material_override/0 = SubResource("StandardMaterial3D_railing")` |
| `StaticProps/LoungeChairNorthA/Mesh` | `padded_leather.tres` | lounge chair cushion/fabric | `surface_material_override/0 = ExtResource("pbr_wood")` |
| `StaticProps/LoungeChairNorthB/Mesh` | `padded_leather.tres` | lounge chair cushion/fabric | `surface_material_override/0 = ExtResource("pbr_wood")` |
| `StaticProps/LoungeChairSouthA/Mesh` | `padded_leather.tres` | lounge chair cushion/fabric | `surface_material_override/0 = ExtResource("pbr_wood")` |
| `StaticProps/TowelNorth/Mesh` | `fabric_polyester.tres` | cloth/towel surface | `surface_material_override/0 = SubResource("StandardMaterial3D_towel")` |
| `StaticProps/SmallTableNorth/PoleMesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `StaticProps/UmbrellaNorth/Pole/Mesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `StaticProps/UmbrellaSouth/Pole/Mesh` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `PhysicsProps/LooseTowelA/Mesh` | `fabric_polyester.tres` | cloth/towel surface | `surface_material_override/0 = SubResource("StandardMaterial3D_towel")` |
| `PhysicsProps/LifebuoyRingA/Mesh` | `rope.tres` | lifebuoy rope-style detail | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/PoolFloatRingA/Mesh` | `foam.tres` | soft pool float | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/LooseDeckBoxA/Mesh` | `metal_plate.tres` | deck storage/metal panel prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/LooseTowelB/Mesh` | `fabric_polyester.tres` | cloth/towel surface | `surface_material_override/0 = SubResource("StandardMaterial3D_towel")` |
| `PhysicsProps/LooseDeckBoxB/Mesh` | `metal_plate.tres` | deck storage/metal panel prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/LooseDeckBoxC/Mesh` | `metal_plate.tres` | deck storage/metal panel prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/StorageCrateA/Mesh` | `metal_plate.tres` | deck storage/metal panel prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/StorageCrateB/Mesh` | `metal_plate.tres` | deck storage/metal panel prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/StorageCrateC/Mesh` | `metal_plate.tres` | deck storage/metal panel prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |

### Objects Skipped

- No targeted objects were skipped for missing materials.

### Remaining Placeholder Materials

- No high-priority targeted placeholder materials remain from this pass.

### UV / Stretching Concerns

- Placeholder box, cylinder, torus, and plane meshes still rely on material-level `uv1_scale`. Large floor/wall/terrain pieces may need real UV unwraps or per-mesh material instances later if repeated patterns stretch or rotate visibly.

## Locker Room / Public Shower

- Scene file: `res://scenes/scenery/LockerRoomScenery3D.tscn`
- Note: Added 8 material ext_resource entries.
- Assignments: 33

| Object / Node | Material Assigned | Reason | Previous Material |
| --- | --- | --- | --- |
| `Terrain/BackWall/Mesh` | `subway_tile.tres` | locker room wall tile | `surface_material_override/0 = ExtResource("pbr_dry_tile")` |
| `Terrain/LeftWall/Mesh` | `subway_tile.tres` | locker room wall tile | `surface_material_override/0 = ExtResource("pbr_dry_tile")` |
| `Terrain/RightWall/Mesh` | `subway_tile.tres` | locker room wall tile | `surface_material_override/0 = ExtResource("pbr_dry_tile")` |
| `Terrain/WetPatchShowers` | `wet_ground.tres` | wet/soap slick floor patch | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `Terrain/WetPatchCenter` | `wet_ground.tres` | wet/soap slick floor patch | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `Terrain/SoapSlickNearDrain` | `wet_ground.tres` | wet/soap slick floor patch | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `Terrain/WetReflectionCenter` | `wet_ground.tres` | wet/soap slick floor patch | `surface_material_override/0 = ExtResource("pbr_ocean_water")` |
| `Terrain/SoapSlickByBench` | `wet_ground.tres` | wet/soap slick floor patch | `surface_material_override/0 = ExtResource("pbr_wet_tile")` |
| `Terrain/RubberMatSouth` | `foam.tres` | soft mat visual replacement | `surface_material_override/0 = ExtResource("pbr_rubber_mat")` |
| `Terrain/RubberMatLockers` | `foam.tres` | soft mat visual replacement | `surface_material_override/0 = ExtResource("pbr_rubber_mat")` |
| `Terrain/DrainCenter` | `metal_grill.tres` | drain/grate metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_dark")` |
| `Terrain/DrainCenterSlotA` | `metal_grill.tres` | drain/grate metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `Terrain/DrainCenterSlotB` | `metal_grill.tres` | drain/grate metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `Terrain/DrainShowerA` | `metal_grill.tres` | drain/grate metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_dark")` |
| `Terrain/DrainShowerSlotA` | `metal_grill.tres` | drain/grate metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `StaticProps/LockerRowBack/LockerA/Mesh` | `metal_plate.tres` | locker metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_locker")` |
| `StaticProps/LockerRowBack/LockerB/Mesh` | `metal_plate.tres` | locker metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_locker")` |
| `StaticProps/LockerRowBack/LockerC/Mesh` | `metal_plate.tres` | locker metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_locker")` |
| `StaticProps/LockerRowBack/LockerD/Mesh` | `metal_plate.tres` | locker metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_locker")` |
| `StaticProps/LockerRowBack/LockerE/Mesh` | `metal_plate.tres` | locker metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_locker")` |
| `StaticProps/ShowerDividerA/Mesh` | `subway_tile.tres` | public shower wall tile | `surface_material_override/0 = ExtResource("pbr_dry_tile")` |
| `StaticProps/ShowerDividerB/Mesh` | `subway_tile.tres` | public shower wall tile | `surface_material_override/0 = ExtResource("pbr_dry_tile")` |
| `StaticProps/ShowerPipeA` | `weathered_metal.tres` | small metal fixture or pole | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `PhysicsProps/LooseTowelA/Mesh` | `fabric_polyester.tres` | cloth/towel surface | `surface_material_override/0 = SubResource("StandardMaterial3D_towel")` |
| `PhysicsProps/SpongeA/Mesh` | `foam.tres` | soft foam prop | `surface_material_override/0 = SubResource("StandardMaterial3D_sponge")` |
| `PhysicsProps/MopHandle/HandleMesh` | `weathered_metal.tres` | mop handle metal surface | `surface_material_override/0 = SubResource("StandardMaterial3D_metal")` |
| `PhysicsProps/MopHandle/HeadMesh` | `fabric_polyester.tres` | cloth/towel surface | `surface_material_override/0 = SubResource("StandardMaterial3D_towel")` |
| `PhysicsProps/WetFloorSignPhysics/Mesh` | `weathered_metal.tres` | small weathered sign surface | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/SpongeB/Mesh` | `foam.tres` | soft foam prop | `surface_material_override/0 = SubResource("StandardMaterial3D_sponge")` |
| `PhysicsProps/LooseTowelB/Mesh` | `fabric_polyester.tres` | cloth/towel surface | `surface_material_override/0 = SubResource("StandardMaterial3D_towel")` |
| `PhysicsProps/WetFloorSignPhysicsB/Mesh` | `weathered_metal.tres` | small weathered sign surface | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/LaundryBasketA/Mesh` | `wicker.tres` | basket/wicker prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |
| `PhysicsProps/LaundryBasketB/Mesh` | `wicker.tres` | basket/wicker prop | `surface_material_override/0 = ExtResource("pbr_plastic")` |

### Objects Skipped

- No targeted objects were skipped for missing materials.

### Remaining Placeholder Materials

- No high-priority targeted placeholder materials remain from this pass.

### UV / Stretching Concerns

- Placeholder box, cylinder, torus, and plane meshes still rely on material-level `uv1_scale`. Large floor/wall/terrain pieces may need real UV unwraps or per-mesh material instances later if repeated patterns stretch or rotate visibly.

## Missing Materials

- None. Every requested material resource needed for this assignment pass was present.

## Safety Notes

- Only `surface_material_override/0` values and material `ext_resource` declarations were changed in scene files.
- Collision nodes, physics materials, transforms, scripts, groups, reset zones, and gameplay settings were intentionally left untouched.
