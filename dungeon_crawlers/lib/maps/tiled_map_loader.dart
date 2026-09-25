import 'package:bonfire/bonfire.dart';

import 'dungeon_tiles.dart';

/// Loads a Tiled `.tmj` map and scales its native 16×16 tiles up to the
/// shared [kTileSize] gameplay grid.
///
/// [asset] is relative to `assets/images/` (Bonfire's [WorldMapReader.fromAsset]
/// root) — e.g. `'magma.tmj'`, not `'assets/images/magma.tmj'`.
WorldMap buildTiledMap(String asset) {
  return WorldMapByTiled(
    WorldMapReader.fromAsset(asset),
    forceTileSize: Vector2.all(kTileSize),
  );
}
