import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';

/// Toxic floor trap that activates only while stepped on.
class ToxicTrap extends GameDecoration with WithSensor<Player> {
  bool _showActiveSprite = false;
  double _activeTimer = 0.0;

  ToxicTrap({required super.position})
      : super(
          size: Vector2.all(24),
        );

  @override
  Future<void> onLoad() async {
    paint.filterQuality = FilterQuality.none;
    await _setSafeSprite();

    sensor.setup(interval: 200);
    sensor.onContactListener((player) {
      _activeTimer = 0.35;
      if (!_showActiveSprite) {
        _showActiveSprite = true;
        _setActiveSprite();
      }
      player.life.handleAttack(AttackOriginEnum.WORLD, 10, 'toxic_trap');
    });

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_showActiveSprite) {
      _activeTimer -= dt;
      if (_activeTimer <= 0) {
        _showActiveSprite = false;
        _setSafeSprite();
      }
    }
  }

  Future<void> _setSafeSprite() async {
    final safe = await MapAssetsManager.getFutureSprite(
      'night_vault/traps/toxic_green_frame_01.png',
    );
    sprite = safe;
  }

  Future<void> _setActiveSprite() async {
    final active = await MapAssetsManager.getFutureSprite(
      'night_vault/traps/toxic_green_frame_08.png',
    );
    sprite = active;
  }
}
