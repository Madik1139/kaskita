import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Memetakan nama ikon di SQLite (`icon_name`) ke ikon Lucide (`LucideIcons`)
/// agar tidak menggunakan emoji pada sistem UI.
class CategoryIconMapper {
  CategoryIconMapper._();

  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'utensils':
        return LucideIcons.utensils;
      case 'car':
        return LucideIcons.car;
      case 'shopping_bag':
        return LucideIcons.shoppingBag;
      case 'zap':
        return LucideIcons.zap;
      case 'coffee':
        return LucideIcons.coffee;
      case 'briefcase':
        return LucideIcons.briefcase;
      case 'store':
        return LucideIcons.store;
      case 'gift':
        return LucideIcons.gift;
      case 'plus_circle':
        return LucideIcons.circlePlus;
      case 'wallet':
        return LucideIcons.wallet;
      case 'landmark':
        return LucideIcons.landmark;
      case 'smartphone':
        return LucideIcons.smartphone;
      case 'arrow_left_right':
        return LucideIcons.arrowLeftRight;
      case 'more_horizontal':
      default:
        return LucideIcons.ellipsis;
    }
  }

  static Color parseHexColor(String hexColor) {
    final String cleaned = hexColor.replaceAll('#', '');
    if (cleaned.length == 6) {
      final int? val = int.tryParse('FF$cleaned', radix: 16);
      if (val != null) {
        return Color(val);
      }
    }
    return const Color(0xFF0F5247);
  }
}

