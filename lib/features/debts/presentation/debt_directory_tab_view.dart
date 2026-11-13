import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../l10n/app_localizations.dart';
import '../models/debt_models.dart';
import '../providers/debt_provider.dart';
import 'contact_detail_screen.dart';
import 'widgets/contact_and_cap_sheets.dart';
import 'widgets/debt_directory_widgets.dart';

/// Tampilan Tab 2 (Buku Hutang & Direktori Kontak):
/// Menampilkan Total Piutang vs Hutang, Indikator Rem Piutang (Lending Cap),
/// Filter Cepat, dan Daftar Kontak beserta Trust Badge otomatis.
class DebtDirectoryTabView extends ConsumerWidget {
  const DebtDirectoryTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<DebtsDirectoryState> dirAsync =
        ref.watch(debtsDirectoryProvider);
    final ContactFilterType activeFilter =
        ref.watch(selectedContactFilterProvider);

    return dirAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object err, StackTrace _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: EmptyStateView(
            icon: LucideIcons.triangleAlert,
            title: l10n.errUnexpectedUiTitle,
            subtitle: AppException.resolveError(err, l10n),
            actionLabel: l10n.reset,
            onActionTap: () =>
                ref.read(debtsDirectoryProvider.notifier).refresh(),
          ),
        ),
      ),
      data: (DebtsDirectoryState state) {
        final List<ContactSummaryModel> filtered =
            state.filterContacts(activeFilter);

        return RefreshIndicator(
          onRefresh: () => ref.read(debtsDirectoryProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: <Widget>[
              DebtOverviewHeaderCard(state: state, l10n: l10n),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _buildFilterChip(
                      context,
                      ref,
                      label: l10n.filterAllContacts,
                      filter: ContactFilterType.all,
                      active: activeFilter,
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      context,
                      ref,
                      label: l10n.filterTheyOweMe,
                      filter: ContactFilterType.theyOweMe,
                      active: activeFilter,
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      context,
                      ref,
                      label: l10n.filterIOweThem,
                      filter: ContactFilterType.iOweThem,
                      active: activeFilter,
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      context,
                      ref,
                      label: l10n.filterOverdue,
                      filter: ContactFilterType.overdue,
                      active: activeFilter,
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(LucideIcons.userPlus, size: 14),
                      label: Text(l10n.addContactBtn),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => ContactFormSheet.show(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                EmptyStateView(
                  icon: LucideIcons.bookUser,
                  title: l10n.emptyContactsTitle,
                  subtitle: l10n.emptyContactsSubtitle,
                  actionLabel: l10n.addContactBtn,
                  onActionTap: () => ContactFormSheet.show(context),
                )
              else
                TactileCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < filtered.length; i++) ...<Widget>[
                        if (i > 0) const Divider(),
                        ContactDirectoryRow(
                          contact: filtered[i],
                          l10n: l10n,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ContactDetailScreen(
                                  contactId: filtered[i].id,
                                ),
                              ),
                            );
                          },
                          onEdit: () => ContactFormSheet.show(
                            context,
                            editingContact: filtered[i],
                          ),
                          onDelete: () => ContactActionsHelper.confirmAndDelete(
                            context: context,
                            ref: ref,
                            contact: filtered[i],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required ContactFilterType filter,
    required ContactFilterType active,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: filter == active,
      visualDensity: VisualDensity.compact,
      onSelected: (_) =>
          ref.read(selectedContactFilterProvider.notifier).state = filter,
    );
  }
}
