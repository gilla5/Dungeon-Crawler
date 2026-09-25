import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import '../maps/dungeon_tiles.dart';

/// Simple colored stand-in player until sprites are added.
class HeroPlayer extends Player with WithCollision {
  HeroPlayer({required super.position})
    // Slightly smaller than a tile so the body clears wall hitboxes without
    // looking like it floats in the corridor. Speed is ~3 tiles/sec.
    : super(size: Vector2.all(kTileSize * 0.8), speed: kTileSize * 3);

  @override
  Future<void> onLoad() async {
    // Inset hitbox so corners don't snag on wall tiles while walking past.
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
