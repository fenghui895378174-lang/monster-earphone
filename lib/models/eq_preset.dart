import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'eq_preset.g.dart';

@HiveType(typeId: 1)
class EQPreset extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  List<double> bands;

  @HiveField(4)
  bool isCustom;

  @HiveField(5)
  bool isActive;

  EQPreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.bands,
    this.isCustom = false,
    this.isActive = false,
  });

  static List<EQPreset> defaultPresets() => [
    EQPreset(
      id: 'pop',
      name: '流行',
      icon: '🎵',
      bands: [3.0, 1.0, -1.0, 1.0, 3.0, 2.0, 1.0, 0.0, 2.0, 3.0],
    ),
    EQPreset(
      id: 'classical',
      name: '古典',
      icon: '🎻',
      bands: [4.0, 3.0, -1.0, -2.0, 0.0, 1.0, 2.0, 3.0, 4.0, 3.0],
    ),
    EQPreset(
      id: 'rock',
      name: '摇滚',
      icon: '🎸',
      bands: [5.0, 3.0, -2.0, 2.0, 4.0, 3.0, 0.0, 2.0, 3.0, 4.0],
    ),
    EQPreset(
      id: 'vocal',
      name: '人声',
      icon: '🎤',
      bands: [-2.0, -1.0, 2.0, 4.0, 3.0, 2.0, -1.0, -2.0, 0.0, 0.0],
    ),
    EQPreset(
      id: 'electronic',
      name: '电子',
      icon: '🎧',
      bands: [4.0, 2.0, -1.0, 0.0, 1.0, 3.0, 4.0, 3.0, 2.0, 4.0],
    ),
    EQPreset(
      id: 'hiphop',
      name: '嘻哈',
      icon: '🎤',
      bands: [5.0, 4.0, -1.0, -2.0, 0.0, 1.0, 2.0, 3.0, 2.0, 4.0],
    ),
    EQPreset(
      id: 'acoustic',
      name: '原声',
      icon: '🎸',
      bands: [3.0, 2.0, 0.0, 2.0, 1.0, 0.0, 2.0, 3.0, 4.0, 2.0],
    ),
    EQPreset(
      id: 'movie',
      name: '电影',
      icon: '🎬',
      bands: [4.0, 3.0, 0.0, 0.0, 2.0, 3.0, 4.0, 4.0, 3.0, 4.0],
    ),
    EQPreset(
      id: 'bass',
      name: '低音增强',
      icon: '🔊',
      bands: [6.0, 5.0, 3.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    ),
    EQPreset(
      id: 'flat',
      name: '平坦',
      icon: '➖',
      bands: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    ),
  ];

  static List<double> get frequencies => [
    32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000,
  ];

  EQPreset copyWith({
    String? id,
    String? name,
    String? icon,
    List<double>? bands,
    bool? isCustom,
    bool? isActive,
  }) {
    return EQPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      bands: bands ?? this.bands,
      isCustom: isCustom ?? this.isCustom,
      isActive: isActive ?? this.isActive,
    );
  }
}
