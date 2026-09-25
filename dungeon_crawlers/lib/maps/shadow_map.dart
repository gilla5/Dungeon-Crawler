import 'package:bonfire/bonfire.dart';

/// Level 4 - The Shadow Temple.
///
/// Loaded from a Tiled JSON map ([assets/images/shadow.tmj]) instead of
/// [MatrixMapGenerator]. Layout matches the old ASCII art: twin columns,
/// void pits, rubble circles, and stairs near the north wall.
///
/// Same loading rules as [buildMagmaMap]: asset path is relative to
/// `assets/images/`, and [forceTileSize] scales 16×16 Tiled tiles up to 32px.
WorldMap buildShadowMap() {
  return WorldMapByTiled(
    WorldMapReader.fromAsset('shadow.tmj'),
    // Keep gameplay on the same 32px grid as Cave/Crypt and [tileSize].
    forceTileSize: Vector2.all(32),
  );
}
