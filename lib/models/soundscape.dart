import 'package:hive/hive.dart';

part 'soundscape.g.dart';

@HiveType(typeId: 4)
class Soundscape extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  String category;

  @HiveField(4)
  bool isPlaying;

  @HiveField(5)
  double volume;

  Soundscape({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    this.isPlaying = false,
    this.volume = 0.5,
  });

  static List<Soundscape> defaults() => [
    Soundscape(id: 'rain', name: '雨声', icon: '🌧️', category: '自然'),
    Soundscape(id: 'ocean', name: '海浪', icon: '🌊', category: '自然'),
    Soundscape(id: 'forest', name: '森林', icon: '🌲', category: '自然'),
    Soundscape(id: 'thunder', name: '雷雨', icon: '⛈️', category: '自然'),
    Soundscape(id: 'wind', name: '风声', icon: '💨', category: '自然'),
    Soundscape(id: 'campfire', name: '篝火', icon: '🔥', category: '自然'),
    Soundscape(id: 'cafe', name: '咖啡馆', icon: '☕', category: '场景'),
    Soundscape(id: 'library', name: '图书馆', icon: '📚', category: '场景'),
    Soundscape(id: 'train', name: '火车', icon: '🚂', category: '场景'),
    Soundscape(id: 'whitenoise', name: '白噪音', icon: '📡', category: '噪音'),
    Soundscape(id: 'pinknoise', name: '粉红噪音', icon: '🌸', category: '噪音'),
    Soundscape(id: 'brownnoise', name: '棕色噪音', icon: '🟤', category: '噪音'),
  ];
}
