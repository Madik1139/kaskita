import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/errors/app_exception.dart';
import '../models/category_model.dart';

class CategoryRepository {
  const CategoryRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;

  Future<List<CategoryModel>> getAllCategories() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> rows = await db.query(
      'categories',
      orderBy: 'is_default DESC, id ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> rows = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: <Object>[type],
      orderBy: 'is_default DESC, id ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<CategoryModel> createCustomCategory({
    required String name,
    required String type,
    String iconName = 'more_horizontal',
    String colorHex = '#0F5247',
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const AppException(AppErrorCode.categoryNameRequired);
    }
    final Database db = await _dbHelper.database;
    final int id = await db.insert('categories', <String, Object?>{
      'name': trimmed,
      'type': type,
      'icon_name': iconName,
      'color_hex': colorHex,
      'is_default': 0,
    });

    final List<Map<String, Object?>> rows = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: <Object>[id],
      limit: 1,
    );
    return CategoryModel.fromMap(rows.first);
  }

  Future<void> deleteCustomCategory(int id) async {
    final Database db = await _dbHelper.database;
    await db.delete(
      'categories',
      where: 'id = ? AND is_default = 0',
      whereArgs: <Object>[id],
    );
  }
}
