import 'package:flutter/material.dart';

class PlayableCharacter {
  const PlayableCharacter({
    required this.name,
    required this.description,
    required this.idleAsset,
    required this.walkAsset,
    required this.accentColor,
    required this.attackStat,
    required this.speedStat,
    required this.defenseStat,
  });

  final String name;
  final String description;
  final String idleAsset;
  final String walkAsset;
  final Color accentColor;
  final int attackStat;
  final int speedStat;
  final int defenseStat;
}

const defaultPlayableCharacter = PlayableCharacter(
  name: 'Soldier',
  description: 'A disciplined fighter ready for any dungeon.',
  idleAsset: 'characters/soldier_idle.png',
  walkAsset: 'characters/soldier_walk.png',
  accentColor: Color(0xFF3A82EE),
  attackStat: 4,
  speedStat: 3,
  defenseStat: 4,
);

const playableCharacters = <PlayableCharacter>[
  defaultPlayableCharacter,
  PlayableCharacter(
    name: 'Orc',
    description: 'A powerful warrior who fears no monster.',
    idleAsset: 'characters/orc_idle.png',
    walkAsset: 'characters/orc_walk.png',
    accentColor: Color(0xFF53B135),
    attackStat: 5,
    speedStat: 2,
    defenseStat: 5,
  ),
  PlayableCharacter(
    name: 'Demon',
    description: 'A mysterious wanderer from the deepest rifts.',
    idleAsset: 'characters/demon_idle.png',
    walkAsset: 'characters/demon_walk.png',
    accentColor: Color(0xFFA838E2),
    attackStat: 5,
    speedStat: 5,
    defenseStat: 2,
  ),
  PlayableCharacter(
    name: 'Blood Monster',
    description: 'A relentless creature born beneath the dungeon.',
    idleAsset: 'characters/blood_monster_idle.png',
    walkAsset: 'characters/blood_monster_walk.png',
    accentColor: Color(0xFFE53935),
    attackStat: 4,
    speedStat: 4,
    defenseStat: 3,
  ),
];
