import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'dungeon_tiles.dart';

/// Level 2 - The Bone Crypt.
///
/// A more structured, symmetric room: an entry marker up top, a pair of
/// pillars guarding the middle, two spike-trap clusters, and rubble piled
/// against the side walls. See [matrixFromArt] for the symbol legend.
const _cryptArt = [
  '################',
  '#......X.......#',
  '#..............#',
  '#..#........#..#',
  '#..#.##..##.#..#',
  '#..............#',
  '#....^^..^^....#',
  '#....^^..^^....#',
  '#..,,........,,#',
  '#..#........#..#',
  '#..............#',
  '################',
];

const _cryptPalette = DungeonPalette(
  floor: Color(0xFF15161B),
  wall: Color(0xFF3A3D46),
  hazard: Color(0xFF8A1F1F), // spikes
  rubble: Color(0xFF57544B),
  stairs: Color(0xFFA9D6C4),
);

WorldMap buildCryptMap() {
  return MatrixMapGenerator.generate(
    layers: [MatrixLayer(matrix: matrixFromArt(_cryptArt))],
    builder: (properties) => buildDungeonTile(properties, _cryptPalette),
  );
}
