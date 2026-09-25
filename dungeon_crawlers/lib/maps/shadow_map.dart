import 'package:bonfire/bonfire.dart';

import 'tiled_map_loader.dart';

/// Level 4 - The Shadow Temple.
///
/// Loaded from a Tiled JSON map ([assets/images/shadow.tmj]) instead of
/// [MatrixMapGenerator]. Layout matches the old ASCII art: twin columns,
/// void pits, rubble circles, and stairs near the north wall.
///
/// Same loading rules as [buildMagmaMap]: asset path is relative to
/// `assets/images/`.
WorldMap buildShadowMap() => buildTiledMap('shadow.tmj');
