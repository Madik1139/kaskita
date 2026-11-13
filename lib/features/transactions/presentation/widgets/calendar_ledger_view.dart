import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import 'daily_transaction_group_card.dart';

/// Sub-Tab Kalender bergaya Money Manager (Realbyte):
/// Menampilkan ringkasan Pemasukan (+) & Konsumsi Murni (-) di tiap sel tanggal
/// serta daftar transaksi tanggal terpilih di bawahnya.
class CalendarLedgerView extends ConsumerWidget {
  const CalendarLedgerView({
    required this.periodState,
    super.key,
  });

  final TransactionsPeriodState periodState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final String langCode = context.currentLanguageCode;
    final DateTime activePeriod = ref.watch(selectedPeriodProvider);
    final DateTime selectedDay = ref.watch(selectedCalendarDayProvider);

    final DateTime firstDay = DateTime(activePeriod.year, activePeriod.month, 1);
    final DateTime lastDay =
        DateTime(activePeriod.year, activePeriod.month + 1, 0);
    final DateTime focusedDay = (selectedDay.year == activePeriod.year &&
            selectedDay.month == activePeriod.month)
        ? selectedDay
        : firstDay;

    final DailyTransactionGroupModel? selectedGroup =
        periodState.groupForDate(focusedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TactileCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: TableCalendar<TransactionItemModel>(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2035, 12, 31),
            focusedDay: focusedDay,
            headerVisible: false,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableGestures: AvailableGestures.horizontalSwipe,
            rowHeight: 56,
            selectedDayPredicate: (DateTime day) => isSameDay(day, focusedDay),
            onDaySelected: (DateTime selected, DateTime focused) {
              ref.read(selectedCalendarDayProvider.notifier).state = selected;
            },
            onPageChanged: (DateTime focused) {
              ref.read(selectedPeriodProvider.notifier).state =
                  DateTime(focused.year, focused.month, 1);
              ref.read(selectedCalendarDayProvider.notifier).state = focused;
            },
            calendarBuilders: CalendarBuilders<TransactionItemModel>(
              defaultBuilder: (
                BuildContext context,
                DateTime day,
                DateTime focusedDay,
              ) =>
                  _buildDayCell(
                context,
                day: day,
                group: periodState.groupForDate(day),
                isSelected: false,
                isToday: false,
              ),
              todayBuilder: (
                BuildContext context,
                DateTime day,
                DateTime focusedDay,
              ) =>
                  _buildDayCell(
                context,
                day: day,
                group: periodState.groupForDate(day),
                isSelected: false,
                isToday: true,
              ),
              selectedBuilder: (
                BuildContext context,
                DateTime day,
                DateTime focusedDay,
              ) =>
                  _buildDayCell(
                context,
                day: day,
                group: periodState.groupForDate(day),
                isSelected: true,
                isToday: isSameDay(day, DateTime.now()),
              ),
              outsideBuilder: (
                BuildContext context,
                DateTime day,
                DateTime focusedDay,
              ) =>
                  Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        AppColors.textSecondary(context).withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (selectedGroup != null)
          DailyTransactionGroupCard(group: selectedGroup)
        else
          EmptyStateView(
            icon: LucideIcons.calendarSearch,
            title: l10n.selectedDateTransactionsLabel(
              DateFormatter.mediumDate(focusedDay, localeCode: langCode),
            ),
            subtitle: l10n.noTransactionsInPeriodSubtitle,
          ),
        if (lastDay.day > 0) const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildDayCell(
    BuildContext context, {
    required DateTime day,
    required DailyTransactionGroupModel? group,
    required bool isSelected,
    required bool isToday,
  }) {
    final Color accent = AppColors.accent(context);
    final int inc = group?.totalIncome ?? 0;
    final int exp = group?.totalPureExpense ?? 0;

    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? accent.withValues(alpha: 0.14)
            : isToday
                ? AppColors.surfaceSecondary(context)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected
              ? accent
              : isToday
                  ? AppColors.border(context)
                  : Colors.transparent,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  (isSelected || isToday) ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? accent : AppColors.textPrimary(context),
            ),
          ),
          if (inc > 0)
            Text(
              '+${CurrencyFormatter.formatCompact(inc)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: AppColors.positive(context),
                fontFeatures: const <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          if (exp > 0)
            Text(
              '-${CurrencyFormatter.formatCompact(exp)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: AppColors.negative(context),
                fontFeatures: const <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

