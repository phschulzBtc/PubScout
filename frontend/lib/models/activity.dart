import 'package:meta/meta.dart';

@immutable
class Activity {
  final String name;
  final String icon;
  final List<String> osmTags;

  const Activity({
    required this.name,
    required this.icon,
    this.osmTags = const [],
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final icon = json['icon'];
    if (name is! String) {
      throw FormatException('Activity: missing or invalid "name" field', json);
    }
    if (icon is! String) {
      throw FormatException('Activity: missing or invalid "icon" field', json);
    }
    return Activity(
      name: name,
      icon: icon,
      osmTags: (json['osm_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'osm_tags': osmTags,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          icon == other.icon;

  @override
  int get hashCode => name.hashCode ^ icon.hashCode;

  @override
  String toString() => 'Activity(name: $name, icon: $icon)';
}
