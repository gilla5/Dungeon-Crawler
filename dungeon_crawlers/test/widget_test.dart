import 'package:flutter_test/flutter_test.dart';

import 'package:dungeon_crawlers/main.dart';
import 'package:dungeon_crawlers/player/playable_character.dart';
import 'package:dungeon_crawlers/settings/game_settings.dart';

void main() {
  test('app and game page can be constructed', () {
    expect(const MyApp(), isA<MyApp>());
    expect(
      const GamePage(character: defaultPlayableCharacter),
      isA<GamePage>(),
    );
  });

  test('playable characters roster is populated', () {
    expect(playableCharacters, isNotEmpty);
    expect(playableCharacters.length, equals(5));
    expect(playableCharacters.first.name, equals('Dark Knight'));
  });

  test('GameSettingsController manages settings correctly', () {
    final controller = GameSettingsController.instance;
    expect(controller.value.brightness, equals(0.6));
    expect(controller.value.joystickSensitivity, equals(1.0));

    controller.update(controller.value.copyWith(
      brightness: 0.9,
      joystickSensitivity: 1.5,
      visualPreset: 'Moody Dark',
    ));

    expect(controller.value.brightness, equals(0.9));
    expect(controller.value.joystickSensitivity, equals(1.5));
    expect(controller.value.visualPreset, equals('Moody Dark'));

    controller.resetToDefaults();
    expect(controller.value.brightness, equals(0.6));
    expect(controller.value.joystickSensitivity, equals(1.0));
  });

  testWidgets('StartScreen renders dungeon title', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('DUNGEON'), findsOneWidget);
    expect(find.text('CRAWLERS'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });
}
