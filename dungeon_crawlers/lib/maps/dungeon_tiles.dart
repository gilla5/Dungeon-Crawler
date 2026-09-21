import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// Tile size shared by every map in the game. Kept in sync with the
/// `tileSize` constant in main.dart (both are 32).
const double kTileSize = 32;

/// Every value that can appear in a map's matrix. Values are `double`
/// because [MatrixLayer] expects `List<List<double>>` -- see the original
/// MatrixMapGenerator usage this project started from.
class DungeonTileValues {
  static const double floor = 0;
  static const double wall = 1;
  static const double hazard = 2;
  static const double rubble = 3;
  static const double stairs = 4;
}

/// Color palette for one map's tile set. Each map (cave, crypt, ...) defines
/// its own palette so they read as visually distinct places even though
/// they're built from the same tile *types* and the same builder function.
class DungeonPalette {
  final Color floor;
  final Color wall;
  final Color hazard;
  final Color rubble;
  final Color stairs;

  const DungeonPalette({
    required this.floor,
    required this.wall,
    required this.hazard,
    required this.rubble,
    required this.stairs,
  });
}

/// Turns a small ASCII "map art" list into the numeric matrix
/// [MatrixMapGenerator] expects. Keeping each map's layout as readable
/// strings (see cave_map.dart / crypt_map.dart) avoids hand-typing, and
/// mistyping, rows of raw numbers.
///
/// Legend:
///   #        wall
///   .        floor
///   ~ or ^   hazard (water, spikes, lava -- whatever fits the map's theme)
///   ,        rubble / decoration (walkable, just visually distinct)
///   X        stairs / exit marker
///
/// Every row must be the same length, and only use the symbols above, or
/// this throws -- that catches a typo in the art immediately instead of
/// silently producing a ragged or wrong map.
List<List<double>> matrixFromArt(List<String> art) {
  const legend = <String, double>{
    '#': DungeonTileValues.wall,
    '.': DungeonTileValues.floor,
    '~': DungeonTileValues.hazard,
    '^': DungeonTileValues.hazard,
    ',': DungeonTileValues.rubble,
    'X': DungeonTileValues.stairs,
  };

  if (art.isEmpty) {
    throw ArgumentError('Map art must have at least one row');
  }
  final width = art.first.length;

  return art.map((row) {
    if (row.length != width) {
      throw ArgumentError(
        'Map art rows must all be the same length '
        '(expected $width, got ${row.length} for "$row")',
      );
    }
    return row.split('').map((ch) {
      final value = legend[ch];
      if (value == null) {
        throw ArgumentError('Unknown map art symbol: "$ch"');
      }
      return value;
    }).toList();
  }).toList();
}

/// Shared tile builder used by every map: turns one matrix cell into the
/// [Tile] Bonfire renders, using the given map's [DungeonPalette]. Walls
/// get a collision box so the player can't walk through them; floor,
/// hazard, rubble and stairs tiles are all walkable.
Tile buildDungeonTile(ItemMatrixProperties properties, DungeonPalette palette) {
  final value = properties.value;
  final isWall = value == DungeonTileValues.wall;

  final Color color;
  if (value == DungeonTileValues.wall) {
    color = palette.wall;
  } else if (value == DungeonTileValues.hazard) {
    color = palette.hazard;
  } else if (value == DungeonTileValues.rubble) {
    color = palette.rubble;
  } else if (value == DungeonTileValues.stairs) {
    color = palette.stairs;
  } else {
    color = palette.floor;
  }

  return Tile(
    x: properties.position.x,
    y: properties.position.y,
    width: kTileSize,
    height: kTileSize,
    color: color,
    collisions: isWall ? [RectangleHitbox(size: Vector2.all(kTileSize))] : null,
  );
}
