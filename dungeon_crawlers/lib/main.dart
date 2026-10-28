import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'maps/molten_depths_map.dart';
import 'maps/night_vault_map.dart';
import 'player/hero_player.dart';
import 'player/playable_character.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dungeon Crawlers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D2C1E),
          brightness: Brightness.dark,
        ),
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _openSettings() {
    showDialog<void>(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              final offset = (_backgroundController.value - 0.5) * 28;
              return Transform.translate(
                offset: Offset(offset, offset * 0.35),
                child: Transform.scale(scale: 1.08, child: child),
              );
            },
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Image.asset(
                'assets/images/menu/dungeon.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.28),
                  Colors.black.withValues(alpha: 0.62),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const Text(
                    'DUNGEON',
                    style: TextStyle(
                      color: Color(0xFFE7D2A4),
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      shadows: [Shadow(blurRadius: 16, color: Colors.black)],
                    ),
                  ),
                  const Text(
                    'CRAWLERS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 12,
                    ),
                  ),
                  const SizedBox(height: 52),
                  _MenuButton(
                    label: 'PLAY',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MapSelectionScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _MenuButton(
                    label: 'SETTINGS',
                    icon: Icons.settings_outlined,
                    onPressed: _openSettings,
                    subdued: true,
                  ),
                  const SizedBox(height: 14),
                  _MenuButton(
                    label: 'CHARACTERS',
                    icon: Icons.groups_2_outlined,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CharacterGalleryScreen(),
                      ),
                    ),
                    subdued: true,
                  ),
                  const Spacer(flex: 3),
                  const Text(
                    'ENTER THE DARK. FIND YOUR WAY OUT.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapSelectionScreen extends StatelessWidget {
  const MapSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHOOSE YOUR DUNGEON'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/menu/dungeon.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.72)),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 90, 24, 24),
              children: [
                const Text(
                  'SELECT A D',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFE7D2A4),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 24),
                _MapCard(
                  title: _levels[0].name,
                  subtitle: 'A silent vault of forgotten secrets',
                  color: const Color(0xFF167D7A),
                  icon: Icons.nightlight_round,
                  onPressed: () => _startGame(context, 0),
                ),
                const SizedBox(height: 18),
                _MapCard(
                  title: _levels[1].name,
                  subtitle: 'Lava, ash, and a dangerous descent',
                  color: const Color(0xFF9B401F),
                  icon: Icons.local_fire_department_rounded,
                  onPressed: () => _startGame(context, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startGame(BuildContext context, int levelIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CharacterSelectionScreen(levelIndex: levelIndex),
      ),
    );
  }
}

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({required this.levelIndex, super.key});

  final int levelIndex;

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selected = playableCharacters[_selectedIndex];
    final currentLevel = _levels[widget.levelIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SELECT YOUR CRAWLER',
          style: TextStyle(
            color: Color(0xFFE7D2A4),
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/menu/dungeon.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.85)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              child: Column(
                children: [
                  // Dungeon Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D2C1E),
                          border: Border.all(
                            color: const Color(0xFFE7D2A4),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black87,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.groups_2_outlined,
                              size: 18,
                              color: Color(0xFFE7D2A4),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'DUNGEON HEROES',
                              style: TextStyle(
                                color: Color(0xFFE7D2A4),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          border: Border.all(color: const Color(0xFF8F351F)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LOCATION: ${currentLevel.name.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Dungeon Character Roster Grid
                  Expanded(
                    child: GridView.builder(
                      itemCount: playableCharacters.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.92,
                          ),
                      itemBuilder: (context, index) {
                        final character = playableCharacters[index];
                        return _DungeonRosterTile(
                          character: character,
                          selected: index == _selectedIndex,
                          onPressed: () =>
                              setState(() => _selectedIndex = index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Selected Hero Dungeon Showcase Card
                  _DungeonHeroShowcase(character: selected),

                  const SizedBox(height: 12),

                  // Enter Dungeon Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8F351F),
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(
                            color: Color(0xFFE7D2A4),
                            width: 2,
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => GamePage(
                            levelIndex: widget.levelIndex,
                            character: selected,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 28,
                            color: Color(0xFFE7D2A4),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ENTER THE DUNGEON (${selected.name.toUpperCase()})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DungeonRosterTile extends StatelessWidget {
  const _DungeonRosterTile({
    required this.character,
    required this.selected,
    required this.onPressed,
  });

  final PlayableCharacter character;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? const Color(0xFFE7D2A4) : const Color(0xFF3D2C1E),
          width: selected ? 3.0 : 1.5,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: character.accentColor.withValues(alpha: 0.5),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ]
            : [],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: selected
              ? [
                  character.accentColor.withValues(alpha: 0.4),
                  const Color(0xFF181310),
                ]
              : [
                  const Color(0xFF2A2017),
                  Colors.black.withValues(alpha: 0.9),
                ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Stack(
            children: [
              // Single Large 5x Character PNG Portrait
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _CharacterPortrait(
                    asset: 'assets/images/${character.idleAsset}',
                    size: 200,
                  ),
                ),
              ),

              // Selected Hero Badge
              if (selected)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D2C1E),
                      border: Border.all(color: const Color(0xFFE7D2A4)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Color(0xFFE7D2A4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

              // Dungeon Stone Nameplate
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF3D2C1E)
                        : Colors.black.withValues(alpha: 0.85),
                    border: Border(
                      top: BorderSide(
                        color: selected
                            ? const Color(0xFFE7D2A4)
                            : Colors.white12,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    character.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFFE7D2A4)
                          : Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DungeonHeroShowcase extends StatelessWidget {
  const _DungeonHeroShowcase({required this.character});

  final PlayableCharacter character;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1510),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7D2A4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Single 5x Hero Preview
          _CharacterPortrait(
            asset: 'assets/images/${character.idleAsset}',
            size: 80,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  character.name.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFE7D2A4),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  character.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Dungeon Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatBar(
                label: 'ATK',
                value: character.attackStat,
                color: const Color(0xFFD32F2F),
              ),
              const SizedBox(height: 3),
              _StatBar(
                label: 'SPD',
                value: character.speedStat,
                color: const Color(0xFF0288D1),
              ),
              const SizedBox(height: 3),
              _StatBar(
                label: 'DEF',
                value: character.defenseStat,
                color: const Color(0xFF388E3C),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        Row(
          children: List.generate(
            5,
            (i) => Container(
              margin: const EdgeInsets.only(left: 2),
              width: 10,
              height: 7,
              decoration: BoxDecoration(
                color: i < value ? color : Colors.white12,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CharacterGalleryScreen extends StatelessWidget {
  const CharacterGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHARACTER GALLERY'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/menu/dungeon.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.78)),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 82, 18, 24),
              children: [
                const Text(
                  'MEET THE CRAWLERS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFE7D2A4),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore stats and combat styles for each fighter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                ...playableCharacters.map(
                  (character) => Card(
                    color: Colors.black.withValues(alpha: 0.68),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: character.accentColor.withValues(alpha: 0.6),
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _CharacterPortrait(
                            asset: 'assets/images/${character.idleAsset}',
                            size: 96,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  character.name.toUpperCase(),
                                  style: TextStyle(
                                    color: character.accentColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  character.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _StatBar(
                                label: 'ATK',
                                value: character.attackStat,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 3),
                              _StatBar(
                                label: 'SPD',
                                value: character.speedStat,
                                color: Colors.lightBlueAccent,
                              ),
                              const SizedBox(height: 3),
                              _StatBar(
                                label: 'DEF',
                                value: character.defenseStat,
                                color: Colors.lightGreenAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterPortrait extends StatelessWidget {
  const _CharacterPortrait({
    required this.asset,
    required this.size,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            widthFactor: 1 / 6,
            heightFactor: 1.0,
            child: Image.asset(
              asset,
              width: 600,
              height: 100,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  double _volume = 0.7;
  bool _showHints = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('SETTINGS'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.volume_up_outlined),
              Expanded(
                child: Slider(
                  value: _volume,
                  onChanged: (value) => setState(() => _volume = value),
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show hints'),
            value: _showHints,
            onChanged: (value) => setState(() => _showHints = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('DONE'),
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.subdued = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool subdued;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: subdued
              ? Colors.black.withValues(alpha: 0.52)
              : const Color(0xFF8F351F),
          foregroundColor: Colors.white,
          side: BorderSide(
            color: subdued ? Colors.white38 : const Color(0xFFE7D2A4),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withValues(alpha: 0.65),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color,
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

/// The playable levels, in order. Each entry pairs a display name with the
/// function that builds that level's [WorldMap], player spawn position, and tile size.
final _levels =
    <
      ({
        String name,
        WorldMap Function() build,
        Vector2 spawnPosition,
        double mapTileSize,
      })
    >[
      (
        name: 'The Night Vault',
        build: buildNightVaultMap,
        spawnPosition: Vector2(
          24 * 25,
          24 * 56,
        ), // Starting point in top-left room near upper bookcases
        mapTileSize: 24,
      ),
      (
        name: 'The Molten Depths',
        build: buildMoltenDepthsMap,
        spawnPosition: Vector2(
          24 * 46,
          24 * 72,
        ), // Cooled Landing, the safe room at the south end
        mapTileSize: 24,
      ),
    ];

class GamePage extends StatefulWidget {
  const GamePage({required this.character, super.key, this.levelIndex = 0});

  final int levelIndex;
  final PlayableCharacter character;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late int _levelIndex = widget.levelIndex;

  void _nextLevel() {
    setState(() {
      _levelIndex = (_levelIndex + 1) % _levels.length;
    });
  }

  Future<void> _quitToMenu() async {
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave dungeon?'),
        content: const Text('Your current progress in this run will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('LEAVE'),
          ),
        ],
      ),
    );

    if (shouldQuit == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const StartScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = _levels[_levelIndex];

    return Stack(
      children: [
        BonfireWidget(
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
          player: HeroPlayer(
            position: level.spawnPosition,
            character: widget.character,
            tileSize: level.mapTileSize,
          ),
          backgroundColor: Colors.black,
          debugMode: false,
          showCollisionArea: false,
          collisionAreaColor: Colors.blue,
          lightingColorGame: Colors.black.withValues(alpha: 0.4),
          colorFilter: GameColorFilter(),
          components: const [],
          cameraConfig: CameraConfig(
            zoom: getZoomFromMaxVisibleTile(context, level.mapTileSize, 16),
            moveOnlyMapArea: true,
          ),
          globalForces: GlobalForcesSettings(),
          onReady: (game) {},
          autofocus: true,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _quitToMenu,
                      tooltip: 'Quit to main menu',
                      color: Colors.white,
                      icon: const Icon(Icons.exit_to_app_rounded),
                    ),
                    Text(
                      level.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                    ),
                  ],
                ),
                if (_levels.length > 1)
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
