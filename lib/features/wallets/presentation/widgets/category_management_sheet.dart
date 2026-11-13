import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/ledger_overview_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

/// Modal Bottom Sheet untuk melihat & menambah Kategori Kas (Pengeluaran & Pemasukan).
class CategoryManagementSheet extends ConsumerStatefulWidget {
  const CategoryManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const CategoryManagementSheet(),
    );
  }

  @override
  ConsumerState<CategoryManagementSheet> createState() =>
      _CategoryManagementSheetState();
}

class _CategoryManagementSheetState
    extends ConsumerState<CategoryManagementSheet> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedType = 'EXPENSE';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final AppLocalizations l10n = context.l10n;
    try {
      await ref.read(categoriesProvider.notifier).addCustomCategory(
            name: _nameController.text,
            type: _selectedType,
            iconName: _selectedType == 'EXPENSE' ? 'shopping_bag' : 'wallet',
            colorHex: _selectedType == 'EXPENSE' ? '#0F5247' : '#0D7A5F',
          );
      _nameController.clear();
      await ref.read(ledgerOverviewProvider.notifier).refreshOverview();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.resolveError(error, l10n))),
        );
      }
    }
  }

  Future<void> _deleteCategory(int id) async {
    await ref.read(categoriesProvider.notifier).deleteCustomCategory(id);
    await ref.read(ledgerOverviewProvider.notifier).refreshOverview();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<List<CategoryModel>> categoriesAsync =
        ref.watch(categoriesProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.categoryManagementTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                tooltip: l10n.close,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.x, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: ChoiceChip(
                  label: Center(child: Text(l10n.expenseTab)),
                  selected: _selectedType == 'EXPENSE',
                  onSelected: (_) => setState(() => _selectedType = 'EXPENSE'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: Center(child: Text(l10n.incomeTab)),
                  selected: _selectedType == 'INCOME',
                  onSelected: (_) => setState(() => _selectedType = 'INCOME'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _nameController,
                  onSubmitted: (_) => _addCategory(),
                  decoration: InputDecoration(
                    hintText: l10n.addCategoryHint,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _addCategory,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: Text(l10n.addCategoryBtn),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object err, StackTrace _) => Center(
                  child: Text(AppException.resolveError(err, l10n)),
                ),
                data: (List<CategoryModel> allCategories) {
                  final List<CategoryModel> filtered = allCategories
                      .where((CategoryModel c) => c.type == _selectedType)
                      .toList();
                  return TactileCard(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        final CategoryModel cat = filtered[index];
                        final String label =
                            LocalizationHelper.localizeCategoryName(
                          cat.name,
                          l10n,
                        );
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            CategoryIconMapper.getIcon(cat.iconName),
                            size: 18,
                            color: AppColors.accent(context),
                          ),
                          title: Text(
                            label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: cat.isDefault
                              ? null
                              : IconButton(
                                  tooltip: l10n.delete,
                                  onPressed: () => _deleteCategory(cat.id),
                                  icon: Icon(
                                    LucideIcons.trash2,
                                    size: 16,
                                    color: AppColors.negative(context),
                                  ),
                                ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
