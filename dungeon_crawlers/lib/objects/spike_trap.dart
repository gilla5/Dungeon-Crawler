import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/map_assets_manager.dart';

/// Floor trap component that activates only while stepped on.
class SpikeTrap extends GameDecoration with WithSensor<Player> {
  bool _active = false;
  bool _showActiveSprite = false;

  SpikeTrap({required super.position})
      : super(
          size: Vector2.all(24),
        );

  @override
  Future<void> onLoad() async {
    await _setSafeSprite();

    sensor.setup(interval: 200);
    sensor.onContactListener((player) {
      _active = true;
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
    if (_active) {
      _active = false;
      return;
    }
    if (_showActiveSprite) {
      _showActiveSprite = false;
      _setSafeSprite();
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
      position: Vector2(3, 0),
      size: Vector2(24, 24),
    );
    sprite = active;
  }
}
