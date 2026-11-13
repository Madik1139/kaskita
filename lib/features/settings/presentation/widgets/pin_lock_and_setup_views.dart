import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import 'pin_keypad_widgets.dart';

/// Layar Pengunci Aplikasi (PIN 6 Digit + Biometrik).
class PinLockOverlay extends ConsumerStatefulWidget {
  const PinLockOverlay({super.key});

  @override
  ConsumerState<PinLockOverlay> createState() => _PinLockOverlayState();
}

class _PinLockOverlayState extends ConsumerState<PinLockOverlay> {
  String _pin = '';
  String? _errorText;

  Future<void> _onDigitTap(String digit) async {
    if (_pin.length >= 6) {
      return;
    }
    setState(() {
      _pin += digit;
      _errorText = null;
    });
    if (_pin.length == 6) {
      try {
        await ref.read(settingsProvider.notifier).unlockWithPin(_pin);
      } catch (error) {
        if (mounted) {
          setState(() {
            _pin = '';
            _errorText = AppException.resolveError(error, context.l10n);
          });
        }
      }
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) {
      return;
    }
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorText = null;
    });
  }

  Future<void> _triggerBiometric() async {
    final String reason = context.l10n.lockScreenSubtitle;
    await ref.read(settingsProvider.notifier).unlockWithBiometrics(reason);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.accent(context).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent(context)),
                    ),
                    child: Icon(
                      LucideIcons.lock,
                      size: 24,
                      color: AppColors.accent(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.lockScreenTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.lockScreenSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 22),
                  PinDigitDots(length: _pin.length),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 20,
                    child: _errorText != null
                        ? Text(
                            _errorText!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.negative(context),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TactilePinKeypad(
                    onDigitTap: _onDigitTap,
                    onBackspaceTap: _onBackspace,
                    onBiometricTap: _triggerBiometric,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom Sheet Pengaturan / Pengubahan PIN 6 Digit.
class PinSetupSheet extends ConsumerStatefulWidget {
  const PinSetupSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const PinSetupSheet(),
    );
  }

  @override
  ConsumerState<PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends ConsumerState<PinSetupSheet> {
  String _pin = '';

  Future<void> _onDigitTap(String digit) async {
    if (_pin.length >= 6) {
      return;
    }
    setState(() => _pin += digit);
    if (_pin.length == 6) {
      final AppLocalizations l10n = context.l10n;
      try {
        await ref.read(settingsProvider.notifier).enablePinLock(_pin);
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pinSetSuccessMsg)),
          );
        }
      } catch (error) {
        if (mounted) {
          setState(() => _pin = '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppException.resolveError(error, l10n))),
          );
        }
      }
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) {
      return;
    }
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.setupPinTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(LucideIcons.x, size: 18),
              ),
            ],
          ),
          Text(
            l10n.enterPinSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          PinDigitDots(length: _pin.length),
          const SizedBox(height: 20),
          TactilePinKeypad(
            onDigitTap: _onDigitTap,
            onBackspaceTap: _onBackspace,
          ),
        ],
      ),
    );
  }
}

