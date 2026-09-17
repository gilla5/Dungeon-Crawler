import 'package:flutter_test/flutter_test.dart';

import 'package:dungeon_crawlers/main.dart';

void main() {
  test('app and game page can be constructed', () {
    expect(const MyApp(), isA<MyApp>());
    expect(const GamePage(), isA<GamePage>());
    expect(tileSize, 32);
  });
}
