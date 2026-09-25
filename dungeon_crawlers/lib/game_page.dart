import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'levels.dart';
import 'maps/dungeon_tiles.dart';
import 'player/hero_player.dart';

/// Hosts the Bonfire game and a temporary overlay for cycling [levels].
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _levelIndex = 0;

  void _nextLevel() {
    setState(() {
      _levelIndex = (_levelIndex + 1) % levels.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = levels[_levelIndex];

    return Stack(
      children: [
        BonfireWidget(
          // A fresh key forces Bonfire to fully rebuild the game (map,
          // player position, camera) whenever the level changes, rather
          // than trying to hot-swap the map inside a running instance.
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
          // If player is omitted, the directional controls the map camera.
          // Spawn is fixed at tile (2, 2) — open floor on every current map;
          // not read from stairs/spawn markers yet.
          player: HeroPlayer(position: Vector2(kTileSize * 2, kTileSize * 2)),
          backgroundColor: Colors.black,
          // Soft vignette so colored tiles read as "underground" without
          // needing per-entity light sources yet.
          lightingColorGame: Colors.black.withValues(alpha: 0.4),
          cameraConfig: CameraConfig(
            // Fit ~16 tiles across so a full 16-wide map fills the viewport.
            zoom: getZoomFromMaxVisibleTile(context, kTileSize, 16),
            moveOnlyMapArea: true,
          ),
        ),
        // Temporary level-switch UI so all four levels are reachable without
        // Bonfire portals / multi-map worlds yet. Replace with a real stairs
        // trigger once ASCII `X` / Tiled `stairs` objects advance the level
        // on contact.
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
