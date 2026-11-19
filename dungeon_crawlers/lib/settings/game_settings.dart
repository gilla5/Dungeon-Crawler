import 'package:flutter/material.dart';

/// Game configuration settings model.
class GameSettings {
  final double masterVolume; // 0.0 to 1.0
  final double sfxVolume; // 0.0 to 1.0
  final double brightness; // 0.1 to 1.0 (dungeon ambient lighting level)
  final double joystickSensitivity; // 0.5 to 2.0 (player move speed factor)
  final double cameraZoom; // 0.8 to 1.5
  final bool showVirtualJoystick;
  final bool showHints;
  final bool showFps;
  final String visualPreset; // 'Normal', 'Moody Dark', 'Sepia Vintage', 'High Contrast'

  const GameSettings({
    this.masterVolume = 0.8,
    this.sfxVolume = 0.8,
    this.brightness = 0.6,
    this.joystickSensitivity = 1.0,
    this.cameraZoom = 1.0,
    this.showVirtualJoystick = true,
    this.showHints = true,
    this.showFps = false,
    this.visualPreset = 'Normal',
  });

  GameSettings copyWith({
    double? masterVolume,
    double? sfxVolume,
    double? brightness,
    double? joystickSensitivity,
    double? cameraZoom,
    bool? showVirtualJoystick,
    bool? showHints,
    bool? showFps,
    String? visualPreset,
  }) {
    return GameSettings(
      masterVolume: masterVolume ?? this.masterVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      brightness: brightness ?? this.brightness,
      joystickSensitivity: joystickSensitivity ?? this.joystickSensitivity,
      cameraZoom: cameraZoom ?? this.cameraZoom,
      showVirtualJoystick: showVirtualJoystick ?? this.showVirtualJoystick,
      showHints: showHints ?? this.showHints,
      showFps: showFps ?? this.showFps,
      visualPreset: visualPreset ?? this.visualPreset,
    );
  }
}

/// Global controller managing game settings state.
class GameSettingsController extends ValueNotifier<GameSettings> {
  GameSettingsController._() : super(const GameSettings());

  static final GameSettingsController instance = GameSettingsController._();

  void update(GameSettings newSettings) {
    value = newSettings;
  }

  void resetToDefaults() {
    value = const GameSettings();
  }
}
