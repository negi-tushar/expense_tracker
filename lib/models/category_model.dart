import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String name;

  // Store icon codePoint as int
  @HiveField(1)
  int iconCodePoint;

  // Optionally store fontFamily if you want, else use default Icons font
  @HiveField(2)
  String? fontFamily;
  @HiveField(3)
  int id;

  CategoryModel({required this.name, required this.iconCodePoint, this.fontFamily, required this.id});

  // Helper to get IconData back easily
  IconData get iconData => IconData(iconCodePoint, fontFamily: fontFamily ?? 'MaterialIcons');
}
