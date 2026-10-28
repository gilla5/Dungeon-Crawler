import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

import 'playable_character.dart';

class HeroPlayer extends SimplePlayer with WithCollision {
  HeroPlayer({
    required super.position,
    required this.character,
    double tileSize = 24,
    this.onDeath,
    this.onLifeUpdate,
  }) : super(
         size: Vector2(tileSize * 6.0, tileSize * 6.0),
         speed: tileSize * 4.5,
         animation: SimpleDirectionAnimation(
           idleRight: _loadAnimation(character.idleAsset, amount: 6),
           runRight: _loadAnimation(character.walkAsset, amount: 8),
         ),
       ) {
    life.onReceiveDamageListener((_, __, ___) {
      onLifeUpdate?.call(life.value, life.max);
    });

    life.onDieListener(() {
      onLifeUpdate?.call(0, life.max);
      onDeath?.call();
    });
  }

  final PlayableCharacter character;
  final VoidCallback? onDeath;
  final void Function(double currentLife, double maxLife)? onLifeUpdate;

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

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == 1 || event.id == LogicalKeyboardKey.space) {
      if (event.event == ActionEvent.DOWN) {
       execAttack();
      }
    }
  }

  void execAttack() {
    attack.melee(
      damage: character.attackStat * 5.0,
      size: Vector2(width * 0.5, height * 0.5),
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
    );
  }
}
