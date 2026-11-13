import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/debt_models.dart';

/// Modal Bottom Sheet untuk Pratinjau & Bagikan Struk Tagihan Bersih (Clean Invoice Receipt PNG).
class CleanInvoiceReceiptSheet extends StatefulWidget {
  const CleanInvoiceReceiptSheet({
    required this.detail,
    super.key,
  });

  final ContactDetailStateModel detail;

  static Future<void> show(
    BuildContext context, {
    required ContactDetailStateModel detail,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CleanInvoiceReceiptSheet(detail: detail),
    );
  }

  @override
  State<CleanInvoiceReceiptSheet> createState() =>
      _CleanInvoiceReceiptSheetState();
}

class _CleanInvoiceReceiptSheetState extends State<CleanInvoiceReceiptSheet> {
  final GlobalKey _receiptBoundaryKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _captureAndSharePng() async {
    if (_isSharing) {
      return;
    }
    setState(() => _isSharing = true);
    try {
      final RenderRepaintBoundary? boundary = _receiptBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        return;
      }
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return;
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final Directory tempDir = await getTemporaryDirectory();
      final String safeName = widget.detail.contact.name
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .toLowerCase();
      final File file = File('${tempDir.path}/struk_kaskita_$safeName.png');
      await file.writeAsBytes(pngBytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(file.path)],
          text:
              'Ringkasan Buku Hutang KasKita - ${widget.detail.contact.name} (${CurrencyFormatter.format(widget.detail.contact.netBalance.abs())})',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String langCode = context.currentLanguageCode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.shareInvoiceBtn,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.x, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: _receiptBoundaryKey,
                child: CleanInvoiceReceiptCard(
                  detail: widget.detail,
                  l10n: l10n,
                  langCode: langCode,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _isSharing ? null : _captureAndSharePng,
            icon: const Icon(LucideIcons.share2, size: 16),
            label: Text(l10n.shareInvoiceActionBtn),
          ),
        ],
      ),
    );
  }
}

/// Widget Struk Tagihan Bersih (selalu dirender dengan tema kertas terang `#F7F6F2`
/// dan tinta gelap `#141518` sesuai spesifikasi desain Bagian 4.3).
class CleanInvoiceReceiptCard extends StatelessWidget {
  const CleanInvoiceReceiptCard({
    required this.detail,
    required this.l10n,
    required this.langCode,
    super.key,
  });

  final ContactDetailStateModel detail;
  final AppLocalizations l10n;
  final String langCode;

  @override
  Widget build(BuildContext context) {
    final ContactSummaryModel contact = detail.contact;
    final String statusText = contact.netBalance > 0
        ? l10n.contactStatusTheyOwe
        : contact.netBalance < 0
            ? l10n.contactStatusIOwe
            : l10n.contactStatusSettled;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 12,
          height: 1.4,
          fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.invoiceHeaderTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AppColors.lightAccentPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.invoicePrintedDate(
                DateFormatter.mediumDate(DateTime.now(), localeCode: langCode),
              ),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.lightTextSecondary,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: AppColors.lightBorder, height: 1),
            ),
            _buildKeyValRow(l10n.invoiceContactName, contact.name.toUpperCase()),
            const SizedBox(height: 4),
            _buildKeyValRow(l10n.invoiceStatusLabel, statusText),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.lightSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    l10n.invoiceRemainingTotal,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(contact.netBalance.abs()),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: contact.netBalance >= 0
                          ? AppColors.lightPositive
                          : AppColors.lightNegative,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: AppColors.lightBorder, height: 1),
            ),
            Text(
              l10n.invoiceUnpaidListTitle,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            if (detail.activeDebts.isEmpty)
              Text(l10n.noActiveDebtsText)
            else
              for (final DebtItemModel item in detail.activeDebts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '• ${item.note}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '  ${l10n.initialAndRemainingLabel(CurrencyFormatter.format(item.principalAmount), CurrencyFormatter.format(item.remainingAmount))}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            if (detail.paymentHistory.isNotEmpty) ...<Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: AppColors.lightBorder, height: 1),
              ),
              Text(
                l10n.invoiceRecentPaymentsTitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              for (final DebtPaymentModel pay
                  in detail.paymentHistory.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '✓ ${pay.paymentDate} - ${pay.note} (${CurrencyFormatter.format(pay.amountPaid)})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.lightPositive,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: AppColors.lightBorder, height: 1),
            ),
            Text(
              l10n.invoiceFooterText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValRow(String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          key,
          style: const TextStyle(color: AppColors.lightTextSecondary),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
