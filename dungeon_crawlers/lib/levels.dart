import 'package:bonfire/bonfire.dart';

import 'maps/cave_map.dart';
import 'maps/crypt_map.dart';
import 'maps/magma_map.dart';
import 'maps/shadow_map.dart';

/// The playable levels, in order. Each entry pairs a display name with the
/// function that builds that level's [WorldMap].
/// Cave / Crypt use [MatrixMapGenerator]; Magma / Shadow load Tiled `.tmj` maps.
final levels = <({String name, WorldMap Function() build})>[
  (name: 'The Sunken Cave', build: buildCaveMap),
  (name: 'The Bone Crypt', build: buildCryptMap),
  (name: 'The Magma Forge', build: buildMagmaMap),
  (name: 'The Shadow Temple', build: buildShadowMap),
];
