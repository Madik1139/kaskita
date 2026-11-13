/// Utilitas pemformatan tanggal gaya Money Manager (Realbyte) dengan dukungan
/// dua bahasa: Bahasa Indonesia (`id`) dan Bahasa Inggris (`en`).
class DateFormatter {
  DateFormatter._();

  static const List<String> _shortDaysId = <String>[
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _shortDaysEn = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _shortMonthsId = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _shortMonthsEn = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _fullMonthsId = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _fullMonthsEn = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static bool _isEn(String localeCode) =>
      localeCode.toLowerCase().startsWith('en');

  /// Mengembalikan string ISO `YYYY-MM-DD` untuk penyimpanan SQLite.
  static String toIsoDate(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Mengembalikan angka tanggal 2 digit (misal `13`) untuk Header Harian Money Manager.
  static String dayNumber(DateTime date) => date.day.toString().padLeft(2, '0');

  /// Mengembalikan nama hari singkat (`Jum` untuk ID, `Fri` untuk EN).
  static String shortDayName(DateTime date, {String localeCode = 'id'}) {
    final List<String> days = _isEn(localeCode) ? _shortDaysEn : _shortDaysId;
    return days[date.weekday - 1];
  }

  /// Mengembalikan format `MM.YYYY` (misal `11.2026`) untuk Header Harian Money Manager.
  static String monthYearDot(DateTime date) =>
      '${date.month.toString().padLeft(2, '0')}.${date.year}';

  /// Mengembalikan format `13 Nov 2026` atau `13 Agu 2026` / `13 Aug 2026`.
  static String mediumDate(DateTime date, {String localeCode = 'id'}) {
    final List<String> months =
        _isEn(localeCode) ? _shortMonthsEn : _shortMonthsId;
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  /// Mengembalikan format `November 2026` sesuai bahasa aktif.
  static String fullMonthYear(DateTime date, {String localeCode = 'id'}) {
    final List<String> months =
        _isEn(localeCode) ? _fullMonthsEn : _fullMonthsId;
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Mengembalikan nama bulan singkat (`Jan`..`Des` / `Dec`) dari indeks 1..12.
  static String shortMonthByIndex(int month, {String localeCode = 'id'}) {
    final List<String> months =
        _isEn(localeCode) ? _shortMonthsEn : _shortMonthsId;
    return months[month - 1];
  }
}
