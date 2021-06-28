import 'package:hive/hive.dart';

// flutter packages pub run build_runner build
part 'hive_data.g.dart';

@HiveType(typeId: 0)
class HiveData extends HiveObject {
  HiveData({required this.name, required this.json, required this.date});

  @HiveField(0)
  final String? name;

  @HiveField(1)
  final DateTime? date;

  @HiveField(2)
  final String? json;
}
