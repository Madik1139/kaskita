import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider global untuk Mode Tema (System / Light / Dark).
final StateProvider<ThemeMode> themeModeProvider =
    StateProvider<ThemeMode>((Ref ref) => ThemeMode.system);

/// Provider global untuk Bahasa Aplikasi (`id` Bahasa Indonesia / `en` English).
final StateProvider<Locale> appLocaleProvider =
    StateProvider<Locale>((Ref ref) => const Locale('id'));

