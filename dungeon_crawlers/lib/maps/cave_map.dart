import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'dungeon_tiles.dart';

/// Level 1 - The Sunken Cave.
///
/// One winding room built around a shallow central pool, with a couple of
/// pillar clusters to break up sightlines and a scatter of rubble near the
/// stairs down. See [matrixFromArt] for the symbol legend.
const _caveArt = [
  '################',
  '#..............#',
  '#..##......##..#',
  '#..#..~~~~..#..#',
  '#....~~~~~~....#',
  '#..#..~~~~..#..#',
  '#..##......##..#',
  '#......,,......#',
  '#..##..,,..##..#',
  '#..#....X...#..#',
  '#..............#',
  '################',
];

const _cavePalette = DungeonPalette(
  floor: Color(0xFF2A2218),
  wall: Color(0xFF4A3728),
  hazard: Color(0xFF1D4E63), // water
  rubble: Color(0xFF5B4A3A),
  stairs: Color(0xFFE8C547),
);

WorldMap buildCaveMap() {
  return MatrixMapGenerator.generate(
    layers: [MatrixLayer(matrix: matrixFromArt(_caveArt))],
    builder: (properties) => buildDungeonTile(properties, _cavePalette),
  );
}
