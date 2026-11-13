import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/tabular_currency_text.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../l10n/app_localizations.dart';
import '../models/debt_models.dart';
import '../providers/debt_provider.dart';
import 'contact_detail_screen.dart';
import 'widgets/contact_and_cap_sheets.dart';

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
              _DebtOverviewHeaderCard(state: state, l10n: l10n),
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
                        _ContactDirectoryRow(
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

class _DebtOverviewHeaderCard extends StatelessWidget {
  const _DebtOverviewHeaderCard({
    required this.state,
    required this.l10n,
  });

  final DebtsDirectoryState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final Color warningColor = AppColors.warning(context);
    final Color accentColor = AppColors.accent(context);

    return TactileCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.debtHeaderReceivablesLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        TabularCurrencyText(
                          amount: state.totalReceivables,
                          fontSize: 18,
                          semanticType: CurrencySemanticType.positive,
                          showPlusSign: state.totalReceivables > 0,
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.debtHeaderPayablesLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        TabularCurrencyText(
                          amount: -state.totalPayables,
                          fontSize: 18,
                          semanticType: CurrencySemanticType.negative,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.lendingCapBarTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => LendingCapSheet.show(
                        context,
                        initialLimit: state.lendingCapLimit,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          children: <Widget>[
                            TabularCurrencyText(
                              amount: state.lendingCapLimit,
                              fontSize: 12,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.pencil,
                              size: 12,
                              color: accentColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.lendingCapProgress,
                    minHeight: 7,
                    backgroundColor: AppColors.surfaceSecondary(context),
                    color: state.isLendingCapExceeded
                        ? warningColor
                        : accentColor,
                  ),
                ),
                if (state.isLendingCapExceeded) ...<Widget>[
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Icon(
                        LucideIcons.triangleAlert,
                        size: 14,
                        color: warningColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.errLendingCapExceededWarning(
                            CurrencyFormatter.format(state.lendingCapLimit),
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: warningColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactDirectoryRow extends StatelessWidget {
  const _ContactDirectoryRow({
    required this.contact,
    required this.l10n,
    required this.onTap,
  });

  final ContactSummaryModel contact;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isPositive = contact.netBalance > 0;
    final bool isNegative = contact.netBalance < 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          contact.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge.fromTrustBadge(
                        contact.trustBadge,
                        l10n: l10n,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${l10n.openDebtsCountLabel(contact.openDebtsCount)}'
                    '${contact.earliestDueDate != null ? " • ${l10n.dueDateLabel}: ${contact.earliestDueDate}" : ""}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TabularCurrencyText(
              amount: contact.netBalance,
              showPlusSign: isPositive,
              semanticType: isPositive
                  ? CurrencySemanticType.positive
                  : isNegative
                      ? CurrencySemanticType.negative
                      : CurrencySemanticType.neutral,
            ),
            const SizedBox(width: 4),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}
