import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

enum BadgeVariant {
  positive,
  negative,
  warning,
  mutation,
  neutral,
}

/// Komponen badge reusable untuk status hutang (`UNPAID`, `PARTIAL`, `PAID`),
/// Trust Badge kontak (`GOOD`, `LATE`, `WARNING`), dan label hari (`Sen`..`Min` / `Mon`..`Sun`).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    super.key,
    this.variant = BadgeVariant.neutral,
    this.icon,
    this.compact = false,
  });

  /// Factory otomatis dari kode Trust Badge kontak (`GOOD`, `LATE`, `WARNING`)
  /// dengan dukungan lokalisasi penuh (`id` / `en`).
  factory StatusBadge.fromTrustBadge(
    String trustBadge, {
    AppLocalizations? l10n,
  }) {
    switch (trustBadge.toUpperCase()) {
      case 'WARNING':
        return StatusBadge(
          label: l10n?.badgeWarning ?? 'WARNING',
          variant: BadgeVariant.negative,
          compact: true,
        );
      case 'LATE':
        return StatusBadge(
          label: l10n?.badgeLate ?? 'LATE',
          variant: BadgeVariant.warning,
          compact: true,
        );
      case 'GOOD':
      default:
        return StatusBadge(
          label: l10n?.badgeGood ?? 'GOOD',
          variant: BadgeVariant.positive,
          compact: true,
        );
    }
  }

  /// Factory otomatis dari status tagihan (`UNPAID`, `PARTIAL`, `PAID`)
  /// dengan dukungan lokalisasi penuh (`id` / `en`).
  factory StatusBadge.fromDebtStatus(
    String status, {
    AppLocalizations? l10n,
  }) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return StatusBadge(
          label: l10n?.badgePaid ?? 'LUNAS',
          variant: BadgeVariant.positive,
          compact: true,
        );
      case 'PARTIAL':
        return StatusBadge(
          label: l10n?.badgePartial ?? 'DICICIL',
          variant: BadgeVariant.warning,
          compact: true,
        );
      case 'UNPAID':
      default:
        return StatusBadge(
          label: l10n?.badgeUnpaid ?? 'BELUM LUNAS',
          variant: BadgeVariant.negative,
          compact: true,
        );
    }
  }

  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    late final Color fg;
    late final Color bg;
    late final Color border;

    switch (variant) {
      case BadgeVariant.positive:
        fg = AppColors.positive(context);
        bg = AppColors.positiveBg(context);
        border = fg.withValues(alpha: 0.35);
      case BadgeVariant.negative:
        fg = AppColors.negative(context);
        bg = AppColors.negativeBg(context);
        border = fg.withValues(alpha: 0.35);
      case BadgeVariant.warning:
        fg = AppColors.warning(context);
        bg = AppColors.warningBg(context);
        border = fg.withValues(alpha: 0.35);
      case BadgeVariant.mutation:
        fg = AppColors.mutation(context);
        bg = AppColors.mutationBg(context);
        border = fg.withValues(alpha: 0.35);
      case BadgeVariant.neutral:
        fg = AppColors.textSecondary(context);
        bg = AppColors.surfaceSecondary(context);
        border = AppColors.border(context);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3.5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: compact ? 11 : 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w700,
                  color: fg,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}
