import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/providers/app_preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../wallets/presentation/widgets/category_management_sheet.dart';
import '../../../wallets/presentation/widgets/wallet_management_sheet.dart';
import '../../../wallets/providers/category_provider.dart';
import '../../../wallets/providers/wallet_provider.dart';
import '../../providers/settings_provider.dart';

/// Kartu Pengaturan Tampilan & Bahasa (Bahasa Indonesia/Inggris + Tema Sistem/Terang/Gelap).
class PreferencesSettingsCard extends ConsumerWidget {
  const PreferencesSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final Locale currentLocale = ref.watch(appLocaleProvider);
    final ThemeMode currentTheme = ref.watch(themeModeProvider);

    return TactileCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                LucideIcons.languages,
                size: 18,
                color: AppColors.accent(context),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.languageSettingTitle,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _SelectorChip(
                  label: '${l10n.languageIndonesian} (ID)',
                  icon: LucideIcons.globe,
                  selected: currentLocale.languageCode == 'id',
                  onTap: () => ref
                      .read(settingsProvider.notifier)
                      .saveLocale(const Locale('id')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SelectorChip(
                  label: '${l10n.languageEnglish} (EN)',
                  icon: LucideIcons.globe,
                  selected: currentLocale.languageCode == 'en',
                  onTap: () => ref
                      .read(settingsProvider.notifier)
                      .saveLocale(const Locale('en')),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            children: <Widget>[
              Icon(
                LucideIcons.palette,
                size: 18,
                color: AppColors.accent(context),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.themeSettingTitle,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _SelectorChip(
                  label: l10n.themeSystem,
                  icon: LucideIcons.monitor,
                  selected: currentTheme == ThemeMode.system,
                  onTap: () => ref
                      .read(settingsProvider.notifier)
                      .saveThemeMode(ThemeMode.system),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SelectorChip(
                  label: l10n.themeLight,
                  icon: LucideIcons.sun,
                  selected: currentTheme == ThemeMode.light,
                  onTap: () => ref
                      .read(settingsProvider.notifier)
                      .saveThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SelectorChip(
                  label: l10n.themeDark,
                  icon: LucideIcons.moon,
                  selected: currentTheme == ThemeMode.dark,
                  onTap: () => ref
                      .read(settingsProvider.notifier)
                      .saveThemeMode(ThemeMode.dark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartu Manajemen Dompet & Kategori di halaman Pengaturan.
class LedgerManagementSettingsCard extends ConsumerWidget {
  const LedgerManagementSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final int walletCount =
        ref.watch(walletsProvider).valueOrNull?.wallets.length ?? 0;
    final int categoryCount =
        ref.watch(categoriesProvider).valueOrNull?.length ?? 0;

    return TactileCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(
              LucideIcons.wallet,
              size: 19,
              color: AppColors.accent(context),
            ),
            title: Text(
              l10n.walletManagementTitle,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              l10n.walletManagementSubtitle(walletCount),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const Icon(LucideIcons.chevronRight, size: 16),
            onTap: () => WalletManagementSheet.show(context),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              LucideIcons.tags,
              size: 19,
              color: AppColors.accent(context),
            ),
            title: Text(
              l10n.categoryManagementTitle,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              l10n.categoryManagementSubtitle(categoryCount),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const Icon(LucideIcons.chevronRight, size: 16),
            onTap: () => CategoryManagementSheet.show(context),
          ),
        ],
      ),
    );
  }
}

class _SelectorChip extends StatelessWidget {
  const _SelectorChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.accent(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.14)
              : AppColors.surfaceSecondary(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? accent : AppColors.border(context),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 14,
              color: selected ? accent : AppColors.textSecondary(context),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? accent : AppColors.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
