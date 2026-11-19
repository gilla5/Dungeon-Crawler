import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'maps/molten_depths_map.dart';
import 'maps/night_vault_map.dart';
import 'player/hero_player.dart';
import 'player/playable_character.dart';
import 'settings/game_settings.dart';

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
                  'SELECT A DUNGEON',
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
                  // Dungeon Responsive Header
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
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
                          mainAxisSize: MainAxisSize.min,
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

                  // Enter Dungeon Action Button (FittedBox to prevent right overflow)
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              size: 26,
                              color: Color(0xFFE7D2A4),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ENTER THE DUNGEON (${selected.name.toUpperCase()})',
                              style: const TextStyle(
                                fontSize: 15,
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
              // Single Large Character PNG Portrait
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _CharacterPortrait(
                    character: character,
                    size: 160,
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
          _CharacterPortrait(
            character: character,
            size: 68,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  character.name.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE7D2A4),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  character.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
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
                            character: character,
                            size: 80,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  character.name.toUpperCase(),
                                  style: TextStyle(
                                    color: character.accentColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
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
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
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
    required this.character,
    required this.size,
  });

  final PlayableCharacter character;
  final double size;

  @override
  Widget build(BuildContext context) {
    final frameCount = character.idleFrames;
    final texW = character.textureWidth.toDouble();
    final texH = character.textureHeight.toDouble();
    final totalW = texW * frameCount;

    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            widthFactor: 1 / frameCount,
            heightFactor: 1.0,
            child: Image.asset(
              'assets/images/${character.idleAsset}',
              width: totalW,
              height: texH,
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

class _SettingsDialogState extends State<SettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GameSettings _workingSettings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _workingSettings = GameSettingsController.instance.value;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyAndSave() {
    GameSettingsController.instance.update(_workingSettings);
    Navigator.of(context).pop();
  }

  void _resetDefaults() {
    setState(() {
      _workingSettings = const GameSettings();
    });
    GameSettingsController.instance.resetToDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final dialogWidth = (media.width * 0.92).clamp(280.0, 520.0);
    final dialogHeight = (media.height * 0.88).clamp(340.0, 580.0);

    return Dialog(
      backgroundColor: const Color(0xFF1C1510),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE7D2A4), width: 1.5),
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.settings_suggest_rounded,
                  color: Color(0xFFE7D2A4),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'GAME SETTINGS',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFE7D2A4),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tab Navigation (Scrollable on small screens)
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFE7D2A4),
              labelColor: const Color(0xFFE7D2A4),
              unselectedLabelColor: Colors.white54,
              isScrollable: media.width < 450,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.tune_rounded, size: 18), text: 'CONTROLS'),
                Tab(icon: Icon(Icons.wb_sunny_outlined, size: 18), text: 'DISPLAY'),
                Tab(icon: Icon(Icons.volume_up_outlined, size: 18), text: 'AUDIO'),
                Tab(icon: Icon(Icons.sports_esports_outlined, size: 18), text: 'GAMEPLAY'),
              ],
            ),
            const SizedBox(height: 12),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildControlsTab(),
                  _buildDisplayTab(),
                  _buildAudioTab(),
                  _buildGameplayTab(),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Footer Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _resetDefaults,
                  icon: const Icon(Icons.restart_alt_rounded, color: Colors.white54, size: 18),
                  label: const Text(
                    'RESET',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F351F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: const BorderSide(color: Color(0xFFE7D2A4)),
                    ),
                  ),
                  onPressed: _applyAndSave,
                  child: const Text('SAVE & CLOSE', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsTab() {
    return ListView(
      children: [
        _buildSliderTile(
          title: 'JOYSTICK SENSITIVITY',
          subtitle: 'Adjust movement speed and responsiveness multiplier',
          icon: Icons.speed_rounded,
          value: _workingSettings.joystickSensitivity,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          valueLabel: '${_workingSettings.joystickSensitivity.toStringAsFixed(1)}x',
          onChanged: (val) {
            setState(() {
              _workingSettings = _workingSettings.copyWith(joystickSensitivity: val);
            });
          },
        ),
        const Divider(color: Colors.white12, height: 20),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.touch_app_outlined, color: Color(0xFFE7D2A4)),
          title: const Text(
            'ON-SCREEN JOYSTICK',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          subtitle: const Text(
            'Show virtual touch movement controls on screen',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          activeThumbColor: const Color(0xFFE7D2A4),
          value: _workingSettings.showVirtualJoystick,
          onChanged: (val) {
            setState(() {
              _workingSettings = _workingSettings.copyWith(showVirtualJoystick: val);
            });
          },
        ),
      ],
    );
  }

  Widget _buildDisplayTab() {
    return ListView(
      children: [
        _buildSliderTile(
          title: 'DUNGEON BRIGHTNESS',
          subtitle: 'Adjust ambient lighting level in dark dungeon corridors',
          icon: Icons.wb_sunny_rounded,
          value: _workingSettings.brightness,
          min: 0.1,
          max: 1.0,
          divisions: 18,
          valueLabel: '${(_workingSettings.brightness * 100).round()}%',
          onChanged: (val) {
            setState(() {
              _workingSettings = _workingSettings.copyWith(brightness: val);
            });
          },
        ),
        const Divider(color: Colors.white12, height: 20),
        _buildSliderTile(
          title: 'CAMERA ZOOM',
          subtitle: 'Adjust field of view distance to hero character',
          icon: Icons.zoom_in_rounded,
          value: _workingSettings.cameraZoom,
          min: 0.8,
          max: 1.5,
          divisions: 7,
          valueLabel: '${_workingSettings.cameraZoom.toStringAsFixed(1)}x',
          onChanged: (val) {
            setState(() {
              _workingSettings = _workingSettings.copyWith(cameraZoom: val);
            });
          },
        ),
        const Divider(color: Colors.white12, height: 20),
        const Text(
          'VISUAL STYLE PRESET',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: ['Normal', 'Moody Dark', 'Sepia Vintage', 'High Contrast'].map((preset) {
            final isSelected = _workingSettings.visualPreset == preset;
            return ChoiceChip(
              label: Text(preset),
              selected: isSelected,
              selectedColor: const Color(0xFF8F351F),
              backgroundColor: const Color(0xFF2A2017),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFE7D2A4) : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _workingSettings = _workingSettings.copyWith(visualPreset: preset);
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAudioTab() {
    return ListView(
      children: [
        _buildSliderTile(
          title: 'MASTER VOLUME',
          subtitle: 'Overall game audio and ambient sound volume',
          icon: Icons.volume_up_rounded,
          value: _workingSettings.masterVolume,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          valueLabel: '${(_workingSettings.masterVolume * 100).round()}%',
          onChanged: (val) {
            setState(() {
              _workingSettings = _workingSettings.copyWith(masterVolume: val);
            });
          },
        ),
        const Divider(color: Colors.white12, height: 20),
        _buildSliderTile(
          title: 'SOUND EFFECTS (SFX)',
          subtitle: 'Combat, step, and trap sound volume',
          icon: Icons.graphic_eq_rounded,
          value: _workingSettings.sfxVolume,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          valueLabel: '${(_workingSettings.sfxVolume * 100).round()}%',
          onChanged: (val) {
            setState(() {
              _workingSettings = _workingSettings.copyWith(sfxVolume: val);
            });
          },
        ),
      ],
    );
  }

  Widget _buildGameplayTab() {
    return ListView(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFE7D2A4)),
          title: const Text(
            'SHOW HINTS & TIPS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          subtitle: const Text(
            'Display helpful controls and dungeon survival tips during gameplay',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          activeThumbColor: const Color(0xFFE7D2A4),
          value: _workingSettings.showHints,
          onChanged: (val) {
            setState(() {
              _workingSettings = _workingSettings.copyWith(showHints: val);
            });
          },
        ),
        const Divider(color: Colors.white12, height: 20),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.monitor_heart_outlined, color: Color(0xFFE7D2A4)),
          title: const Text(
            'PERFORMANCE & FPS COUNTER',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          subtitle: const Text(
            'Display real-time frame rate (FPS) overlay in game window',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          activeThumbColor: const Color(0xFFE7D2A4),
          value: _workingSettings.showFps,
          onChanged: (val) {
            setState(() {
              _workingSettings = _workingSettings.copyWith(showFps: val);
            });
          },
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFE7D2A4), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF3D2C1E),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE7D2A4)),
              ),
              child: Text(
                valueLabel,
                style: const TextStyle(
                  color: Color(0xFFE7D2A4),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF8F351F),
            inactiveTrackColor: Colors.white12,
            thumbColor: const Color(0xFFE7D2A4),
            overlayColor: const Color(0xFFE7D2A4).withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
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
  late double _currentLife = 100;
  late double _maxLife = 100;
  bool _isDead = false;
  int _gameKeyCounter = 0;

  void _nextLevel() {
    setState(() {
      _levelIndex = (_levelIndex + 1) % _levels.length;
      _isDead = false;
      _currentLife = 100;
      _gameKeyCounter++;
    });
  }

  void _restartLevel() {
    setState(() {
      _isDead = false;
      _currentLife = 100;
      _gameKeyCounter++;
    });
  }

  void _handleDeath() {
    if (_isDead) return;
    setState(() {
      _isDead = true;
    });
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1510),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFD32F2F), width: 2),
        ),
        title: const Text(
          'YOU DIED',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD32F2F),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        content: Text(
          '${widget.character.name} fell in ${_levels[_levelIndex].name}.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _quitToMenuWithoutConfirm();
            },
            child: const Text('MAIN MENU', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8F351F),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _restartLevel();
            },
            child: const Text('TRY AGAIN'),
          ),
        ],
      ),
    );
  }

  void _openInGameSettings() {
    showDialog<void>(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  void _quitToMenuWithoutConfirm() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const StartScreen()),
        (_) => false,
      );
    }
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
      _quitToMenuWithoutConfirm();
    }
  }

  ColorFilter _getVisualColorFilter(String preset) {
    switch (preset) {
      case 'Moody Dark':
        return const ColorFilter.mode(
          Color(0x551B1B3A),
          BlendMode.darken,
        );
      case 'Sepia Vintage':
        return const ColorFilter.mode(
          Color(0x55704214),
          BlendMode.color,
        );
      case 'High Contrast':
        return const ColorFilter.mode(
          Color(0x22FFFFFF),
          BlendMode.overlay,
        );
      case 'Normal':
      default:
        return const ColorFilter.mode(
          Colors.transparent,
          BlendMode.dst,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = _levels[_levelIndex];

    return Scaffold(
      body: ValueListenableBuilder<GameSettings>(
        valueListenable: GameSettingsController.instance,
        builder: (context, settings, child) {
          final controllers = <PlayerController>[];
          if (settings.showVirtualJoystick) {
            controllers.add(Joystick(directional: JoystickDirectional()));
          }
          controllers.add(
            Keyboard(
              config: KeyboardConfig(
                directionalKeys: [
                  KeyboardDirectionalKeys.arrows(),
                  KeyboardDirectionalKeys.wasd(),
                ],
              ),
            ),
          );

          final brightnessAlpha = (1.0 - settings.brightness).clamp(0.0, 0.88);

          return Stack(
            children: [
              ColorFiltered(
                colorFilter: _getVisualColorFilter(settings.visualPreset),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: brightnessAlpha),
                    BlendMode.darken,
                  ),
                  child: BonfireWidget(
                    key: ValueKey('${_levelIndex}_${_gameKeyCounter}_${settings.showVirtualJoystick}'),
                    map: level.build(),
                    playerControllers: controllers,
                    player: HeroPlayer(
                      position: level.spawnPosition,
                      character: widget.character,
                      tileSize: level.mapTileSize,
                      sensitivity: settings.joystickSensitivity,
                      onLifeUpdate: (current, max) {
                        if (mounted) {
                          setState(() {
                            _currentLife = current;
                            _maxLife = max;
                          });
                        }
                      },
                      onDeath: _handleDeath,
                    ),
                    backgroundColor: Colors.black,
                    debugMode: settings.showFps,
                    showCollisionArea: false,
                    collisionAreaColor: Colors.blue,
                    lightingColorGame: Colors.black.withValues(alpha: 0.2),
                    colorFilter: GameColorFilter(),
                    components: const [],
                    cameraConfig: CameraConfig(
                      zoom: getZoomFromMaxVisibleTile(context, level.mapTileSize, 16) * settings.cameraZoom,
                      moveOnlyMapArea: true,
                    ),
                    globalForces: GlobalForcesSettings(),
                    onReady: (game) {},
                    autofocus: true,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
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
                              IconButton(
                                onPressed: _openInGameSettings,
                                tooltip: 'Game Settings',
                                color: const Color(0xFFE7D2A4),
                                icon: const Icon(Icons.settings_rounded),
                              ),
                              const SizedBox(width: 4),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 160),
                                child: Text(
                                  level.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                                  ),
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE7D2A4).withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                color: _currentLife > 30 ? const Color(0xFFE53935) : Colors.redAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.character.name.toUpperCase(),
                                    style: TextStyle(
                                      color: widget.character.accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 120,
                                    height: 8,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (_currentLife / _maxLife).clamp(0.0, 1.0),
                                        backgroundColor: Colors.white12,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          _currentLife > 30 ? const Color(0xFFE53935) : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${_currentLife.toInt()}/${_maxLife.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (settings.showHints)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE7D2A4).withValues(alpha: 0.6)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFE7D2A4), size: 16),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'WASD/Arrows to move • Space to Attack • ⚙ for Settings',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
