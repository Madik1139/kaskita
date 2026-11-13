import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconName,
    required this.colorHex,
    this.isDefault = false,
  });

  factory CategoryModel.fromMap(Map<String, Object?> map) {
    return CategoryModel(
      id: (map['id'] as int?) ?? 0,
      name: (map['name'] as String?) ?? '',
      type: (map['type'] as String?) ?? 'EXPENSE',
      iconName: (map['icon_name'] as String?) ?? 'more_horizontal',
      colorHex: (map['color_hex'] as String?) ?? '#0F5247',
      isDefault: ((map['is_default'] as int?) ?? 0) == 1,
    );
  }

  final int id;
  final String name;
  final String type; // 'INCOME' or 'EXPENSE'
  final String iconName;
  final String colorHex;
  final bool isDefault;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'type': type,
      'icon_name': iconName,
      'color_hex': colorHex,
      'is_default': isDefault ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        type,
        iconName,
        colorHex,
        isDefault,
      ];
}
