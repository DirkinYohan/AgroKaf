import 'package:intl/intl.dart';

/// Spanish (Colombia) date formats. Requires `initializeDateFormatting`
/// (called in `main`).
class DateFormatter {
  DateFormatter._();

  static const String _locale = 'es_CO';

  /// "8 de noviembre de 2026"
  static String longDate(DateTime date) =>
      DateFormat.yMMMMd(_locale).format(date);

  /// "8 nov 2026, 3:45 p. m."
  static String dateTime(DateTime date) =>
      DateFormat.yMMMd(_locale).add_jm().format(date);
}
