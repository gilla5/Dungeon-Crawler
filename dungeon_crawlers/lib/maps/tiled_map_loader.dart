import 'package:bonfire/bonfire.dart';

import 'dungeon_tiles.dart';

/// Loads a Tiled `.tmj` map under `assets/images/` and scales its native
/// 16×16 tiles up to the shared [kTileSize] gameplay grid.
WorldMap buildTiledMap(String asset) {
  return WorldMapByTiled(
    WorldMapReader.fromAsset(asset),
    forceTileSize: Vector2.all(kTileSize),
  );
}
