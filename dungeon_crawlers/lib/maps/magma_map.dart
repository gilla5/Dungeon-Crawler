import 'package:bonfire/bonfire.dart';

import 'tiled_map_loader.dart';

/// Level 3 - The Magma Forge.
///
/// Loaded from a Tiled JSON map ([assets/images/magma.tmj]) instead of
/// [MatrixMapGenerator]. Layout matches the old ASCII art: lava channels,
/// forge pillars, ash piles, and stairs near the south wall.
///
/// Bonfire resolves [WorldMapReader.fromAsset] under `assets/images/`, so
/// the path is just `magma.tmj` (not `assets/images/magma.tmj`).
WorldMap buildMagmaMap() => buildTiledMap('magma.tmj');
