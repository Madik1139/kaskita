class AppConstants {
  AppConstants._();

  static const String appName = 'KasKita';
  static const String appVersion = '1.0.0';
  static const String dbName = 'kaskita_ledger.db';
  static const int dbVersion = 1;

  // GitHub OTA Release Endpoint
  static const String githubRepoOwner = 'Madik1139';
  static const String githubRepoName = 'kaskita';
  static const String githubLatestReleaseApi =
      'https://api.github.com/repos/$githubRepoOwner/$githubRepoName/releases/latest';
  static const String githubReleasesWebUrl =
      'https://github.com/$githubRepoOwner/$githubRepoName/releases';

  // App Settings Keys
  static const String keyLendingCapLimit = 'lending_cap_limit';
  static const String keyOnboardingPromptShown = 'onboarding_prompt_shown';
  static const String keyThemeMode = 'theme_mode';
  static const String keyAppLocale = 'app_locale';
  static const String keyAppLockEnabled = 'app_lock_enabled';
  static const String secureKeyAppPin = 'kaskita_secure_app_pin';

  // Default Lending Cap (Rp 1.000.000)
  static const int defaultLendingCap = 1000000;

  // Default Expense Categories (6 Fixed)
  static const List<Map<String, Object>> defaultExpenseCategories = <Map<String, Object>>[
    <String, Object>{
      'name': 'Makan & Minum',
      'type': 'EXPENSE',
      'icon_name': 'utensils',
      'color_hex': '#C83349',
      'is_default': 1,
    },
    <String, Object>{
      'name': 'Transport & BBM',
      'type': 'EXPENSE',
      'icon_name': 'car',
      'color_hex': '#D97706',
      'is_default': 1,
    },
    <String, Object>{
      'name': 'Belanja Harian',
      'type': 'EXPENSE',
      'icon_name': 'shopping_bag',
      'color_hex': '#0F5247',
      'is_default': 1,
    },
    <String, Object>{
      'name': 'Tagihan & Kuota',
      'type': 'EXPENSE',
      'icon_name': 'zap',
      'color_hex': '#1D4ED8',
      'is_default': 1,
    },
    <String, Object>{
      'name': 'Hiburan & Nongkrong',
      'type': 'EXPENSE',
      'icon_name': 'coffee',
      'color_hex': '#9333EA',
      'is_default': 1,
    },
    <String, Object>{
      'name': 'Lainnya',
      'type': 'EXPENSE',
      'icon_name': 'more_horizontal',
      'color_hex': '#686B73',
      'is_default': 1,
    },
  ];

  // Default Income Categories (4 Fixed)
  static const List<Map<String, Object>> defaultIncomeCategories = <Map<String, Object>>[
    <String, Object>{
      'name': 'Gaji / Upah',
      'type': 'INCOME',
      'icon_name': 'briefcase',
      'color_hex': '#0D7A5F',
      'is_default': 1,
    },
    <String, Object>{
      'name': 'Hasil Usaha',
      'type': 'INCOME',
      'icon_name': 'store',
      'color_hex': '#0F5247',
      'is_default': 1,
    },
    <String, Object>{
      'name': 'Bonus / Pemberian',
      'type': 'INCOME',
      'icon_name': 'gift',
      'color_hex': '#1D4ED8',
      'is_default': 1,
    },
    <String, Object>{
      'name': 'Lainnya',
      'type': 'INCOME',
      'icon_name': 'plus_circle',
      'color_hex': '#686B73',
      'is_default': 1,
    },
  ];
}

