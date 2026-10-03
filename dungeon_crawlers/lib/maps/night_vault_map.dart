import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/spritefusion/model/spritefucion_map.dart';

import '../objects/spike_trap.dart';
import '../objects/toxic_trap.dart';

/// Level 2 - The Night Vault.
///
/// A large dungeon map loaded directly from the SpriteFusion JSON asset
/// (`assets/images/night_vault/map.json`).
WorldMap buildNightVaultMap() {
  return WorldMapBySpritefusion(
    WorldMapReader.fromAsset<SpritefusionMap>('night_vault/map.json'),
    objectsBuilder: {
      'Traps_8': (position) => SpikeTrap(position: position),
      'Traps_9': (position) => SpikeTrap(position: position),
      'Traps_10': (position) => SpikeTrap(position: position),
      'Traps_11': (position) => SpikeTrap(position: position),
      'Traps_18': (position) => ToxicTrap(position: position),
      'Traps_19': (position) => ToxicTrap(position: position),
    },
  );
}
