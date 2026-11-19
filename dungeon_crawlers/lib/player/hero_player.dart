import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

import '../settings/game_settings.dart';
import 'playable_character.dart';

class HeroPlayer extends SimplePlayer with WithCollision {
  bool _isAttacking = false;
  bool _isDefending = false;
  bool _isJumping = false;
  bool _isDead = false;

  HeroPlayer({
    required super.position,
    required this.character,
    this.tileSize = 24,
    double sensitivity = 1.0,
    this.onDeath,
    this.onLifeUpdate,
  }) : super(
         size: Vector2(
           tileSize * 3.5 * (character.textureWidth / 96.0),
           tileSize * 3.5 * (character.textureHeight / 84.0),
         ),
         speed: tileSize * 4.5 * sensitivity,
         animation: SimpleDirectionAnimation(
           idleRight: _loadAnimation(
             character.idleAsset,
             amount: character.idleFrames,
             textureSize: Vector2(
               character.textureWidth.toDouble(),
               character.textureHeight.toDouble(),
             ),
             stepTime: 0.12,
           ),
           runRight: _loadAnimation(
             character.runAsset ?? character.walkAsset,
             amount: character.runFrames,
             textureSize: Vector2(
               character.textureWidth.toDouble(),
               character.textureHeight.toDouble(),
             ),
             stepTime: 0.1,
           ),
         ),
       ) {
    life.onReceiveDamageListener((_, damage, id) {
      if (_isDefending) {
        life.add(damage * 0.5);
      }
      onLifeUpdate?.call(life.value, life.max);
      _playHurtAnimation();
    });

    life.onDieListener(() {
      onLifeUpdate?.call(0, life.max);
      _playDeathAnimation();
    });
  }

  final PlayableCharacter character;
  final double tileSize;
  final VoidCallback? onDeath;
  final void Function(double currentLife, double maxLife)? onLifeUpdate;

  static Future<SpriteAnimation> _loadAnimation(
    String path, {
    required int amount,
    required Vector2 textureSize,
    double stepTime = 0.1,
  }) {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final sensitivity = GameSettingsController.instance.value.joystickSensitivity;
    speed = tileSize * 4.5 * sensitivity;
  }

  @override
  Future<void> onLoad() async {
    paint.filterQuality = FilterQuality.none;
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.28, size.y * 0.28),
        position: Vector2(size.x * 0.36, size.y * 0.36),
      ),
    );
    return super.onLoad();
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN) {
      if (event.id == 1 ||
          event.id == LogicalKeyboardKey.space ||
          event.id == LogicalKeyboardKey.space.keyId) {
        execAttack();
      } else if (event.id == 2 ||
          event.id == LogicalKeyboardKey.shift ||
          event.id == LogicalKeyboardKey.shiftLeft ||
          event.id == LogicalKeyboardKey.keyF ||
          event.id == LogicalKeyboardKey.keyF.keyId) {
        execDefend();
      } else if (event.id == 3 ||
          event.id == LogicalKeyboardKey.keyJ ||
          event.id == LogicalKeyboardKey.keyJ.keyId) {
        execJump();
      }
    }
  }

  Future<void> execAttack() async {
    if (_isAttacking || _isDead) return;
    _isAttacking = true;

    if (character.attackAsset != null) {
      final anim = await _loadAnimation(
        character.attackAsset!,
        amount: character.attackFrames,
        textureSize: Vector2(
          character.textureWidth.toDouble(),
          character.textureHeight.toDouble(),
        ),
        stepTime: 0.08,
      );

      animation?.playOnce(
        anim,
        onFinish: () {
          _isAttacking = false;
        },
      );
    } else {
      _isAttacking = false;
    }

    attack.melee(
      damage: character.attackStat * 5.0,
      size: Vector2(width * 0.6, height * 0.6),
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
    );
  }

  Future<void> execDefend() async {
    if (_isDefending || _isDead) return;
    _isDefending = true;

    if (character.defendAsset != null) {
      final anim = await _loadAnimation(
        character.defendAsset!,
        amount: character.defendFrames,
        textureSize: Vector2(
          character.textureWidth.toDouble(),
          character.textureHeight.toDouble(),
        ),
        stepTime: 0.1,
      );

      animation?.playOnce(
        anim,
        onFinish: () {
          _isDefending = false;
        },
      );
    } else {
      Future.delayed(const Duration(milliseconds: 400), () {
        _isDefending = false;
      });
    }
  }

  Future<void> execJump() async {
    if (_isJumping || _isDead) return;
    _isJumping = true;

    if (character.jumpAsset != null) {
      final anim = await _loadAnimation(
        character.jumpAsset!,
        amount: character.jumpFrames,
        textureSize: Vector2(
          character.textureWidth.toDouble(),
          character.textureHeight.toDouble(),
        ),
        stepTime: 0.09,
      );

      animation?.playOnce(
        anim,
        onFinish: () {
          _isJumping = false;
        },
      );
    } else {
      _isJumping = false;
    }
  }

  Future<void> _playHurtAnimation() async {
    if (_isDead) return;
    if (character.hurtAsset != null) {
      final anim = await _loadAnimation(
        character.hurtAsset!,
        amount: character.hurtFrames,
        textureSize: Vector2(
          character.textureWidth.toDouble(),
          character.textureHeight.toDouble(),
        ),
        stepTime: 0.08,
      );
      animation?.playOnce(anim);
    }
  }

  Future<void> _playDeathAnimation() async {
    if (_isDead) return;
    _isDead = true;

    if (character.deathAsset != null) {
      final anim = await _loadAnimation(
        character.deathAsset!,
        amount: character.deathFrames,
        textureSize: Vector2(
          character.textureWidth.toDouble(),
          character.textureHeight.toDouble(),
        ),
        stepTime: 0.1,
      );

      animation?.playOnce(
        anim,
        onFinish: () {
          onDeath?.call();
        },
      );
    } else {
      onDeath?.call();
    }
  }
}
