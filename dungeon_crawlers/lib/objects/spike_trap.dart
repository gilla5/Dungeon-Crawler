import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';

/// Floor trap component that activates only while stepped on.
class SpikeTrap extends GameDecoration with WithSensor<Player> {
  bool _showActiveSprite = false;
  double _activeTimer = 0.0;

  SpikeTrap({required super.position})
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
      player.life.handleAttack(AttackOriginEnum.WORLD, 10, 'trap');
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
      'night_vault/traps/Trap-Spikes-Floor.png',
      position: Vector2(0, 0),
      size: Vector2(24, 24),
    );
    sprite = safe;
  }

  Future<void> _setActiveSprite() async {
    final active = await MapAssetsManager.getFutureSprite(
      'night_vault/traps/Trap-Spikes-Floor.png',
      position: Vector2(72, 0),
      size: Vector2(24, 24),
    );
    sprite = active;
  }
}
