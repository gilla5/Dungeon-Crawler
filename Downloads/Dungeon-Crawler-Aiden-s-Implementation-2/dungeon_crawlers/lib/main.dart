import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'maps/night_vault_map.dart';
import 'player/hero_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dungeon Crawlers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D2C1E),
          brightness: Brightness.dark,
        ),
      ),
      home: const GamePage(),
    );
  }
}

/// The playable levels, in order. Each entry pairs a display name with the
/// function that builds that level's [WorldMap], player spawn position, and tile size.
final _levels = <({
  String name,
  WorldMap Function() build,
  Vector2 spawnPosition,
  double mapTileSize,
})>[
  (
    name: 'The Night Vault',
    build: buildNightVaultMap,
    spawnPosition: Vector2(24 * 25, 24 * 56), // Starting point in top-left room near upper bookcases
    mapTileSize: 24,
  ),
];

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _levelIndex = 0;

  void _nextLevel() {
    setState(() {
      _levelIndex = (_levelIndex + 1) % _levels.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = _levels[_levelIndex];

    return Stack(
      children: [
        BonfireWidget(
          key: ValueKey(_levelIndex),
          map: level.build(),
          playerControllers: [
            Joystick(directional: JoystickDirectional()),
            Keyboard(
              config: KeyboardConfig(
                directionalKeys: [
                  KeyboardDirectionalKeys.arrows(),
                  KeyboardDirectionalKeys.wasd(),
                ],
              ),
            ),
          ],
          player: HeroPlayer(
            position: level.spawnPosition,
            tileSize: level.mapTileSize,
          ),
          backgroundColor: Colors.black,
          debugMode: false,
          showCollisionArea: false,
          collisionAreaColor: Colors.blue,
          lightingColorGame: Colors.black.withValues(alpha: 0.4),
          colorFilter: GameColorFilter(),
          components: const [],
          cameraConfig: CameraConfig(
            zoom: getZoomFromMaxVisibleTile(context, level.mapTileSize, 16),
            moveOnlyMapArea: true,
          ),
          globalForces: GlobalForcesSettings(),
          onReady: (game) {},
          autofocus: true,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  level.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
                if (_levels.length > 1)
                  ElevatedButton(
                    onPressed: _nextLevel,
                    child: const Text('Next Level'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

