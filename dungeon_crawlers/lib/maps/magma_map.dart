import 'package:bonfire/bonfire.dart';

/// Level 3 - The Magma Forge.
///
/// Loaded from a Tiled JSON map ([assets/images/magma.tmj]) instead of
/// [MatrixMapGenerator]. Layout matches the old ASCII art: lava channels,
/// forge pillars, ash piles, and stairs near the south wall.
///
/// Bonfire resolves [WorldMapReader.fromAsset] under `assets/images/`, so
/// the path is just `magma.tmj` (not `assets/images/magma.tmj`). The source
/// tiles are 16×16; [forceTileSize] scales them to the game's 32px grid.
WorldMap buildMagmaMap() {
  return WorldMapByTiled(
    WorldMapReader.fromAsset('magma.tmj'),
    // Keep gameplay on the same 32px grid as Cave/Crypt and [tileSize].
    forceTileSize: Vector2.all(32),
  );
}
