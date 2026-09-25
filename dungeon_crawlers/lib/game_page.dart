import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'levels.dart';
import 'maps/dungeon_tiles.dart';
import 'player/hero_player.dart';

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
          player: HeroPlayer(position: Vector2(kTileSize * 2, kTileSize * 2)),
          backgroundColor: Colors.black,
          lightingColorGame: Colors.black.withValues(alpha: 0.4),
          cameraConfig: CameraConfig(
            zoom: getZoomFromMaxVisibleTile(context, kTileSize, 16),
            moveOnlyMapArea: true,
          ),
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
