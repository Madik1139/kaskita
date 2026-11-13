import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../data/category_repository.dart';
import '../models/category_model.dart';

final Provider<CategoryRepository> categoryRepositoryProvider =
    Provider<CategoryRepository>(
  (Ref ref) => CategoryRepository(DatabaseHelper.instance),
);

final AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>
    categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
  CategoriesNotifier.new,
);

class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() async {
    return ref.watch(categoryRepositoryProvider).getAllCategories();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(categoryRepositoryProvider).getAllCategories(),
    );
  }

  Future<void> addCustomCategory({
    required String name,
    required String type,
    String iconName = 'more_horizontal',
    String colorHex = '#0F5247',
  }) async {
    await ref.read(categoryRepositoryProvider).createCustomCategory(
          name: name,
          type: type,
          iconName: iconName,
          colorHex: colorHex,
        );
    await refresh();
  }

  Future<void> deleteCustomCategory(int id) async {
    await ref.read(categoryRepositoryProvider).deleteCustomCategory(id);
    await refresh();
  }
}
