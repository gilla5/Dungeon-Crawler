import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'maps/cave_map.dart';
import 'maps/crypt_map.dart';
import 'maps/magma_map.dart';
import 'maps/shadow_map.dart';

const double tileSize = 32;

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
/// function that builds that level's [WorldMap].
/// Cave / Crypt use [MatrixMapGenerator]; Magma / Shadow load Tiled `.tmj` maps.
final _levels = <({String name, WorldMap Function() build})>[
  (name: 'The Sunken Cave', build: buildCaveMap),
  (name: 'The Bone Crypt', build: buildCryptMap),
  (name: 'The Magma Forge', build: buildMagmaMap),
  (name: 'The Shadow Temple', build: buildShadowMap),
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

    // Bonfire 4.x API — older docs used `joystick:` / `progress:` / a raw
    // path string for Tiled. Those were renamed or removed.
    return Stack(
      children: [
        BonfireWidget(
          // A fresh key forces Bonfire to fully rebuild the game (map,
          // player position, camera) whenever the level changes, rather
          // than trying to hot-swap the map inside a running instance.
          key: ValueKey(_levelIndex),
          // Cave/Crypt return MatrixMapGenerator maps; Magma/Shadow return
          // WorldMapByTiled (see magma_map.dart / shadow_map.dart).
          map: level.build(),
          // was `joystick:` — now a list so you can combine controls
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
          // If player is omitted, the directional controls the map camera
          player: HeroPlayer(position: Vector2(tileSize * 2, tileSize * 2)),
          // interface: KnightInterface(),
          // background: MyParallaxBackground(), // extend GameBackground
          backgroundColor: Colors.black,
          debugMode: false,
          showCollisionArea: false,
          collisionAreaColor: Colors.blue,
          lightingColorGame: Colors.black.withValues(alpha: 0.4),
          colorFilter: GameColorFilter(),
          components: const [],
          // overlayBuilderMap: {
          //   'barLife': (context, game) => const MyBarLifeWidget(),
          // },
          // initialActiveOverlays: ['barLife'],
          cameraConfig: CameraConfig(
            zoom: getZoomFromMaxVisibleTile(context, tileSize, 16),
            moveOnlyMapArea: true,
          ),
          globalForces: GlobalForcesSettings(),
          onReady: (game) {},
          autofocus: true,
          // mouseCursor: SystemMouseCursors.basic,
          // `progress:` was removed in Bonfire 3+/4 — show your own loading
          // UI while preparing assets if needed.
        ),
        // Minimal level-switch UI so both maps are reachable without wiring
        // up Bonfire's Tiled-portal/multi-map-world features yet. Swap this
        // for a real portal/stairs trigger once the crypt's `X` tile should
        // actually send the player to the next level on contact.
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

/// Simple colored stand-in player until sprites are added.
class HeroPlayer extends Player with WithCollision {
  HeroPlayer({required super.position})
    : super(size: Vector2.all(tileSize * 0.8), speed: tileSize * 3);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size * 0.7, position: size * 0.15));
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)),
      paint..color = const Color(0xFFE8C547),
    );
  }
}
