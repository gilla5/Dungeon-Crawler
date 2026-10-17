import 'dart:ui';

import 'package:bonfire/bonfire.dart';

class HeroPlayer extends SimplePlayer with WithCollision {
  static const _spritePath = 'player/knight.png';
  static final Vector2 _spritePixelSize = Vector2(184, 264);

  HeroPlayer({
    required super.position,
    double tileSize = 24,
  }) : super(
          size: Vector2(tileSize * 1.15, tileSize * 1.7),
          speed: tileSize * 4,
          animation: SimpleDirectionAnimation(
            idleRight: _loadKnightAnimation(),
            runRight: _loadKnightAnimation(),
          ),
        );

  static Future<SpriteAnimation> _loadKnightAnimation() {
    return SpriteAnimation.load(
      _spritePath,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: _spritePixelSize,
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    paint.filterQuality = FilterQuality.none;
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.45, size.y * 0.28),
        position: Vector2(size.x * 0.275, size.y * 0.68),
      ),
    );
    return super.onLoad();
  }
}
