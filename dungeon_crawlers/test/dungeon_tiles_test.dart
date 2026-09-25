// Unit tests for matrixFromArt (ASCII legend → numeric tile matrix).
import 'package:dungeon_crawlers/maps/dungeon_tiles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('matrixFromArt', () {
    test('maps legend symbols to tile values', () {
      final matrix = matrixFromArt(const ['#.~^,X']);

      expect(matrix, [
        [
          DungeonTileValues.wall,
          DungeonTileValues.floor,
          DungeonTileValues.hazard,
          DungeonTileValues.hazard,
          DungeonTileValues.rubble,
          DungeonTileValues.stairs,
        ],
      ]);
    });

    test('rejects empty art', () {
      expect(() => matrixFromArt(const []), throwsArgumentError);
    });

    test('rejects unequal row lengths', () {
      expect(() => matrixFromArt(const ['##', '#']), throwsArgumentError);
    });

    test('rejects unknown symbols', () {
      expect(() => matrixFromArt(const ['#A#']), throwsArgumentError);
    });
  });
}
