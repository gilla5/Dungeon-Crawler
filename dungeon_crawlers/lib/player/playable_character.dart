import 'package:flutter/material.dart';

class PlayableCharacter {
  const PlayableCharacter({
    required this.name,
    required this.description,
    required this.idleAsset,
    required this.walkAsset,
    this.runAsset,
    this.attackAsset,
    this.defendAsset,
    this.hurtAsset,
    this.deathAsset,
    this.jumpAsset,
    required this.accentColor,
    required this.attackStat,
    required this.speedStat,
    required this.defenseStat,
    this.idleFrames = 6,
    this.walkFrames = 8,
    this.runFrames = 8,
    this.attackFrames = 6,
    this.defendFrames = 6,
    this.hurtFrames = 4,
    this.deathFrames = 12,
    this.jumpFrames = 5,
    this.textureWidth = 100,
    this.textureHeight = 100,
  });

  final String name;
  final String description;
  final String idleAsset;
  final String walkAsset;
  final String? runAsset;
  final String? attackAsset;
  final String? defendAsset;
  final String? hurtAsset;
  final String? deathAsset;
  final String? jumpAsset;
  final Color accentColor;
  final int attackStat;
  final int speedStat;
  final int defenseStat;
  final int idleFrames;
  final int walkFrames;
  final int runFrames;
  final int attackFrames;
  final int defendFrames;
  final int hurtFrames;
  final int deathFrames;
  final int jumpFrames;
  final int textureWidth;
  final int textureHeight;
}

const darkKnightCharacter = PlayableCharacter(
  name: 'Dark Knight',
  description: 'A matte black plate warrior with a crimson crest and master swordcraft.',
  idleAsset: 'knight/idle.png',
  walkAsset: 'knight/walk.png',
  runAsset: 'knight/run.png',
  attackAsset: 'knight/attack_1.png',
  defendAsset: 'knight/defend.png',
  hurtAsset: 'knight/hurt.png',
  deathAsset: 'knight/death.png',
  jumpAsset: 'knight/jump.png',
  accentColor: Color(0xFFE7D2A4),
  attackStat: 5,
  speedStat: 4,
  defenseStat: 5,
  idleFrames: 7,
  walkFrames: 8,
  runFrames: 8,
  attackFrames: 6,
  defendFrames: 6,
  hurtFrames: 4,
  deathFrames: 12,
  jumpFrames: 5,
  textureWidth: 96,
  textureHeight: 84,
);

const defaultPlayableCharacter = darkKnightCharacter;

const playableCharacters = <PlayableCharacter>[
  darkKnightCharacter,
  PlayableCharacter(
    name: 'Soldier',
    description: 'A disciplined fighter ready for any dungeon.',
    idleAsset: 'characters/soldier_idle.png',
    walkAsset: 'characters/soldier_walk.png',
    accentColor: Color(0xFF3A82EE),
    attackStat: 4,
    speedStat: 3,
    defenseStat: 4,
    idleFrames: 6,
    walkFrames: 8,
    textureWidth: 100,
    textureHeight: 100,
  ),
  PlayableCharacter(
    name: 'Orc',
    description: 'A powerful warrior who fears no monster.',
    idleAsset: 'characters/orc_idle.png',
    walkAsset: 'characters/orc_walk.png',
    accentColor: Color(0xFF53B135),
    attackStat: 5,
    speedStat: 2,
    defenseStat: 5,
    idleFrames: 6,
    walkFrames: 8,
    textureWidth: 100,
    textureHeight: 100,
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
    idleFrames: 6,
    walkFrames: 8,
    textureWidth: 100,
    textureHeight: 100,
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
    idleFrames: 6,
    walkFrames: 8,
    textureWidth: 100,
    textureHeight: 100,
  ),
];
