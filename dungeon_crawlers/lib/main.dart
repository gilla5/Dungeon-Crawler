import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

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

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Bonfire 4.x API — older docs used `joystick:` / `progress:` / a raw
    // path string for Tiled. Those were renamed or removed.
    return BonfireWidget(
      // required — swap to WorldMapByTiled when you have a Tiled map:
      // map: WorldMapByTiled(WorldMapReader.fromAsset('tile/map.json')),
      map: _buildMap(),
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
      // `progress:` was removed in Bonfire 3+/4 — show your own loading UI
      // while preparing assets if needed.
    );
  }
}

/// Simple colored stand-in player until sprites are added.
class HeroPlayer extends Player with WithCollision {
  HeroPlayer({required super.position})
      : super(
          size: Vector2.all(tileSize * 0.8),
          speed: tileSize * 3,
        );

  @override
  Future<void> onLoad() async {
    add(
      RectangleHitbox(
        size: size * 0.7,
        position: size * 0.15,
      ),
    );
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

WorldMap _buildMap() {
  // 0 = floor, 1 = wall
  const matrix = <List<double>>[
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  ];

  return MatrixMapGenerator.generate(
    layers: [
      MatrixLayer(matrix: matrix),
    ],
    builder: (properties) {
      final isWall = properties.value == 1;
      return Tile(
        x: properties.position.x,
        y: properties.position.y,
        width: tileSize,
        height: tileSize,
        color: isWall
            ? const Color(0xFF4A3728)
            : const Color(0xFF2A2218),
        collisions: isWall
            ? [RectangleHitbox(size: Vector2.all(tileSize))]
            : null,
      );
    },
  );
}
