import 'package:dungeon_crawlers/app.dart';
import 'package:dungeon_crawlers/game_page.dart';
import 'package:dungeon_crawlers/maps/dungeon_tiles.dart';
import 'package:dungeon_crawlers/maps/magma_map.dart';
import 'package:dungeon_crawlers/maps/shadow_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiledjsonreader/map/layer/object_layer.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

void main() {
  // Needed so rootBundle can load assets/images/*.tmj in tests.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('app and game page can be constructed', () {
    expect(const MyApp(), isA<MyApp>());
    expect(const GamePage(), isA<GamePage>());
    expect(kTileSize, 32);
  });

  test('magma and shadow Tiled maps load with tilesets', () async {
    // Full path from project root — TiledJsonReader does not add assets/images/.
    final magma = await TiledJsonReader('assets/images/magma.tmj').read();
    expect(magma.width, 16);
    expect(magma.height, 12);
    expect(magma.tileSets, isNotNull);
    expect(magma.tileSets!.length, 2);
    expect(magma.tileSets!.first.image, 'dungeon_ii.png');
    expect(magma.tileSets!.last.image, 'extras.png');

    // Stairs object is how future portals hook in (objectsBuilder key = name).
    final stairs = magma.layers!
        .whereType<ObjectLayer>()
        .expand((l) => l.objects ?? const [])
        .where((o) => o.name == 'stairs');
    expect(stairs, isNotEmpty);

    final shadow = await TiledJsonReader('assets/images/shadow.tmj').read();
    expect(shadow.width, 16);
    expect(shadow.height, 12);

    // Builders only construct WorldMapByTiled; they do not load tiles yet.
    expect(buildMagmaMap(), isNotNull);
    expect(buildShadowMap(), isNotNull);
  });
}
