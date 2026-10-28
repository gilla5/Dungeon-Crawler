import 'dart:ui';

import 'package:bonfire/bonfire.dart';

import 'playable_character.dart';

class HeroPlayer extends SimplePlayer with WithCollision {
  HeroPlayer({
    required super.position,
    required this.character,
    double tileSize = 24,
  }) : super(
         size: Vector2(tileSize * 6.0, tileSize * 6.0),
         speed: tileSize * 4.5,
         animation: SimpleDirectionAnimation(
           idleRight: _loadAnimation(character.idleAsset, amount: 6),
           runRight: _loadAnimation(character.walkAsset, amount: 8),
         ),
       );

  final PlayableCharacter character;

  static Future<SpriteAnimation> _loadAnimation(
    String path, {
    required int amount,
  }) {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.12,
        textureSize: Vector2(100, 100),
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    paint.filterQuality = FilterQuality.none;
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.22, size.y * 0.22),
        position: Vector2(size.x * 0.41, size.y * 0.39),
      ),
    );
    return super.onLoad();
  }
}
